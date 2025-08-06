class RepositoryEntity {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final int stargazersCount;
  final int forksCount;
  final String? language;
  final String? avatarUrl;
  final String ownerLogin;
  final DateTime? updatedAt;
  final bool isPrivate;
  final String? defaultBranch;
  final DateTime? bookmarkedAt;

  const RepositoryEntity({
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
    this.bookmarkedAt,
  });

  RepositoryEntity copyWithBookmark({DateTime? bookmarkedAt}) {
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
      bookmarkedAt: bookmarkedAt ?? DateTime.now(),
    );
  }

  RepositoryEntity copyWithoutBookmark() {
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
      bookmarkedAt: null,
    );
  }

  bool get isBookmarked => bookmarkedAt != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepositoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RepositoryEntity{id: $id, name: $name, fullName: $fullName, stars: $stargazersCount}';
  }
}