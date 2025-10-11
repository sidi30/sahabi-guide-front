import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/constants.dart';
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

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'],
    );
  }
}

/// Service d'authentification gérant le flux Passeport + OTP
class AuthService {
  final StorageService _storage;
  final DioClient _dioClient;

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
      print('Erreur lors de l\'initialisation de l\'authentification: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  /// Demande d'OTP pour un numéro de passeport
  Future<AuthResult> requestOtp(String passportNo) async {
    _setState(AuthState.loading);

    try {
      final response = await _dioClient.post(
        '/api/auth/passport/login',
        data: {'passportNo': passportNo},
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);
        
        if (result.success) {
          _setState(AuthState.otpSent);
          // Stocker temporairement le numéro de passeport
          await _storage.store(AppConstants.passportNoKey, passportNo);
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
    } catch (e) {
      _setState(AuthState.error);
      return AuthResult(
        success: false,
        message: 'Erreur de connexion: ${e.toString()}',
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
          await _storage.storeSecurely(AppConstants.authTokenKey, result.token!);
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
      return AuthResult(
        success: false,
        message: 'Erreur lors de la vérification: ${e.toString()}',
      );
    }
  }

  /// Valide un token existant
  Future<bool> validateToken([String? token]) async {
    try {
      final tokenToValidate = token ?? _currentToken;
      if (tokenToValidate == null) return false;

      final response = await _dioClient.post(
        '/api/auth/passport/validate',
        data: {'token': tokenToValidate},
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);
        return result.success;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la validation du token: $e');
      return false;
    }
  }

  /// Renvoie un nouveau code OTP
  Future<AuthResult> resendOtp(String passportNo) async {
    _setState(AuthState.loading);

    try {
      final response = await _dioClient.post(
        '/api/auth/passport/resend',
        data: {'passportNo': passportNo},
      );

      if (response.statusCode == 200) {
        final result = AuthResult.fromJson(response.data);
        
        if (result.success) {
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
      return AuthResult(
        success: false,
        message: 'Erreur de connexion: ${e.toString()}',
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
      print('Erreur lors de la déconnexion: $e');
    } finally {
      // Nettoyer les données locales
      await _storage.deleteSecurely(AppConstants.authTokenKey);
      await _storage.remove(AppConstants.userIdKey);
      await _storage.remove(AppConstants.passportNoKey);
      await _storage.remove(AppConstants.userProfileKey);
      
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
    
    return await _storage.get(AppConstants.userIdKey);
  }

  /// Charge le profil utilisateur depuis le storage ou l'API
  Future<void> _loadUserProfile() async {
    try {
      // D'abord essayer de charger depuis le storage
      final cachedProfile = await _storage.get(AppConstants.userProfileKey);
      
      if (cachedProfile != null) {
        _currentUser = json.decode(cachedProfile);
        _userController.add(_currentUser);
        
        // Stocker l'ID utilisateur
        if (_currentUser!['id'] != null) {
          await _storage.store(
            AppConstants.userIdKey,
            _currentUser!['id'].toString(),
          );
        }
      }
      
      // TODO: Charger le profil depuis l'API si nécessaire
      // final token = await getCurrentToken();
      // if (token != null) {
      //   final response = await _dioClient.get(
      //     '/api/auth/profile',
      //     options: Options(headers: {'Authorization': 'Bearer $token'}),
      //   );
      //   // Mettre à jour le profil
      // }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
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

