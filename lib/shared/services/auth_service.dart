import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/token_validator.dart';
import 'storage_service.dart';

/// États d'authentification
enum AuthState {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  error,
}

/// Résultat d'une opération d'authentification
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;
  final bool isPassportNotFound;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.isPassportNotFound = false,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'],
    );
  }

  // Factory pour passeport non trouvé
  factory AuthResult.passportNotFound(String message) {
    return AuthResult(
      success: false,
      message: message,
      isPassportNotFound: true,
    );
  }
}

/// Service d'authentification gérant le flux Passeport + OTP
class AuthService {
  final StorageService _storage;
  final DioClient _dioClient;

  // Rate limiting pour les requêtes OTP
  DateTime? _lastOtpRequestTime;

  // Stream pour notifier les changements d'état d'authentification
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;

  // Stream pour notifier les changements d'utilisateur
  final _userController = StreamController<Map<String, dynamic>?>.broadcast();
  Stream<Map<String, dynamic>?> get userStream => _userController.stream;

  // État actuel
  AuthState _currentState = AuthState.initial;
  Map<String, dynamic>? _currentUser;
  String? _currentToken;

  AuthService(this._storage, this._dioClient) {
    _initializeAuth();
  }

  /// Initialise l'authentification au démarrage
  Future<void> _initializeAuth() async {
    _setState(AuthState.loading);

    try {
      final token = await _storage.getSecurely(AppConstants.authTokenKey);

      if (token != null && token.isNotEmpty) {
        // Valider le token
        final isValid = await validateToken(token);
        if (isValid) {
          _currentToken = token;
          await _loadUserProfile();
          _setState(AuthState.authenticated);
        } else {
          await logout();
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation de l\'authentification', error: e);
      _setState(AuthState.unauthenticated);
    }
  }

  /// Demande d'OTP pour un numéro de passeport
  Future<AuthResult> requestOtp(String passportNo) async {
    if (_lastOtpRequestTime != null &&
        DateTime.now().difference(_lastOtpRequestTime!) < const Duration(seconds: 60)) {
      return AuthResult(
        success: false,
        message: 'Veuillez patienter avant de renvoyer un code OTP',
      );
    }

    _setState(AuthState.loading);

    try {
      final response = await _dioClient.post(
        '/api/auth/passport/login',
        data: {'passportNo': passportNo},
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);

        if (result.success) {
          _lastOtpRequestTime = DateTime.now();
          _setState(AuthState.otpSent);
          // Stocker temporairement le numéro de passeport
          await _storage.storeSecurely(AppConstants.passportNoKey, passportNo);
        } else {
          _setState(AuthState.error);
        }

        return result;
      } else {
        _setState(AuthState.error);
        return AuthResult(
          success: false,
          message: 'Erreur lors de l\'envoi du code OTP',
        );
      }
    } on DioException catch (e) {
      _setState(AuthState.error);
      
      AppLogger.error('DioException dans requestOtp: statusCode=${e.response?.statusCode}, data=${e.response?.data}');
      AppLogger.error('DioException type: ${e.type}, message: ${e.message}');
      
      // Vérifier si c'est une erreur de connexion
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AuthResult(
          success: false,
          message: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        );
      }
      
      // Retourner un AuthResult spécial pour passeport non trouvé
      if (e.response?.statusCode == 404) {
        String errorMessage = 'Vous n\'êtes pas inscrit. Rapprochez-vous de votre agence ou contactez-nous.';
        
        // Extraire le message du backend si disponible
        if (e.response?.data != null) {
          try {
            final responseData = e.response!.data;
            AppLogger.info('Type de responseData: ${responseData.runtimeType}');
            AppLogger.info('Contenu responseData: $responseData');
            
            if (responseData is Map<String, dynamic> && responseData['message'] != null) {
              // Utiliser notre message personnalisé au lieu du message backend
              errorMessage = 'Vous n\'êtes pas inscrit. Rapprochez-vous de votre agence ou contactez-nous.';
              AppLogger.info('Message personnalisé utilisé: $errorMessage');
            } else if (responseData is String) {
              // Si la réponse est une chaîne JSON, la parser
              final jsonData = json.decode(responseData);
              if (jsonData['message'] != null) {
                errorMessage = 'Vous n\'êtes pas inscrit. Rapprochez-vous de votre agence ou contactez-nous.';
                AppLogger.info('Message personnalisé utilisé (String JSON): $errorMessage');
              }
            }
          } catch (parseError) {
            // Garder le message par défaut si le parsing échoue
            AppLogger.warning('Erreur parsing réponse 404: $parseError');
          }
        }
        
        AppLogger.info('Message final pour 404: $errorMessage');
        return AuthResult.passportNotFound(errorMessage);
      } else if (e.response?.statusCode == 400) {
        String errorMessage = 'Numéro de passeport invalide';
        
        // Extraire le message du backend si disponible
        if (e.response?.data != null) {
          try {
            final responseData = e.response!.data;
            if (responseData is Map<String, dynamic> && responseData['message'] != null) {
              errorMessage = responseData['message'];
            } else if (responseData is String) {
              final jsonData = json.decode(responseData);
              if (jsonData['message'] != null) {
                errorMessage = jsonData['message'];
              }
            }
          } catch (parseError) {
            AppLogger.warning('Erreur parsing réponse 400: $parseError');
          }
        }
        
        return AuthResult(
          success: false,
          message: errorMessage,
        );
      }
      
      // Pour les autres codes d'erreur ou si pas de réponse
      String errorMessage = 'Erreur de connexion';
      if (e.response?.statusCode != null) {
        errorMessage = 'Erreur serveur (${e.response!.statusCode})';
      }
      
      return AuthResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      _setState(AuthState.error);
      AppLogger.error('Exception générale dans requestOtp: $e');
      
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue',
      );
    }
  }

  /// Vérification du code OTP
  Future<AuthResult> verifyOtp(String passportNo, String otpCode) async {
    _setState(AuthState.loading);

    try {
      final response = await _dioClient.post(
        '/api/auth/passport/verify',
        data: {
          'passportNo': passportNo,
          'otpCode': otpCode,
        },
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);

        if (result.success && result.token != null) {
          // Stocker le token
          await _storage.storeSecurely(
              AppConstants.authTokenKey, result.token!);
          _currentToken = result.token;

          // Charger le profil utilisateur
          await _loadUserProfile();

          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.error);
        }

        return result;
      } else {
        _setState(AuthState.error);
        return AuthResult(
          success: false,
          message: 'Code de vérification invalide',
        );
      }
    } catch (e) {
      _setState(AuthState.error);
      AppLogger.error('Erreur lors de la vérification OTP', error: e);
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue lors de la vérification',
      );
    }
  }

  /// Valide un token existant
  Future<bool> validateToken([String? token]) async {
    try {
      final tokenToValidate = token ?? _currentToken;
      if (tokenToValidate == null) return false;

      // Vérifier l'expiration locale d'abord
      if (TokenValidator.isTokenExpired(tokenToValidate)) {
        AppLogger.warning('Token expiré localement');
        await logout();
        return false;
      }

      final response = await _dioClient.post(
        '/api/auth/passport/validate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tokenToValidate',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);
        return result.success;
      }

      return false;
    } catch (e) {
      AppLogger.error('Erreur validation token', error: e);
      return false;
    }
  }

  /// Renvoie un nouveau code OTP
  Future<AuthResult> resendOtp(String passportNo) async {
    if (_lastOtpRequestTime != null &&
        DateTime.now().difference(_lastOtpRequestTime!) < const Duration(seconds: 60)) {
      return AuthResult(
        success: false,
        message: 'Veuillez patienter avant de renvoyer un code OTP',
      );
    }

    _setState(AuthState.loading);

    try {
      final response = await _dioClient.post(
        '/api/auth/passport/resend',
        data: {'passportNo': passportNo},
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);

        if (result.success) {
          _lastOtpRequestTime = DateTime.now();
          _setState(AuthState.otpSent);
        } else {
          _setState(AuthState.error);
        }

        return result;
      } else {
        _setState(AuthState.error);
        return AuthResult(
          success: false,
          message: 'Erreur lors du renvoi du code',
        );
      }
    } catch (e) {
      _setState(AuthState.error);
      AppLogger.error('Erreur lors du renvoi OTP', error: e);
      return AuthResult(
        success: false,
        message: 'Une erreur est survenue lors du renvoi du code',
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final token = await _storage.getSecurely(AppConstants.authTokenKey);

      if (token != null) {
        // Appeler l'endpoint de déconnexion
        await _dioClient.post(
          '/api/auth/passport/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Erreur déconnexion', error: e);
    } finally {
      // Nettoyer les données locales
      await _storage.deleteSecurely(AppConstants.authTokenKey);
      await _storage.deleteSecurely(AppConstants.userIdKey);
      await _storage.deleteSecurely(AppConstants.passportNoKey);
      await _storage.deleteSecurely(AppConstants.userProfileKey);

      _currentToken = null;
      _currentUser = null;
      _userController.add(null);
      _setState(AuthState.unauthenticated);
    }
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    if (_currentState == AuthState.authenticated && _currentToken != null) {
      return true;
    }

    final token = await _storage.getSecurely(AppConstants.authTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Récupère l'utilisateur courant
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    await _loadUserProfile();
    return _currentUser;
  }

  /// Récupère le token courant
  Future<String?> getCurrentToken() async {
    if (_currentToken != null) {
      return _currentToken;
    }

    _currentToken = await _storage.getSecurely(AppConstants.authTokenKey);
    return _currentToken;
  }

  /// Récupère l'ID de l'utilisateur courant
  Future<String?> getCurrentUserId() async {
    if (_currentUser != null && _currentUser!['id'] != null) {
      return _currentUser!['id'].toString();
    }

    return await _storage.getSecurely(AppConstants.userIdKey);
  }

  /// Charge le profil utilisateur depuis le storage ou l'API
  Future<void> _loadUserProfile() async {
    try {
      // D'abord essayer de charger depuis le storage
      final cachedProfile = await _storage.getSecurely(AppConstants.userProfileKey);

      if (cachedProfile != null) {
        _currentUser = json.decode(cachedProfile);
        _userController.add(_currentUser);

        // Stocker l'ID utilisateur
        if (_currentUser!['id'] != null) {
          await _storage.storeSecurely(
            AppConstants.userIdKey,
            _currentUser!['id'].toString(),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement du profil', error: e);
    }
  }

  /// Met à jour l'état d'authentification
  void _setState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }

  /// État d'authentification actuel
  AuthState get currentState => _currentState;

  /// Dispose les ressources
  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}
