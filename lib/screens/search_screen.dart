import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
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
  String _activeTab = 'devs'; // 'devs', 'groups', 'projects'
  String _searchQuery = '';

  // Seed developers database for search (excluding current user)
  final List<Map<String, String>> _mockDevelopers = [
    {
      "name": "Alex Rivera",
      "username": "alex_dev",
      "avatar": "A",
      "bio": "Senior Flutter Engineer. Shipping apps in public. Open-source maintainer.",
    },
    {
      "name": "Sarah Chen",
      "username": "sarah_ai",
      "avatar": "S",
      "bio": "AI/ML Researcher. Prompt engineering & custom local model fine-tuning.",
    },
    {
      "name": "Dan Williamson",
      "username": "dan_code",
      "avatar": "D",
      "bio": "Fullstack web developer. React, Next.js, and Node.js optimization.",
    },
    {
      "name": "Emily Watson",
      "username": "emily_web",
      "avatar": "E",
      "bio": "React Developer. Passionate about WebGL and interactive web animations.",
    },
    {
      "name": "Marcus Aurelius",
      "username": "philosopher_dev",
      "avatar": "M",
      "bio": "Systems Engineer. Rust, assembly language, and kernel-level programming.",
    },
  ];

  final Set<String> _followedUsernames = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
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
            child: Row(
              children: [
                _buildCategoryTab('devs', 'Developers'),
                _buildCategoryTab('groups', 'Communities'),
                _buildCategoryTab('projects', 'Projects'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // Search results
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                if (_activeTab == 'devs') {
                  return _buildDevsResults(textPrimary, textSecondary, borderCol);
                } else if (_activeTab == 'groups') {
                  return _buildGroupsResults(appState, textSecondary);
                } else {
                  return _buildProjectsResults(appState, textSecondary);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String tabKey, String label) {
    final isSelected = _activeTab == tabKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabKey;
          });
        },
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 16,
              height: 2,
              color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // Render matching Developers
  Widget _buildDevsResults(Color textPrimary, Color textSecondary, Color borderCol) {
    final filteredDevs = _mockDevelopers.where((dev) {
      final name = dev['name']!.toLowerCase();
      final username = dev['username']!.toLowerCase();
      final bio = dev['bio']!.toLowerCase();
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
        final username = dev['username']!;
        final isFollowed = _followedUsernames.contains(username);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderCol, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: borderCol,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  dev['avatar']!,
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Meta info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dev['name']!,
                      style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@$username',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dev['bio']!,
                      style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Follow toggle button
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isFollowed) {
                      _followedUsernames.remove(username);
                    } else {
                      _followedUsernames.add(username);
                      // Update main app stats context
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
    // For demonstration, let's include some public database search projects
    final allMockProjects = [
      ...userProjects,
      Project(
        id: "p_search_1",
        title: "KernelRust",
        description: "A sandbox environment containing Rust modules compiling directly within native Linux kernels.",
        techStack: ["Rust", "Linux Kernel", "C"],
        githubUrl: "https://github.com",
        demoUrl: "https://github.com",
      ),
      Project(
        id: "p_search_2",
        title: "Zenith GL",
        description: "High-performance procedural GPU compiler written completely using Typescript and raw WebGL pipeline models.",
        techStack: ["TypeScript", "WebGL", "GPU Shaders"],
        githubUrl: "https://github.com",
        demoUrl: "https://github.com",
      ),
    ];

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
