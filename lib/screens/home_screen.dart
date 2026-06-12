import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_item.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showCommentsSheet(BuildContext context, Post post) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<AppState>(
              builder: (context, appState, child) {
                // Find refreshed post in app state to observe real-time comment updates
                final currentPost = appState.posts.firstWhere((p) => p.id == post.id, orElse: () => post);
                final comments = currentPost.comments;

                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border.all(color: borderCol, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: borderCol,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Comments Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments (${currentPost.commentsCount})',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x),
                              onPressed: () => Navigator.pop(context),
                              iconSize: 20,
                            )
                          ],
                        ),
                      ),
                      Divider(color: borderCol, height: 1),
                      
                      // Comments list
                      Expanded(
                        child: comments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.messageSquare,
                                      size: 36,
                                      color: textSecondary.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(color: textSecondary, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Be the first to share your thoughts!',
                                      style: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontSize: 11),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return CommentItem(comment: comments[index]);
                                },
                              ),
                      ),
                      
                      Divider(color: borderCol, height: 1),
                      
                      // Comment Input Row
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 10,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                        ),
                        child: Row(
                          children: [
                            // User initials avatar placeholder
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                appState.currentUser.avatarUrl,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Text Input field
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderCol),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: TextField(
                                  controller: textController,
                                  style: TextStyle(color: textPrimary, fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Send button
                            GestureDetector(
                              onTap: () {
                                final text = textController.text;
                                if (text.trim().isNotEmpty) {
                                  appState.addComment(post.id, text);
                                  textController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.send,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Minimal Devs logo branding
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Devs',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Theme toggler action (Light / Dark mode swap)
          Consumer<AppState>(
            builder: (context, appState, child) {
              return IconButton(
                icon: Icon(
                  appState.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                  size: 20,
                ),
                onPressed: () => appState.toggleTheme(),
              );
            },
          ),
          
          // Activity bell notification page access
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final postsList = appState.posts;

          if (postsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 48,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No posts in feed',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: postsList.length,
            itemBuilder: (context, index) {
              final post = postsList[index];
              return PostCard(
                post: post,
                onLikeTap: () => appState.toggleLike(post.id),
                onSaveTap: () {
                  appState.toggleSave(post.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        post.isSaved ? 'Post removed from saves' : 'Post saved successfully!',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      backgroundColor: AppTheme.primaryBlue,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                onCommentTap: () => _showCommentsSheet(context, post),
                onShareTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied share link for @${post.authorUsername}\'s post!', style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppTheme.primaryBlue,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                onFollowTap: () {
                  appState.toggleFollowUser(post.authorUsername);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You followed @${post.authorUsername}', style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppTheme.primaryBlue,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
