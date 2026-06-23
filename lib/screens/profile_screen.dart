import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:iconsax/iconsax.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_tag.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    if (_scrollController.hasClients && _scrollController.offset > 100) {
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
  Widget _buildBanner(BuildContext context, bool isDark, String? bannerImage) {
    if (bannerImage != null && bannerImage.startsWith("http")) {
      return Image.network(
        bannerImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    
    final gridColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E5E5);
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF2F2F2);
    
    return Container(
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

  Widget _buildAvatarWidget(String avatarUrl, bool isDark) {
    if (avatarUrl.length == 1) {
      return Container(
        width: 66,
        height: 66,
        decoration: const BoxDecoration(
          color: AppTheme.primaryBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          avatarUrl,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      );
    } else if (avatarUrl.startsWith('http') || avatarUrl.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(33),
        child: Image.network(
          avatarUrl,
          width: 66,
          height: 66,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Iconsax.profile_circle5,
            size: 66,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
          ),
        ),
      );
    } else {
      return Icon(
        Iconsax.profile_circle5,
        size: 66,
        color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
      );
    }
  }

  Widget _buildSmallAvatarWidget(String avatarUrl, bool isDark) {
    if (avatarUrl.length == 1) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppTheme.primaryBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          avatarUrl,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    } else if (avatarUrl.startsWith('http') || avatarUrl.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          avatarUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Iconsax.profile_circle5,
            size: 36,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
          ),
        ),
      );
    } else {
      return Icon(
        Iconsax.profile_circle5,
        size: 36,
        color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF536471),
      );
    }
  }

  IconData _getLinkIcon(String platform, String url) {
    final cleanPlatform = platform.toLowerCase().trim();
    final cleanUrl = url.toLowerCase().trim();

    if (cleanPlatform.contains('github') || cleanUrl.contains('github.com')) {
      return LucideIcons.code;
    } else if (cleanPlatform.contains('linkedin') || cleanUrl.contains('linkedin.com')) {
      return LucideIcons.briefcase;
    } else if (cleanPlatform.contains('youtube') || cleanUrl.contains('youtube.com') || cleanUrl.contains('youtu.be')) {
      return LucideIcons.play;
    } else if (cleanPlatform.contains('instagram') || cleanUrl.contains('instagram.com')) {
      return Iconsax.instagram;
    } else if (cleanPlatform.contains('twitter') || cleanPlatform.contains(' x ') || cleanPlatform == 'x' || cleanUrl.contains('twitter.com') || cleanUrl.contains('x.com')) {
      return LucideIcons.send;
    } else if (cleanPlatform.contains('portfolio') || cleanPlatform.contains('website') || cleanPlatform.contains('web')) {
      return LucideIcons.globe;
    }
    return LucideIcons.link;
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
        child: DefaultTabController(
          length: 3,
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              final user = appState.currentUser;
              
              // Filter feed posts to get only user's posts
              final userPosts = appState.posts.where((post) => post.authorUsername == user.username).toList();
              final userProjects = appState.projects;
  
              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 190,
                      backgroundColor: _showCollapsedTitle ? theme.scaffoldBackgroundColor : Colors.transparent,
                      elevation: _showCollapsedTitle ? 0.5 : 0.0,
                      automaticallyImplyLeading: false,
                      titleSpacing: 16,
                      title: AnimatedOpacity(
                        opacity: _showCollapsedTitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Row(
                          children: [
                            _buildSmallAvatarWidget(user.avatarUrl, isDark),
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
                      actions: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.pencil,
                            size: 22,
                            color: textPrimary,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.share2,
                            size: 22,
                            color: textPrimary,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share profile clicked'),
                                duration: Duration(milliseconds: 700),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.menu,
                            size: 22,
                            color: textPrimary,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('More options clicked'),
                                duration: Duration(milliseconds: 700),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            Positioned(
                              top: 0, // Starts at the very top of the screen/app bar
                              left: 0,
                              right: 0,
                              height: 150, // Increased height to 150
                              child: _buildBanner(context, isDark, user.bannerImage),
                            ),
                            Positioned(
                              left: 16,
                              top: 114, // Overlaps bottom of the 150-height banner
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                ),
                                alignment: Alignment.center,
                                child: _buildAvatarWidget(user.avatarUrl, isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: user.links.isEmpty
                                    ? [
                                        _buildLinkChip(context, _getLinkIcon('GitHub', user.githubUrl), 'GitHub', user.githubUrl),
                                        const SizedBox(width: 8),
                                        _buildLinkChip(context, _getLinkIcon('Portfolio', user.portfolioUrl), 'Portfolio', user.portfolioUrl),
                                      ]
                                    : user.links.map((link) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: _buildLinkChip(
                                            context,
                                            _getLinkIcon(link.platform, link.url),
                                            link.platform,
                                            link.url,
                                          ),
                                        );
                                      }).toList(),
                              ),
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
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        Container(
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            border: Border(
                              bottom: BorderSide(color: borderCol, width: 0.8),
                            ),
                          ),
                          child: TabBar(
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 3.5),
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                            labelColor: textPrimary,
                            unselectedLabelColor: textSecondary,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                            tabs: [
                              Tab(text: 'Posts (${userPosts.length})'),
                              Tab(text: 'Projects (${userProjects.length})'),
                              Tab(text: 'About'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    // Tab 1: Posts Tab
                    userPosts.isEmpty
                        ? _buildEmptyTabState('No updates posted yet.')
                        : ListView.builder(
                            key: const PageStorageKey<String>('posts_tab'),
                            padding: const EdgeInsets.all(12),
                            itemCount: userPosts.length,
                            itemBuilder: (context, index) {
                              final post = userPosts[index];
                              return PostCard(
                                post: post,
                                onLikeTap: () => appState.toggleLike(post.id),
                                onSaveTap: () => appState.toggleSave(post.id),
                              );
                            },
                          ),
                          
                    // Tab 2: Projects Tab
                    userProjects.isEmpty
                        ? _buildEmptyTabState('No projects published yet.')
                        : ListView.builder(
                            key: const PageStorageKey<String>('projects_tab'),
                            padding: const EdgeInsets.all(12),
                            itemCount: userProjects.length,
                            itemBuilder: (context, index) {
                              final proj = userProjects[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProjectCard(
                                  project: proj,
                                ),
                              );
                            },
                          ),
                          
                    // Tab 3: About Tab
                    SingleChildScrollView(
                      key: const PageStorageKey<String>('about_tab'),
                      padding: const EdgeInsets.all(12),
                      child: _buildAboutTab(context, user, textPrimary, textSecondary, borderCol),
                    ),
                  ],
                ),
              );
            },
          ),
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
              (user.about != null && user.about!.isNotEmpty)
                  ? user.about!
                  : 'Hey, I\'m ${user.name}! I love writing clean Flutter layouts, learning Kotlin compilers, and building developer tools in public. Mostly focusing on crafting dark modes and highly responsive micro-animations.',
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
          
          // Interests section
          if (user.interests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Interests',
              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.interests.map((interest) => SkillTag(label: interest, isActive: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child);

  final Widget _child;

  @override
  double get minExtent => 46.0;
  @override
  double get maxExtent => 46.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
