/// Base exception for server errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception when a resource is not found
class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception for authentication/authorization issues
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({required this.message});

  @override
  String toString() => 'UnauthorizedException: $message';
}
