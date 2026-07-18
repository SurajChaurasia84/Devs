import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  UserProfile _currentUser = UserProfile(
    name: "",
    username: "",
    avatarUrl: "",
    bio: "",
    skills: [],
    techStack: [],
    githubUrl: "",
    portfolioUrl: "",
    followersCount: 0,
    followingCount: 0,
    postsCount: 0,
    projectsCount: 0,
    about: "",
    interests: [],
    links: [],
  );
  UserProfile get currentUser => _currentUser;

  final List<Post> _posts = [];
  List<Post> get posts => _posts;

  final List<Community> _communities = [];
  List<Community> get communities => _communities;

  final List<Project> _projects = [];
  List<Project> get projects => _projects;

  final List<DevsNotification> _notifications = [];
  List<DevsNotification> get notifications => _notifications;

  AppState({ThemeMode initialThemeMode = ThemeMode.system}) : _themeMode = initialThemeMode;

  // --- ACTIONS ---

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      final platformBrightness = PlatformDispatcher.instance.platformBrightness;
      _themeMode = platformBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', _themeMode.name);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newIsLiked = !post.isLiked;
      _posts[postIndex] = post.copyWith(
        isLiked: newIsLiked,
        likesCount: post.likesCount + (newIsLiked ? 1 : -1),
      );
      notifyListeners();
    }
  }

  void toggleSave(String postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(
        isSaved: !post.isSaved,
      );
      notifyListeners();
    }
  }

  void addComment(String postId, String content) {
    if (content.trim().isEmpty) return;

    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newComment = Comment(
        id: "new_cmt_${DateTime.now().millisecondsSinceEpoch}",
        userName: _currentUser.name,
        userUsername: _currentUser.username,
        userAvatarUrl: _currentUser.avatarUrl,
        content: content,
        timeAgo: "Just now",
      );

      final updatedComments = List<Comment>.from(post.comments)..insert(0, newComment);
      _posts[postIndex] = post.copyWith(
        comments: updatedComments,
        commentsCount: post.commentsCount + 1,
      );
      notifyListeners();
    }
  }

  void toggleJoinCommunity(String communityId) {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final comm = _communities[index];
      final newIsJoined = !comm.isJoined;
      _communities[index] = comm.copyWith(
        isJoined: newIsJoined,
        memberCount: comm.memberCount + (newIsJoined ? 1 : -1),
      );
      notifyListeners();
    }
  }

  void addPost({
    required String content,
    required String type,
    String? codeSnippet,
    String? codeLanguage,
    String? screenshotPlaceholderType,
    String? projectTitle,
    String? projectDescription,
  }) {
    final newPost = Post(
      id: "post_${DateTime.now().millisecondsSinceEpoch}",
      authorName: _currentUser.name,
      authorUsername: _currentUser.username,
      authorAvatarUrl: _currentUser.avatarUrl,
      content: content,
      type: type,
      codeSnippet: codeSnippet,
      codeLanguage: codeLanguage,
      screenshotPlaceholderType: screenshotPlaceholderType,
      projectTitle: projectTitle,
      projectDescription: projectDescription,
      likesCount: 0,
      isLiked: false,
      commentsCount: 0,
      isSaved: false,
      timeAgo: "Just now",
      comments: [],
    );

    _posts.insert(0, newPost);
    
    // Increment post count in current user's profile stats
    _currentUser = _currentUser.copyWith(
      postsCount: _currentUser.postsCount + 1,
    );

    // If it is a project, add to user's project list as well
    if (type == "project" && projectTitle != null && projectDescription != null) {
      final newProject = Project(
        id: "proj_${DateTime.now().millisecondsSinceEpoch}",
        title: projectTitle,
        description: projectDescription,
        techStack: ["Flutter", "Dart"], // default tags for simulation
        githubUrl: "https://github.com/SurajChaurasia84",
        demoUrl: "https://devs.app/demo",
      );
      _projects.insert(0, newProject);
      _currentUser = _currentUser.copyWith(
        projectsCount: _currentUser.projectsCount + 1,
      );
    }

    notifyListeners();
  }

  void toggleFollowUser(String username) {
    // Toggle follow simulation
    if (username == _currentUser.username) return;
    
    // In our simplified mock, if following an author, we just update the follow counter
    // Let's increment or decrement following count of currentUser
    // To see feedback, we can toggle follows state
    _currentUser = _currentUser.copyWith(
      followingCount: _currentUser.followingCount + 1, // simplified toggle
    );
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        // Load custom links if table exists
        List<ProfileLink> profileLinks = [];
        try {
          final linksRes = await Supabase.instance.client
              .from('profile_links')
              .select()
              .eq('profile_id', user.id);
          
          profileLinks = linksRes.map((l) {
            return ProfileLink(
              platform: l['platform'] ?? '',
              url: l['url'] ?? '',
            );
          }).toList();
        } catch (e) {
          // Ignore table-not-found / RLS errors
        }

        _currentUser = UserProfile(
          name: data['name'] ?? 'New Developer',
          username: data['username'] ?? user.email!.split('@')[0],
          avatarUrl: data['avatar_url'] ?? 'https://api.dicebear.com/7.x/bottts/png?seed=${user.id}',
          bannerImage: data['banner_image'],
          bio: data['bio'] ?? 'Joined Devs community!',
          skills: data['skills'] != null ? List<String>.from(data['skills']) : [],
          techStack: data['tech_stack'] != null ? List<String>.from(data['tech_stack']) : [],
          githubUrl: data['github_url'] ?? '',
          portfolioUrl: data['portfolio_url'] ?? '',
          followersCount: data['followers_count'] ?? 0,
          followingCount: data['following_count'] ?? 0,
          postsCount: data['posts_count'] ?? 0,
          projectsCount: data['projects_count'] ?? 0,
          about: data['about'] ?? '',
          interests: data['interests'] != null ? List<String>.from(data['interests']) : [],
          links: profileLinks,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _currentUser = profile;
    notifyListeners();

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'name': profile.name,
          'username': profile.username,
          'bio': profile.bio,
          'email': user.email,
          'avatar_url': profile.avatarUrl,
          'banner_image': profile.bannerImage,
          'skills': profile.skills,
          'tech_stack': profile.techStack,
          'github_url': profile.githubUrl,
          'portfolio_url': profile.portfolioUrl,
          'followers_count': profile.followersCount,
          'following_count': profile.followingCount,
          'posts_count': profile.postsCount,
          'projects_count': profile.projectsCount,
          'about': profile.about,
          'interests': profile.interests,
        });

        // Sync links
        try {
          await Supabase.instance.client
              .from('profile_links')
              .delete()
              .eq('profile_id', user.id);

          if (profile.links.isNotEmpty) {
            final linkRows = profile.links.map((link) => {
              'profile_id': user.id,
              'platform': link.platform,
              'url': link.url,
            }).toList();
            await Supabase.instance.client.from('profile_links').insert(linkRows);
          }
        } catch (e) {
          // Table may not exist or RLS issue, ignore
        }
      } catch (e) {
        debugPrint('Error updating profile in Supabase: $e');
      }
    }
  }

  Future<bool> checkAndLoadProfile(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('name, username')
          .eq('id', userId)
          .maybeSingle();

      if (res != null && 
          res['name'] != null && 
          res['name'].toString().isNotEmpty && 
          res['username'] != null && 
          res['username'].toString().isNotEmpty) {
        await loadUserProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking profile: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  void addProject(Project project) {
    _projects.insert(0, project);
    _currentUser = _currentUser.copyWith(
      projectsCount: _currentUser.projectsCount + 1,
    );
    notifyListeners();
  }

  void editProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    _projects.removeWhere((p) => p.id == projectId);
    _currentUser = _currentUser.copyWith(
      projectsCount: _currentUser.projectsCount - 1,
    );
    notifyListeners();
  }
}
