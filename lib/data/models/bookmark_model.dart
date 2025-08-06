import 'package:hive/hive.dart';
import '../../domain/entities/repository_entity.dart';

part 'bookmark_model.g.dart';

/// 북마크 저장을 위한 Hive 모델
@HiveType(typeId: 0)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String htmlUrl;

  @HiveField(5)
  final int stargazersCount;

  @HiveField(6)
  final int forksCount;

  @HiveField(7)
  final String? language;

  @HiveField(8)
  final String? avatarUrl;

  @HiveField(9)
  final String ownerLogin;

  @HiveField(10)
  final DateTime? updatedAt;

  @HiveField(11)
  final bool isPrivate;

  @HiveField(12)
  final String? defaultBranch;

  @HiveField(13)
  final DateTime bookmarkedAt; // 북마크 추가 시간

  BookmarkModel({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    required this.stargazersCount,
    required this.forksCount,
    this.language,
    this.avatarUrl,
    required this.ownerLogin,
    this.updatedAt,
    required this.isPrivate,
    this.defaultBranch,
    required this.bookmarkedAt,
  });

  /// RepositoryEntity에서 BookmarkModel 생성
  factory BookmarkModel.fromEntity(RepositoryEntity entity) {
    return BookmarkModel(
      id: entity.id,
      name: entity.name,
      fullName: entity.fullName,
      description: entity.description,
      htmlUrl: entity.htmlUrl,
      stargazersCount: entity.stargazersCount,
      forksCount: entity.forksCount,
      language: entity.language,
      avatarUrl: entity.avatarUrl,
      ownerLogin: entity.ownerLogin,
      updatedAt: entity.updatedAt,
      isPrivate: entity.isPrivate,
      defaultBranch: entity.defaultBranch,
      bookmarkedAt: entity.bookmarkedAt ?? DateTime.now(),
    );
  }

  /// BookmarkModel을 RepositoryEntity로 변환
  RepositoryEntity toEntity() {
    return RepositoryEntity(
      id: id,
      name: name,
      fullName: fullName,
      description: description,
      htmlUrl: htmlUrl,
      stargazersCount: stargazersCount,
      forksCount: forksCount,
      language: language,
      avatarUrl: avatarUrl,
      ownerLogin: ownerLogin,
      updatedAt: updatedAt,
      isPrivate: isPrivate,
      defaultBranch: defaultBranch,
      bookmarkedAt: bookmarkedAt,
    );
  }

  @override
  String toString() {
    return 'BookmarkModel{id: $id, name: $name, bookmarkedAt: $bookmarkedAt}';
  }
}