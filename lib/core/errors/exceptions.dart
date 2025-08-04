// Base Exception
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// 네트워트 예외처리
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, [this.statusCode, super.code]);

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// api 예외처리
class GitHubApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? errorData;

  const GitHubApiException(
      super.message,
      [this.statusCode, this.errorData, super.code]
      );
}

// Rate Limiting Exception
class RateLimitException extends GitHubApiException {
  final DateTime? resetTime;

  const RateLimitException(
      super.message,
      [super.statusCode,
        super.errorData,
        this.resetTime,
        super.code]
      );
}

// Local Database Exceptions
class LocalDatabaseException extends AppException {
  const LocalDatabaseException(super.message, [super.code]);
}

// Cache Exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}