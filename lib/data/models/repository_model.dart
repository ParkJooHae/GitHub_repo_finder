import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/repository_entity.dart';

part 'repository_model.g.dart';

@JsonSerializable()
class RepositoryModel {
  final int id;
  final String name;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? description;
  @JsonKey(name: 'html_url')
  final String htmlUrl;
  @JsonKey(name: 'stargazers_count')
  final int stargazersCount;
  @JsonKey(name: 'forks_count')
  final int forksCount;
  final String? language;
  final OwnerModel owner;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'private')
  final bool isPrivate;
  @JsonKey(name: 'default_branch')
  final String? defaultBranch;

  const RepositoryModel({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    required this.stargazersCount,
    required this.forksCount,
    this.language,
    required this.owner,
    this.updatedAt,
    required this.isPrivate,
    this.defaultBranch,
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) =>
      _$RepositoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryModelToJson(this);

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
      avatarUrl: owner.avatarUrl,
      ownerLogin: owner.login,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      isPrivate: isPrivate,
      defaultBranch: defaultBranch,
    );
  }

  factory RepositoryModel.fromEntity(RepositoryEntity entity) {
    return RepositoryModel(
      id: entity.id,
      name: entity.name,
      fullName: entity.fullName,
      description: entity.description,
      htmlUrl: entity.htmlUrl,
      stargazersCount: entity.stargazersCount,
      forksCount: entity.forksCount,
      language: entity.language,
      owner: OwnerModel(
        login: entity.ownerLogin,
        avatarUrl: entity.avatarUrl,
      ),
      updatedAt: entity.updatedAt?.toIso8601String(),
      isPrivate: entity.isPrivate,
      defaultBranch: entity.defaultBranch,
    );
  }
}

@JsonSerializable()
class OwnerModel {
  final String login;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const OwnerModel({
    required this.login,
    this.avatarUrl,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) =>
      _$OwnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerModelToJson(this);
}