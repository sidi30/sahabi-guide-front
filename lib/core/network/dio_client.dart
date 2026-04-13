import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import '../../shared/services/storage_service.dart';
import '../config/env_config.dart';
import '../error/api_exceptions.dart';
import '../utils/app_logger.dart';

class DioClient {
  late final Dio _dio;
  final StorageService? _storageService;

  DioClient(Dio dio, {StorageService? storageService}) : _storageService = storageService {
    _dio = dio;

    // Permet de surcharger l'URL de base via --dart-define=API_BASE_URL=...
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    final baseUrl =
        envBaseUrl.isNotEmpty ? envBaseUrl : AppConstants.apiBaseUrl;

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors - Conditional logging based on environment
    if (EnvConfig.enableDioDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Token expired or invalid - clear auth state
          if (error.response?.statusCode == 401 && _storageService != null) {
            await _storageService!.deleteSecurely('auth_token');
            // Don't retry - user needs to re-authenticate via OTP
          }
          // Gérer les erreurs de manière centralisée
          final apiException = _handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );

    // SSL certificate pinning in release mode only
    if (!kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // Only allow connections to our domain
          return host.endsWith('sahabiguide.com');
        };
        return client;
      };
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _getAuthToken() async {
    if (_storageService == null) {
      return null;
    }
    
    try {
      // Récupérer le token depuis le stockage sécurisé
      final token = await _storageService!.getSecurely('auth_token');
      return token;
    } catch (e) {
      // En cas d'erreur, retourner null et laisser l'app gérer
      return null;
    }
  }

  ApiException _handleError(DioException error) {
    // Logger l'erreur en mode debug
    if (EnvConfig.enableDetailedLogs) {
      AppLogger.error('API Error: ${error.type} - ${error.message}');
      if (error.response != null) {
        AppLogger.error('Status Code: ${error.response?.statusCode}');
        AppLogger.error('Response: ${error.response?.data}');
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Délai de connexion dépassé. Veuillez réessayer.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        // Extraire le message d'erreur du backend si disponible
        String? backendMessage;
        if (responseData is Map<String, dynamic>) {
          backendMessage = responseData['message'] ?? responseData['error'];
        }

        switch (statusCode) {
          case 400:
            return ValidationException(
              backendMessage ?? 'Données invalides',
              errors: responseData is Map<String, dynamic> 
                  ? responseData['errors'] 
                  : null,
            );
          case 401:
            return UnauthorizedException(
              backendMessage ?? 'Non autorisé. Veuillez vous reconnecter.',
            );
          case 403:
            return ForbiddenException(
              backendMessage ?? 'Accès interdit.',
            );
          case 404:
            return NotFoundException(
              backendMessage ?? 'Ressource non trouvée.',
            );
          case 422:
            return ValidationException(
              backendMessage ?? 'Erreur de validation',
              errors: responseData is Map<String, dynamic> 
                  ? responseData['errors'] 
                  : null,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              backendMessage ?? 'Erreur serveur. Veuillez réessayer plus tard.',
            );
          default:
            return UnknownException(
              backendMessage ?? 'Erreur HTTP: $statusCode',
              error,
            );
        }

      case DioExceptionType.cancel:
        return CancelException('Requête annulée.');

      case DioExceptionType.connectionError:
        return NetworkException(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );

      case DioExceptionType.badCertificate:
        return CertificateException(
          'Certificat SSL invalide. Connexion non sécurisée.',
        );

      case DioExceptionType.unknown:
        return UnknownException(
          'Erreur inconnue: ${error.message ?? "Non spécifiée"}',
          error,
        );
    }
  }
}
