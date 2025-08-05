import 'package:json_annotation/json_annotation.dart';
import 'repository_model.dart';

part 'search_response_model.g.dart';

/// GitHub 검색 API 응답 모델
///
/// GitHub API의 /search/repositories 엔드포인트 응답을 파싱
@JsonSerializable()
class SearchResponseModel {
  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'incomplete_results')
  final bool incompleteResults;
  final List<RepositoryModel> items;

  const SearchResponseModel({
    required this.totalCount,
    required this.incompleteResults,
    required this.items,
  });

  /// JSON에서 SearchResponseModel 생성 (자동 생성)
  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);

  /// SearchResponseModel을 JSON으로 변환 (자동 생성)
  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);

  /// 결과가 비어있는지 확인
  bool get isEmpty => items.isEmpty;

  /// 결과가 있는지 확인
  bool get isNotEmpty => items.isNotEmpty;

  /// 페이지네이션 정보 계산
  bool hasMorePages(int currentPage, int perPage) {
    final expectedItems = currentPage * perPage;
    return totalCount > expectedItems;
  }
}