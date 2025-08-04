import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/search_response_model.dart';

abstract class GitHubRemoteDataSource {
  Future<SearchResponseModel> searchRepositories({
    required String query,
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  });
}

class GitHubRemoteDataSourceImpl implements GitHubRemoteDataSource {
  final http.Client client;

  GitHubRemoteDataSourceImpl({required this.client});

  @override
  Future<SearchResponseModel> searchRepositories({
    required String query,
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    // 빈 쿼리 검증
    if (query.trim().isEmpty) {
      throw const GitHubApiException('검색어를 입력해주세요.');
    }

    // URL 파라미터 구성
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchRepositories}')
        .replace(queryParameters: {
      'q': query.trim(),
      'page': page.toString(),
      'per_page': perPage.clamp(1, ApiConstants.maxPerPage).toString(),
      'sort': 'stars',
      'order': 'desc',
    });

    try {
      // HTTP 요청 실행
      final response = await client
          .get(
        uri,
        headers: ApiConstants.headers,
      )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('인터넷 연결을 확인해주세요.');
    } on HttpException catch (e) {
      throw NetworkException('네트워크 오류가 발생했습니다: ${e.message}');
    } on FormatException catch (e) {
      throw GitHubApiException('응답 데이터 형식이 올바르지 않습니다: ${e.message}');
    } catch (e) {
      throw GitHubApiException('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  /// HTTP 응답 처리
  SearchResponseModel _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // 성공 응답 (200)
    if (statusCode == 200) {
      try {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return SearchResponseModel.fromJson(jsonData);
      } catch (e) {
        throw GitHubApiException('응답 파싱 중 오류가 발생했습니다: $e', statusCode);
      }
    }

    // 에러 응답 처리
    String errorMessage;
    Map<String, dynamic>? errorData;

    try {
      errorData = json.decode(response.body) as Map<String, dynamic>;
      errorMessage = errorData['message'] ?? _getDefaultErrorMessage(statusCode);
    } catch (e) {
      errorMessage = _getDefaultErrorMessage(statusCode);
    }

    // Rate Limiting (403)
    if (statusCode == 403) {
      final resetHeader = response.headers['x-ratelimit-reset'];
      DateTime? resetTime;
      if (resetHeader != null) {
        final resetTimestamp = int.tryParse(resetHeader);
        if (resetTimestamp != null) {
          resetTime = DateTime.fromMillisecondsSinceEpoch(resetTimestamp * 1000);
        }
      }
      throw RateLimitException(errorMessage, statusCode, errorData, resetTime);
    }

    // 기타 GitHub API 에러
    throw GitHubApiException(errorMessage, statusCode, errorData);
  }

  /// 상태 코드별 기본 에러 메시지
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다.';
      case 403:
        return 'API 사용량 한도를 초과했습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 422:
        return '검색어가 올바르지 않습니다.';
      case 500:
        return '서버 내부 오류가 발생했습니다.';
      case 502:
        return '서버가 응답하지 않습니다.';
      case 503:
        return '서비스를 사용할 수 없습니다.';
      default:
        return 'HTTP $statusCode 오류가 발생했습니다.';
    }
  }
}