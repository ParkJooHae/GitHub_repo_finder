class ApiConstants {

  static const String baseUrl = 'https://api.github.com';

  static const String searchRepositories = '/search/repositories';

  static const int defaultPerPage = 30;
  static const int maxPerPage = 100;

  static const Map<String, String> headers = {
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  static const Duration requestTimeout = Duration(seconds: 10);
}