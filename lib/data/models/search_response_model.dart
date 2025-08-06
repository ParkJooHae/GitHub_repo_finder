import 'package:json_annotation/json_annotation.dart';
import 'repository_model.dart';

part 'search_response_model.g.dart';

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

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool hasMorePages(int currentPage, int perPage) {
    final expectedItems = currentPage * perPage;
    return totalCount > expectedItems;
  }
}