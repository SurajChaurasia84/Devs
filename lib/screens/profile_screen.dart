import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:iconsax/iconsax.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_tag.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'posts'; // 'posts', 'projects', 'about'
  late ScrollController _scrollController;
  bool _showCollapsedTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients && _scrollController.offset > 80) {
      if (!_showCollapsedTitle) {
        setState(() {
          _showCollapsedTitle = true;
        });
      }
    } else {
      if (_showCollapsedTitle) {
        setState(() {
          _showCollapsedTitle = false;
        });
      }
    }
  }

  // Build the custom grid/blueprint background banner for developer profile
  Widget _buildBanner(BuildContext context, bool isDark) {
    final gridColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E5E5);
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF2F2F2);
    
    return Container(
      height: 100,
      width: double.infinity,
      color: bgColor,
      child: Stack(
        children: [
          // Grid paper pattern background
          Positioned.fill(
            child: GridPaper(
              color: gridColor,
              interval: 14,
              subdivisions: 1,
              child: Container(),
            ),
          ),
          // Binary text matrix decorations
          Positioned(
            left: 20,
            top: 20,
            child: Opacity(
              opacity: isDark ? 0.06 : 0.04,
              child: Text(
                '01100100 01100101 01110110 01110011', // binary for "devs"
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 40,
            child: Opacity(
              opacity: isDark ? 0.07 : 0.04,
              child: Text(
                'class Developer {}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
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
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            final user = appState.currentUser;
            
            // Filter feed posts to get only user's posts
            final userPosts = appState.posts.where((post) => post.authorUsername == user.username).toList();
            final userProjects = appState.projects;
  
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 144,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0.5,
                  automaticallyImplyLeading: false,
                  titleSpacing: 16,
                  title: AnimatedOpacity(
                    opacity: _showCollapsedTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF202020) : const Color(0xFFF0F0F0),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Iconsax.profile_circle5,
                            size: 28,
                            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildBanner(context, isDark),
                        Positioned(
                          left: 16,
                          bottom: -36,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Iconsax.profile_circle5,
                              size: 66,
                              color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Top padding to account for the overlapping avatar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 44),
                ),
                
                // Profile details & stats block
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Username
                        Text(
                          user.name,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Bio
                        Text(
                          user.bio,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Links Row
                        Row(
                          children: [
                            _buildLinkChip(context, LucideIcons.github, 'GitHub', user.githubUrl),
                            const SizedBox(width: 8),
                            _buildLinkChip(context, LucideIcons.globe, 'Portfolio', user.portfolioUrl),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats metrics row
                        Row(
                          children: [
                            _buildStatItem(user.followersCount.toString(), 'Followers'),
                            _buildStatDivider(borderCol),
                            _buildStatItem(user.followingCount.toString(), 'Following'),
                            _buildStatDivider(borderCol),
                            _buildStatItem(userPosts.length.toString(), 'Posts'),
                            _buildStatDivider(borderCol),
                            _buildStatItem(userProjects.length.toString(), 'Projects'),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                
                // Tab Selector Row
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: borderCol, width: 1),
                        bottom: BorderSide(color: borderCol, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('posts', 'Posts (${userPosts.length})'),
                        _buildTabItem('projects', 'Projects (${userProjects.length})'),
                        _buildTabItem('about', 'About'),
                      ],
                    ),
                  ),
                ),
                
                // Dynamic Tab contents
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: _selectedTab == 'posts'
                      ? (userPosts.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyTabState('No updates posted yet.'),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final post = userPosts[index];
                                  return PostCard(
                                    post: post,
                                    onLikeTap: () => appState.toggleLike(post.id),
                                    onSaveTap: () => appState.toggleSave(post.id),
                                  );
                                },
                                childCount: userPosts.length,
                              ),
                            ))
                      : _selectedTab == 'projects'
                          ? (userProjects.isEmpty
                              ? SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _buildEmptyTabState('No projects published yet.'),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final proj = userProjects[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: ProjectCard(
                                          project: proj,
                                        ),
                                      );
                                    },
                                    childCount: userProjects.length,
                                  ),
                                ))
                          : SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildAboutTab(context, user, textPrimary, textSecondary, borderCol),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLinkChip(BuildContext context, IconData icon, String label, String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening link: $url...', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.primaryBlue,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: borderCol),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: AppTheme.primaryBlue),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(Color col) {
    return Container(
      width: 1,
      height: 24,
      color: col,
    );
  }

  Widget _buildTabItem(String tabKey, String label) {
    final isSelected = _selectedTab == tabKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTabState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, UserProfile user, Color textPrimary, Color textSecondary, Color borderCol) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio details section
          Text(
            'Developer Story',
            style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: borderCol),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Hey, I\'m ${user.name}! I love writing clean Flutter layouts, learning Kotlin compilers, and building developer tools in public. Mostly focusing on crafting dark modes and highly responsive micro-animations.',
              style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Skills tag section
          Text(
            'Skills',
            style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills.map((skill) => SkillTag(label: skill, isActive: true)).toList(),
          ),
          const SizedBox(height: 16),
          
          // Tech Stack section
          Text(
            'Tech Stack',
            style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.techStack.map((tech) => SkillTag(label: tech)).toList(),
          ),
        ],
      ),
    );
  }
}
