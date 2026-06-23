import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../utils/link_utils.dart';

class ProfileLinkTile extends StatelessWidget {
  final ProfileLink link;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProfileLinkTile({
    super.key,
    required this.link,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final faviconUrl = getFaviconUrl(link.url);
    final displayTitle = link.platform.isNotEmpty ? link.platform : getDomainName(link.url);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // CircleAvatar containing favicon image
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 18,
            child: ClipOval(
              child: Image.network(
                faviconUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.language,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    link.url,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 14,
                color: Colors.red.shade200,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
