import 'package:flutter/material.dart';
import '../models/data_models.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  UserProfile _currentUser = UserProfile(
    name: "Suraj Chaurasia",
    username: "suraj_dev",
    avatarUrl: "S",
    bio: "Building Devs app in public. Flutter dev | UI/UX Designer | Open Source Enthusiast 🚀",
    skills: ["Dart", "Flutter", "Kotlin", "Java", "Python", "Swift"],
    techStack: ["Git", "VS Code", "Android Studio", "GitHub Actions", "Docker", "Node.js", "Firebase"],
    githubUrl: "https://github.com/SurajChaurasia84",
    portfolioUrl: "https://suraj.dev",
    followersCount: 1240,
    followingCount: 382,
    postsCount: 3,
    projectsCount: 2,
  );
  UserProfile get currentUser => _currentUser;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  List<Community> _communities = [];
  List<Community> get communities => _communities;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<DevsNotification> _notifications = [];
  List<DevsNotification> get notifications => _notifications;

  AppState() {
    _initData();
  }

  void _initData() {
    // 1. Initial Communities
    _communities = [
      Community(
        id: "c1",
        name: "Flutter",
        description: "Official community for Flutter developers to share progress, packages, and code snippets.",
        coverImageIndex: 0,
        memberCount: 14200,
        isJoined: true,
      ),
      Community(
        id: "c2",
        name: "React",
        description: "Modern web UI library and framework discussions, Next.js, and typescript architecture.",
        coverImageIndex: 1,
        memberCount: 22500,
        isJoined: false,
      ),
      Community(
        id: "c3",
        name: "Python",
        description: "Data science, script automation, backend development, and general Python coding guidelines.",
        coverImageIndex: 2,
        memberCount: 31100,
        isJoined: false,
      ),
      Community(
        id: "c4",
        name: "AI/ML",
        description: "Deep learning, LLMs, neural networks, computer vision, and prompt engineering.",
        coverImageIndex: 3,
        memberCount: 18400,
        isJoined: true,
      ),
      Community(
        id: "c5",
        name: "Android",
        description: "Kotlin, Jetpack Compose, native Android performance tuning, and architecture.",
        coverImageIndex: 4,
        memberCount: 11800,
        isJoined: false,
      ),
      Community(
        id: "c6",
        name: "Web Development",
        description: "HTML, CSS, JavaScript, node, backend servers, and web design optimization standards.",
        coverImageIndex: 5,
        memberCount: 28900,
        isJoined: false,
      ),
    ];

    // 2. Initial Projects (Owned by current user or showcase)
    _projects = [
      Project(
        id: "p1",
        title: "Devs Android App",
        description: "A premium social ecosystem built for developer collaboration. Supports code highlights, build showcased public projects, and light/dark themes.",
        imagePlaceholder: "devs_app",
        techStack: ["Flutter", "Dart", "Material 3", "ChangeNotifier"],
        githubUrl: "https://github.com/SurajChaurasia84/Devs",
        demoUrl: "https://devs.app/demo",
      ),
      Project(
        id: "p2",
        title: "FastRegex Highlighter",
        description: "A lightweight parser custom built to highlight code structures in modern developer interfaces using minimalist design principles.",
        imagePlaceholder: "auth_screen",
        techStack: ["Dart", "Regular Expressions", "TextSpan"],
        githubUrl: "https://github.com/SurajChaurasia84/FastRegex",
        demoUrl: "https://pub.dev/packages/fast_regex",
      ),
    ];

    // 3. Initial Posts
    _posts = [
      Post(
        id: "post_1",
        authorName: "Alex Rivera",
        authorUsername: "alex_dev",
        authorAvatarUrl: "A",
        content: "Finally shipping the Devs Android app UI! The dynamic theme toggling is super smooth. Let me know what you think of the custom code highlighter implementation. Check out the main entry code below:",
        type: "code",
        codeLanguage: "dart",
        codeSnippet: """import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devs',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigationScreen(),
    );
  }
}""",
        likesCount: 42,
        isLiked: false,
        commentsCount: 2,
        isSaved: false,
        timeAgo: "2h ago",
        comments: [
          Comment(
            id: "cmt_1",
            userName: "Dan Williamson",
            userUsername: "dan_code",
            userAvatarUrl: "D",
            content: "This looks incredibly clean! Love the custom font rendering.",
            timeAgo: "50m ago",
          ),
          Comment(
            id: "cmt_2",
            userName: "Sarah Chen",
            userUsername: "sarah_ai",
            userAvatarUrl: "S",
            content: "Stunning work! The bottom sheet drawer animation is very smooth.",
            timeAgo: "30m ago",
          ),
        ],
      ),
      Post(
        id: "post_2",
        authorName: "Sarah Chen",
        authorUsername: "sarah_ai",
        authorAvatarUrl: "S",
        content: "Just finished training a custom parser for syntax highlighting using only black, white, gray, and blue tokens. Fits perfectly with our design constraint rules! Check out the showcase details.",
        type: "project",
        projectTitle: "SyntaxHighlight-Parser",
        projectDescription: "A custom light weight regex parser optimized for code snippets with minimalist highlight themes.",
        likesCount: 89,
        isLiked: false,
        commentsCount: 1,
        isSaved: false,
        timeAgo: "4h ago",
        comments: [
          Comment(
            id: "cmt_3",
            userName: "Emily Watson",
            userUsername: "emily_web",
            userAvatarUrl: "E",
            content: "Exactly what I was looking for! Will definitely read the source code.",
            timeAgo: "2h ago",
          ),
        ],
      ),
      Post(
        id: "post_3",
        authorName: "Dan Williamson",
        authorUsername: "dan_code",
        authorAvatarUrl: "D",
        content: "Starting my day by reviewing some old Kotlin logic. Clean architecture is always worth the extra setup time. Writing domain repositories with Result models keeps errors clean:",
        type: "code",
        codeLanguage: "kotlin",
        codeSnippet: """class UserUseCase(private val repository: UserRepository) {
    suspend fun execute(userId: String): Result<User> {
        return try {
            val user = repository.getUser(userId)
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}""",
        likesCount: 19,
        isLiked: false,
        commentsCount: 0,
        isSaved: false,
        timeAgo: "5h ago",
        comments: [],
      ),
      Post(
        id: "post_4",
        authorName: "Emily Watson",
        authorUsername: "emily_web",
        authorAvatarUrl: "E",
        content: "A sneak peek of the dashboard layout I'm building for a server monitoring client. Clean dark theme, responsive grid cards, status highlights. Almost ready for demo deployment!",
        type: "screenshot",
        screenshotPlaceholderType: "dashboard",
        likesCount: 124,
        isLiked: true,
        commentsCount: 0,
        isSaved: true,
        timeAgo: "1d ago",
        comments: [],
      ),
    ];

    // 4. Initial Notifications
    _notifications = [
      DevsNotification(
        id: "n1",
        type: "like",
        userName: "Sarah Chen",
        userUsername: "sarah_ai",
        userAvatarUrl: "S",
        actionDetails: "liked your project showcase FastRegex Highlighter",
        timeAgo: "10m ago",
      ),
      DevsNotification(
        id: "n2",
        type: "comment",
        userName: "Dan Williamson",
        userUsername: "dan_code",
        userAvatarUrl: "D",
        actionDetails: "commented: 'Awesome UI design, very snappy!'",
        timeAgo: "45m ago",
      ),
      DevsNotification(
        id: "n3",
        type: "follow",
        userName: "Alex Rivera",
        userUsername: "alex_dev",
        userAvatarUrl: "A",
        actionDetails: "started following you",
        timeAgo: "2h ago",
      ),
      DevsNotification(
        id: "n4",
        type: "mention",
        userName: "Emily Watson",
        userUsername: "emily_web",
        userAvatarUrl: "E",
        actionDetails: "mentioned you: 'Check out @suraj_dev's project showcase'",
        timeAgo: "1d ago",
      ),
    ];
  }

  // --- ACTIONS ---

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
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
}
