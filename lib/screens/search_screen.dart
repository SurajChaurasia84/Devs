import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/user_avatar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/community_card.dart';
import '../widgets/project_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _dbDevelopers = [];
  bool _isLoadingDevs = true;

  final Set<String> _followedUsernames = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
    _fetchDevelopers();
  }

  Future<void> _fetchDevelopers() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      var query = Supabase.instance.client.from('profiles').select();
      
      if (currentUser != null) {
        query = query.not('id', 'eq', currentUser.id);
      }
      
      final data = await query;
      if (mounted) {
        setState(() {
          _dbDevelopers = List<Map<String, dynamic>>.from(data);
          _isLoadingDevs = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching developers from database: $e');
      if (mounted) {
        setState(() {
          _isLoadingDevs = false;
        });
      }
    }
  }

  Widget _buildDevAvatar(String avatarUrl, String name, Color textPrimary, Color borderCol) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return UserAvatar(
      avatarUrl: avatarUrl.isEmpty ? (name.isNotEmpty ? name[0] : 'D') : avatarUrl,
      size: 40,
      isDark: isDark,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sleek Search input bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, color: textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search devs, communities, or projects...',
                            hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Icon(LucideIcons.xCircle, color: textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Tabs Category header selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.only(right: 16),
                    indicator: const SmallUnderlineTabIndicator(
                      color: AppTheme.primaryBlue,
                      width: 16,
                      strokeWidth: 2,
                    ),
                    labelColor: textPrimary,
                    unselectedLabelColor: textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Developers'),
                      Tab(text: 'Communities'),
                      Tab(text: 'Projects'),
                    ],
                  ),
                ),
              ),
              
              // Search results
              Expanded(
                child: TabBarView(
                  children: [
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return _buildAllResults(appState, textPrimary, textSecondary, borderCol);
                      },
                    ),
                    _buildDevsResults(textPrimary, textSecondary, borderCol),
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return _buildGroupsResults(appState, textSecondary);
                      },
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return _buildProjectsResults(appState, textSecondary);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Render matching Developers, Communities, and Projects in "All" view
  Widget _buildAllResults(AppState appState, Color textPrimary, Color textSecondary, Color borderCol) {
    if (_isLoadingDevs) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      );
    }

    final filteredDevs = _dbDevelopers.where((dev) {
      final name = (dev['name'] ?? '').toString().toLowerCase();
      final username = (dev['username'] ?? '').toString().toLowerCase();
      final bio = (dev['bio'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || username.contains(_searchQuery) || bio.contains(_searchQuery);
    }).toList();

    final filteredGroups = appState.communities.where((comm) {
      final name = comm.name.toLowerCase();
      final desc = comm.description.toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();

    final userProjects = appState.projects;
    final filteredProjects = userProjects.where((proj) {
      final title = proj.title.toLowerCase();
      final desc = proj.description.toLowerCase();
      final tech = proj.techStack.join(' ').toLowerCase();
      return title.contains(_searchQuery) || desc.contains(_searchQuery) || tech.contains(_searchQuery);
    }).toList();

    if (filteredDevs.isEmpty && filteredGroups.isEmpty && filteredProjects.isEmpty) {
      return _buildEmptyState('No results found');
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (filteredDevs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Developers',
              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ...filteredDevs.take(3).map((dev) {
            final username = dev['username'] ?? '';
            final isFollowed = _followedUsernames.contains(username);
            final name = dev['name'] ?? 'Developer';
            final bio = dev['bio'] ?? '';
            final avatarUrl = dev['avatar_url'] ?? '';

            return _buildDevRow(avatarUrl, name, username, bio, isFollowed, textPrimary, textSecondary, borderCol);
          }),
        ],
        if (filteredGroups.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Communities',
              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ...filteredGroups.take(2).map((community) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CommunityCard(
                community: community,
                onJoinTap: () => appState.toggleJoinCommunity(community.id),
              ),
            );
          }),
        ],
        if (filteredProjects.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Projects',
              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ...filteredProjects.take(3).map((project) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProjectCard(
                project: project,
              ),
            );
          }),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // Developer row helper
  Widget _buildDevRow(
    String avatarUrl,
    String name,
    String username,
    String bio,
    bool isFollowed,
    Color textPrimary,
    Color textSecondary,
    Color borderCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderCol, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDevAvatar(avatarUrl, name, textPrimary, borderCol),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@$username',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                if (isFollowed) {
                  _followedUsernames.remove(username);
                } else {
                  _followedUsernames.add(username);
                  Provider.of<AppState>(context, listen: false).toggleFollowUser(username);
                }
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: isFollowed ? borderCol : AppTheme.primaryBlue, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isFollowed ? 'Following' : 'Follow',
              style: TextStyle(
                color: isFollowed ? textSecondary : AppTheme.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Render matching Developers
  Widget _buildDevsResults(Color textPrimary, Color textSecondary, Color borderCol) {
    if (_isLoadingDevs) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      );
    }

    final filteredDevs = _dbDevelopers.where((dev) {
      final name = (dev['name'] ?? '').toString().toLowerCase();
      final username = (dev['username'] ?? '').toString().toLowerCase();
      final bio = (dev['bio'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || username.contains(_searchQuery) || bio.contains(_searchQuery);
    }).toList();

    if (filteredDevs.isEmpty) {
      return _buildEmptyState('No developers found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDevs.length,
      itemBuilder: (context, index) {
        final dev = filteredDevs[index];
        final username = dev['username'] ?? '';
        final isFollowed = _followedUsernames.contains(username);
        final name = dev['name'] ?? 'Developer';
        final bio = dev['bio'] ?? '';
        final avatarUrl = dev['avatar_url'] ?? '';

        return _buildDevRow(avatarUrl, name, username, bio, isFollowed, textPrimary, textSecondary, borderCol);
      },
    );
  }

  // Render matching Communities
  Widget _buildGroupsResults(AppState appState, Color textSecondary) {
    final filteredGroups = appState.communities.where((comm) {
      final name = comm.name.toLowerCase();
      final desc = comm.description.toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();

    if (filteredGroups.isEmpty) {
      return _buildEmptyState('No communities found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final community = filteredGroups[index];
        return CommunityCard(
          community: community,
          onJoinTap: () => appState.toggleJoinCommunity(community.id),
        );
      },
    );
  }

  // Render matching Projects
  Widget _buildProjectsResults(AppState appState, Color textSecondary) {
    final userProjects = appState.projects;
    final allMockProjects = userProjects;

    final filteredProjects = allMockProjects.where((proj) {
      final title = proj.title.toLowerCase();
      final desc = proj.description.toLowerCase();
      final tech = proj.techStack.join(' ').toLowerCase();
      return title.contains(_searchQuery) || desc.contains(_searchQuery) || tech.contains(_searchQuery);
    }).toList();

    if (filteredProjects.isEmpty) {
      return _buildEmptyState('No projects found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProjectCard(
            project: project,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: 40, color: textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SmallUnderlineTabIndicator extends Decoration {
  final Color color;
  final double width;
  final double strokeWidth;

  const SmallUnderlineTabIndicator({
    required this.color,
    this.width = 16.0,
    this.strokeWidth = 2.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SmallUnderlinePainter(this, onChanged);
  }
}

class _SmallUnderlinePainter extends BoxPainter {
  final SmallUnderlineTabIndicator decoration;

  _SmallUnderlinePainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final xOffset = offset.dx + (size.width - decoration.width) / 2;
    final yOffset = offset.dy + size.height - decoration.strokeWidth;

    final paint = Paint()
      ..color = decoration.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(xOffset, yOffset, decoration.width, decoration.strokeWidth),
        const Radius.circular(1),
      ),
      paint,
    );
  }
}
