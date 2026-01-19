import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env_config.dart';
import '../error/exceptions.dart';

part 'dio_client.g.dart';

/// Notion API base URL
const String _notionBaseUrl = 'https://api.notion.com/v1';

/// Notion API version
const String _notionVersion = '2022-06-28';

/// Provider for Dio client configured for Notion API
@riverpod
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _notionBaseUrl,
      headers: {
        'Authorization': 'Bearer ${EnvConfig.notionApiKey}',
        'Notion-Version': _notionVersion,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: exception,
            type: error.type,
            response: error.response,
          ),
        );
      },
    ),
  );

  return dio;
}

Exception _handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException(
        message: 'Tiempo de conexión agotado. Verifica tu conexión a internet.',
      );
    case DioExceptionType.connectionError:
      return const NetworkException(
        message: 'Error de conexión. Verifica tu conexión a internet.',
      );
    case DioExceptionType.badResponse:
      return _handleBadResponse(error.response);
    case DioExceptionType.cancel:
      return const NetworkException(message: 'Petición cancelada.');
    default:
      return ServerException(
        message: error.message ?? 'Error desconocido',
      );
  }
}

Exception _handleBadResponse(Response? response) {
  final statusCode = response?.statusCode;
  final data = response?.data;

  String message = 'Error del servidor';
  if (data is Map<String, dynamic>) {
    message = data['message'] as String? ?? message;
  }

  switch (statusCode) {
    case 400:
      return ServerException(message: message, statusCode: statusCode);
    case 401:
      return const UnauthorizedException(
        message: 'API Key de Notion inválida o no autorizada.',
      );
    case 403:
      return const UnauthorizedException(
        message: 'No tienes permisos para acceder a este recurso.',
      );
    case 404:
      return const NotFoundException(
        message: 'Recurso no encontrado en Notion.',
      );
    case 429:
      return const ServerException(
        message: 'Demasiadas peticiones. Intenta de nuevo en unos segundos.',
        statusCode: 429,
      );
    default:
      return ServerException(message: message, statusCode: statusCode);
  }
}
