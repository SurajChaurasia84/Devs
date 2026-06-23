import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class NotificationItem extends StatelessWidget {
  final DevsNotification notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _getIconForType() {
    switch (notification.type) {
      case 'like':
        return LucideIcons.heart;
      case 'comment':
        return LucideIcons.messageSquare;
      case 'follow':
        return LucideIcons.userPlus;
      case 'mention':
        return LucideIcons.atSign;
      default:
        return LucideIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final iconCol = AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderCol, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon indicator
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              _getIconForType(),
              color: iconCol,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // User Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              notification.userAvatarUrl,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: textPrimary, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(
                        text: notification.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' @${notification.userUsername} ',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      TextSpan(text: notification.actionDetails),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Interactive follow back / actions if follow type
          if (notification.type == 'follow')
            TextButton(
              onPressed: () {
                // follow back simulation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Followed back @${notification.userUsername}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryBlue,
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: AppTheme.primaryBlue, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Follow Back',
                style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
