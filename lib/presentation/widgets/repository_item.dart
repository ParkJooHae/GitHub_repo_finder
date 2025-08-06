import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/repository_entity.dart';

class RepositoryItem extends StatelessWidget {
  final RepositoryEntity repository;
  final Function(RepositoryEntity) onBookmarkToggle;

  const RepositoryItem({
    super.key,
    required this.repository,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showRepositoryDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 아바타
                  _buildOwnerAvatar(),
                  const SizedBox(width: 12),

                  // 저장소 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repository.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          repository.ownerLogin,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 북마크 버튼
                  IconButton(
                    onPressed: () => onBookmarkToggle(repository),
                    icon: Icon(
                      repository.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: repository.isBookmarked
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    tooltip: repository.isBookmarked
                        ? '북마크 제거'
                        : '북마크 추가',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 설명
              if (repository.description != null && repository.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    repository.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // 통계 정보
              Row(
                children: [
                  // 언어
                  if (repository.language != null)
                    _buildLanguageChip(repository.language!),

                  const Spacer(),

                  // 스타 수
                  _buildStatItem(
                    Icons.star_border,
                    _formatNumber(repository.stargazersCount),
                    Colors.amber[700],
                  ),

                  const SizedBox(width: 16),

                  // 포크 수
                  _buildStatItem(
                    Icons.call_split,
                    _formatNumber(repository.forksCount),
                    Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 아바타
  Widget _buildOwnerAvatar() {
    if (repository.avatarUrl != null && repository.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(repository.avatarUrl!),
        onBackgroundImageError: (_, __) {},
        child: const Icon(Icons.person, size: 20),
      );
    } else {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 20),
      );
    }
  }

  /// 언어
  Widget _buildLanguageChip(String language) {
    final color = _getLanguageColor(language);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        language,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(IconData icon, String count, Color? color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    switch (number) {
      case 0: return '0';
      case 1: return '1';
      case 2: return '2';
      case 3: return '3';
      case 4: return '4';
      case 5: return '5';
      case 6: return '6';
      case 7: return '7';
      case 8: return '8';
      case 9: return '9';
      case 10: return '10';
      default:
        if (number < 1000) return number.toString();
        if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
        return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// 언어별 색상
  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF0175C2);
      case 'kotlin':
        return const Color(0xFF7F52FF);
      case 'java':
        return const Color(0xFFED8B00);
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'typescript':
        return const Color(0xFF3178C6);
      case 'python':
        return const Color(0xFF3776AB);
      case 'swift':
        return const Color(0xFFFA7343);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'rust':
        return const Color(0xFF000000);
      case 'c++':
        return const Color(0xFF00599C);
      default:
        return Colors.grey[600]!;
    }
  }

  /// 저장소 상세 정보 다이얼로그
  void _showRepositoryDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(repository.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('소유자: ${repository.ownerLogin}'),
              const SizedBox(height: 8),
              if (repository.description != null)
                Text('설명: ${repository.description}'),
              const SizedBox(height: 8),
              Text('스타: ${_formatNumber(repository.stargazersCount)}'),
              const SizedBox(height: 4),
              Text('포크: ${_formatNumber(repository.forksCount)}'),
              const SizedBox(height: 4),
              if (repository.language != null)
                Text('언어: ${repository.language}'),
              const SizedBox(height: 8),
              Text('URL: ${repository.htmlUrl}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              // URL 복사
              Clipboard.setData(ClipboardData(text: repository.htmlUrl));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL이 클립보드에 복사되었습니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('URL 복사'),
          ),
        ],
      ),
    );
  }
}