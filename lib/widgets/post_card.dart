import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import 'code_highlighter.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onFollowTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLikeTap,
    this.onCommentTap,
    this.onSaveTap,
    this.onShareTap,
    this.onFollowTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _likeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeController.forward();
    if (widget.onLikeTap != null) widget.onLikeTap!();
  }

  // Generate a beautiful mock IDE/Dashboard screenshot layout in pure Flutter code
  Widget _buildScreenshotMockup(BuildContext context, bool isDark) {
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final cardBg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF2F2F2);
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mock IDE Window Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderCol, width: 1)),
            ),
            child: Row(
              children: [
                // 3 window controls
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF555555), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                // Editor File Tab
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    border: Border.all(color: borderCol),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.code_rounded, size: 8, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'dashboard_view.dart',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Mock IDE Workspace layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left File Tree bar
                Container(
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: borderCol, width: 1)),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 15, height: 4, decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.4), borderRadius: BorderRadius.circular(1))),
                      const SizedBox(height: 4),
                      Container(width: 25, height: 4, decoration: BoxDecoration(color: textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(1))),
                      const SizedBox(height: 4),
                      Container(width: 20, height: 4, decoration: BoxDecoration(color: textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(1))),
                      const SizedBox(height: 4),
                      Container(width: 28, height: 4, decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.4), borderRadius: BorderRadius.circular(1))),
                    ],
                  ),
                ),
                
                // Central Grid Board (Simulating a beautiful app dashboard screen)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row 1: App Header bar layout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 32, height: 8, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2))),
                            Container(width: 12, height: 8, decoration: BoxDecoration(color: textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Row 2: Grid card containers
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(3, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: borderCol),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 3,
                                      color: textSecondary.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      width: 22,
                                      height: 6,
                                      color: index == 1 ? AppTheme.primaryBlue : textSecondary.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Window Bottom status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131313) : const Color(0xFFE8E8E8),
              border: Border(top: BorderSide(color: borderCol, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 7, color: AppTheme.primaryBlue),
                    const SizedBox(width: 3),
                    Text(
                      'Ready',
                      style: TextStyle(color: textSecondary, fontSize: 6, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'UTF-8   Dart',
                  style: TextStyle(color: textSecondary, fontSize: 6, fontWeight: FontWeight.bold),
                ),
              ],
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Author Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.post.authorAvatarUrl,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Author Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.authorName,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Post type indicator badge (Twitter-like verification style)
                          if (widget.post.type != 'text')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.post.type.toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '@${widget.post.authorUsername} • ${widget.post.timeAgo}',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Follow simulation button (Hidden for the current user)
                if (widget.post.authorUsername != 'suraj_dev')
                  TextButton(
                    onPressed: widget.onFollowTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: AppTheme.primaryBlue, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Post Text Content
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
            child: Text(
              widget.post.content,
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          
          // Specific post contents by type
          if (widget.post.type == 'code' && widget.post.codeSnippet != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: CodeHighlighter(
                code: widget.post.codeSnippet!,
                language: widget.post.codeLanguage ?? 'dart',
              ),
            )
          else if (widget.post.type == 'project' && widget.post.projectTitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.projectTitle!,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.post.projectDescription ?? '',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                    ),
                  ],
                ),
              ),
            )
          else if (widget.post.type == 'screenshot')
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: _buildScreenshotMockup(context, isDark),
            ),
          
          // Footer Actions Divider
          Divider(color: borderCol, height: 1, thickness: 1),
          
          // Footer Interaction Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like Action
                GestureDetector(
                  onTap: _handleLike,
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _likeScale,
                        child: Icon(
                          widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          size: 18,
                          color: widget.post.isLiked ? AppTheme.primaryBlue : textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.likesCount}',
                        style: TextStyle(
                          color: widget.post.isLiked ? AppTheme.primaryBlue : textSecondary,
                          fontSize: 12,
                          fontWeight: widget.post.isLiked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Comment Action
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 17,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.commentsCount}',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Save Action
                GestureDetector(
                  onTap: widget.onSaveTap,
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        size: 18,
                        color: widget.post.isSaved ? AppTheme.primaryBlue : textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.isSaved ? 'Saved' : 'Save',
                        style: TextStyle(
                          color: widget.post.isSaved ? AppTheme.primaryBlue : textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Share Action
                GestureDetector(
                  onTap: widget.onShareTap,
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
