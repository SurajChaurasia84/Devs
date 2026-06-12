import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onJoinTap;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    this.onJoinTap,
    this.onTap,
  });

  // Custom blueprint pattern background for community covers
  Widget _buildCover(BuildContext context, bool isDark) {
    final gridColor = isDark ? const Color(0xFF151515) : const Color(0xFFE8E8E8);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F2);
    
    // Draw grid patterns
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          // Grid lines
          Positioned.fill(
            child: GridPaper(
              color: gridColor,
              interval: 14,
              subdivisions: 1,
              child: Container(),
            ),
          ),
          // Code bracket symbols decoration
          Positioned(
            right: 12,
            bottom: 4,
            child: Opacity(
              opacity: isDark ? 0.12 : 0.08,
              child: Text(
                '</>',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          // Short label tag
          Positioned(
            left: 12,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DEV GROUP',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);

    // Format member count to K format if > 1000
    String formatMembers(int count) {
      if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}k members';
      }
      return '$count members';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            _buildCover(context, isDark),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          community.name,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Join action button
                      TextButton(
                        onPressed: onJoinTap,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: community.isJoined
                              ? Colors.transparent
                              : AppTheme.primaryBlue,
                          side: community.isJoined
                              ? BorderSide(color: borderCol, width: 1)
                              : BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          community.isJoined ? 'Joined' : 'Join',
                          style: TextStyle(
                            color: community.isJoined ? textSecondary : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Member count
                  Text(
                    formatMembers(community.memberCount),
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    community.description,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
