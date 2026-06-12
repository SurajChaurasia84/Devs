import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import 'skill_tag.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onGithubTap;
  final VoidCallback? onDemoTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onGithubTap,
    this.onDemoTap,
  });

  // Custom schematic browser/IDE mock layout to showcase project visual content
  Widget _buildProjectPreview(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F0F0);
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: borderCol, width: 1)),
      ),
      child: Stack(
        children: [
          // Browser UI schematic
          Positioned(
            top: 8,
            left: 10,
            right: 10,
            child: Row(
              children: [
                // 3 small dots
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 3),
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 3),
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                // URL bar
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181818) : const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.lock, size: 7, color: AppTheme.primaryBlue),
                        const SizedBox(width: 3),
                        Text(
                          '${project.id}.devs.app/preview',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 7,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code visual placeholder lines representing repository code/design
          Positioned(
            left: 15,
            top: 36,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code structures
                Row(
                  children: [
                    Container(width: 24, height: 6, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Container(width: 50, height: 6, decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(width: 14, height: 6, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Container(width: 70, height: 6, decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Container(width: 30, height: 6, decoration: BoxDecoration(color: textPrimary.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Container(width: 20, height: 6, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ],
            ),
          ),
          // Brand badge overlay
          Positioned(
            right: 12,
            bottom: 8,
            child: Icon(
              Iconsax.code,
              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
              size: 28,
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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Project image/mock screenshot
          _buildProjectPreview(context, isDark),
          
          // Project information content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Tech Stack Wrap
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.techStack.map((tech) => SkillTag(label: tech)).toList(),
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    // GitHub Link (Outlined)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGithubTap ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening GitHub repository for ${project.title}...', style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppTheme.primaryBlue,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.github, size: 14),
                        label: const Text('GitHub', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: borderCol),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Live Demo (Filled Blue)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDemoTap ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Launching live demo for ${project.title}...', style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppTheme.primaryBlue,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.export, size: 14),
                        label: const Text('Demo', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
