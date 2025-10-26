import 'package:dio/dio.dart';
import '../utils/constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient(Dio dio) {
    _dio = dio;
    _dio.options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));

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
        onError: (error, handler) {
          // Ne pas traiter l'erreur ici, laisser les couches supérieures gérer
          // _handleError(error);
          handler.next(error);
        },
      ),
    );
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
    // This would typically get the token from secure storage
    // For now, we'll return null - this should be implemented with proper token management
    return null;
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Timeout de connexion');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          throw Exception('Non autorisé');
        } else if (statusCode == 403) {
          throw Exception('Accès interdit');
        } else if (statusCode == 404) {
          throw Exception('Ressource non trouvée');
        } else if (statusCode == 500) {
          throw Exception('Erreur serveur');
        } else {
          throw Exception('Erreur HTTP: $statusCode');
        }
      case DioExceptionType.cancel:
        throw Exception('Requête annulée');
      case DioExceptionType.connectionError:
        throw Exception('Erreur de connexion');
      case DioExceptionType.badCertificate:
        throw Exception('Certificat invalide');
      case DioExceptionType.unknown:
      default:
        throw Exception('Erreur inconnue: ${error.message}');
    }
  }
}
