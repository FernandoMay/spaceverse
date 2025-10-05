// lib/core/errors/exceptions.dart
import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});

  factory ServerException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('Request timeout', code: 'TIMEOUT');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        return ServerException(
          message,
          code: statusCode?.toString(),
          details: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ServerException('Request cancelled', code: 'CANCELLED');
      case DioExceptionType.connectionError:
        return ServerException('No internet connection', code: 'NO_INTERNET');
      case DioExceptionType.badCertificate:
        return ServerException('Invalid SSL certificate', code: 'BAD_CERTIFICATE');
      case DioExceptionType.unknown:
        return ServerException('Unknown error occurred', code: 'UNKNOWN');
    }
  }
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code, super.details});
}

class AuthorizationException extends AppException {
  AuthorizationException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class BlockchainException extends AppException {
  BlockchainException(super.message, {super.code, super.details});
}

class MLException extends AppException {
  MLException(super.message, {super.code, super.details});
}

class ARException extends AppException {
  ARException(super.message, {super.code, super.details});
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.details});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.details});
}

class SocialException extends AppException {
  SocialException(super.message, {super.code, super.details});
}