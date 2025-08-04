// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepositoryModel _$RepositoryModelFromJson(Map<String, dynamic> json) =>
    RepositoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String,
      stargazersCount: (json['stargazers_count'] as num).toInt(),
      forksCount: (json['forks_count'] as num).toInt(),
      language: json['language'] as String?,
      owner: OwnerModel.fromJson(json['owner'] as Map<String, dynamic>),
      updatedAt: json['updated_at'] as String?,
      isPrivate: json['private'] as bool,
      defaultBranch: json['default_branch'] as String?,
    );

Map<String, dynamic> _$RepositoryModelToJson(RepositoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'full_name': instance.fullName,
      'description': instance.description,
      'html_url': instance.htmlUrl,
      'stargazers_count': instance.stargazersCount,
      'forks_count': instance.forksCount,
      'language': instance.language,
      'owner': instance.owner,
      'updated_at': instance.updatedAt,
      'private': instance.isPrivate,
      'default_branch': instance.defaultBranch,
    };

OwnerModel _$OwnerModelFromJson(Map<String, dynamic> json) => OwnerModel(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$OwnerModelToJson(OwnerModel instance) =>
    <String, dynamic>{
      'login': instance.login,
      'avatar_url': instance.avatarUrl,
    };
