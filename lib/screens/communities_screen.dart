import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/community_card.dart';
import '../widgets/post_card.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Communities',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final communities = appState.communities;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return CommunityCard(
                community: community,
                onJoinTap: () => appState.toggleJoinCommunity(community.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityDetailScreen(community: community),
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

class CommunityDetailScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailScreen({
    super.key,
    required this.community,
  });

  // Cover image blueprint for the group header
  Widget _buildDetailCover(BuildContext context, bool isDark) {
    final gridColor = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE5E5E5);
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9);

    return Container(
      height: 120,
      width: double.infinity,
      color: bgColor,
      child: Stack(
        children: [
          // Grid lines
          Positioned.fill(
            child: GridPaper(
              color: gridColor,
              interval: 16,
              subdivisions: 1,
              child: Container(),
            ),
          ),
          // Code overlay
          Positioned(
            right: 20,
            bottom: 10,
            child: Opacity(
              opacity: isDark ? 0.08 : 0.05,
              child: Text(
                'import \'${community.name.toLowerCase()}\';',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          // Close button back arrow
          Positioned(
            left: 8,
            top: 8,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                radius: 18,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  color: isDark ? Colors.white : Colors.black,
                  onPressed: () => Navigator.pop(context),
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

    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Re-fetch community state for real-time join button synchronization
          final currentCommunity = appState.communities.firstWhere((c) => c.id == community.id, orElse: () => community);
          
          // Filter feed posts by community matches (simplified tag-like search)
          final groupPosts = appState.posts.where((post) {
            final content = post.content.toLowerCase();
            final title = post.projectTitle?.toLowerCase() ?? '';
            final snippet = post.codeSnippet?.toLowerCase() ?? '';
            final name = currentCommunity.name.toLowerCase();
            return content.contains(name) || title.contains(name) || snippet.contains(name);
          }).toList();

          return CustomScrollView(
            slivers: [
              // Cover banner
              SliverToBoxAdapter(
                child: _buildDetailCover(context, isDark),
              ),
              
              // Meta Header Block
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderCol, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentCommunity.name,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${currentCommunity.memberCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} members',
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Toggle join action
                          ElevatedButton(
                            onPressed: () => appState.toggleJoinCommunity(currentCommunity.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentCommunity.isJoined ? theme.cardColor : AppTheme.primaryBlue,
                              foregroundColor: currentCommunity.isJoined ? textPrimary : Colors.white,
                              elevation: 0,
                              side: currentCommunity.isJoined ? BorderSide(color: borderCol) : BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(
                              currentCommunity.isJoined ? 'Joined' : 'Join Community',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentCommunity.description,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Community Feed
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: groupPosts.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.messageSquare,
                                size: 36,
                                color: textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No recent posts in ${currentCommunity.name}',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = groupPosts[index];
                            return PostCard(
                              post: post,
                              onLikeTap: () => appState.toggleLike(post.id),
                              onSaveTap: () => appState.toggleSave(post.id),
                              onFollowTap: () => appState.toggleFollowUser(post.authorUsername),
                            );
                          },
                          childCount: groupPosts.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
