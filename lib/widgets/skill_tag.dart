import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class SkillTag extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final bool showDelete;
  final VoidCallback? onDelete;

  const SkillTag({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bg;
    Color borderCol;
    Color textCol;

    if (isActive) {
      bg = AppTheme.primaryBlue.withValues(alpha: 0.12);
      borderCol = AppTheme.primaryBlue;
      textCol = AppTheme.primaryBlue;
    } else {
      bg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
      borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
      textCol = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderCol, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textCol,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (showDelete) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  LucideIcons.x,
                  size: 14,
                  color: textCol.withValues(alpha: 0.7),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
