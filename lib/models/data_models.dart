class UserProfile {
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final List<String> skills;
  final List<String> techStack;
  final String githubUrl;
  final String portfolioUrl;
  int followersCount;
  int followingCount;
  int postsCount;
  int projectsCount;

  UserProfile({
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.skills,
    required this.techStack,
    required this.githubUrl,
    required this.portfolioUrl,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.projectsCount,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? avatarUrl,
    String? bio,
    List<String>? skills,
    List<String>? techStack,
    String? githubUrl,
    String? portfolioUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? projectsCount,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      techStack: techStack ?? this.techStack,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      projectsCount: projectsCount ?? this.projectsCount,
    );
  }
}

class Comment {
  final String id;
  final String userName;
  final String userUsername;
  final String userAvatarUrl;
  final String content;
  final String timeAgo;

  Comment({
    required this.id,
    required this.userName,
    required this.userUsername,
    required this.userAvatarUrl,
    required this.content,
    required this.timeAgo,
  });
}

class Post {
  final String id;
  final String authorName;
  final String authorUsername;
  final String authorAvatarUrl;
  final String content;
  final String type; // 'text', 'code', 'project', 'screenshot'
  final String? codeSnippet;
  final String? codeLanguage;
  final String? screenshotPlaceholderType; // 'dashboard', 'editor', 'landing'
  final String? projectTitle;
  final String? projectDescription;
  int likesCount;
  bool isLiked;
  int commentsCount;
  bool isSaved;
  final String timeAgo;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatarUrl,
    required this.content,
    required this.type,
    this.codeSnippet,
    this.codeLanguage,
    this.screenshotPlaceholderType,
    this.projectTitle,
    this.projectDescription,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
    required this.isSaved,
    required this.timeAgo,
    required this.comments,
  });

  Post copyWith({
    String? id,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    String? content,
    String? type,
    String? codeSnippet,
    String? codeLanguage,
    String? screenshotPlaceholderType,
    String? projectTitle,
    String? projectDescription,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
    bool? isSaved,
    String? timeAgo,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      screenshotPlaceholderType: screenshotPlaceholderType ?? this.screenshotPlaceholderType,
      projectTitle: projectTitle ?? this.projectTitle,
      projectDescription: projectDescription ?? this.projectDescription,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
      isSaved: isSaved ?? this.isSaved,
      timeAgo: timeAgo ?? this.timeAgo,
      comments: comments ?? this.comments,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final String? imagePlaceholder; // 'auth_screen', 'db_dashboard', 'devs_app'
  final List<String> techStack;
  final String githubUrl;
  final String demoUrl;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.imagePlaceholder,
    required this.techStack,
    required this.githubUrl,
    required this.demoUrl,
  });
}

class Community {
  final String id;
  final String name;
  final String description;
  final int coverImageIndex;
  int memberCount;
  bool isJoined;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageIndex,
    required this.memberCount,
    required this.isJoined,
  });

  Community copyWith({
    String? id,
    String? name,
    String? description,
    int? coverImageIndex,
    int? memberCount,
    bool? isJoined,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageIndex: coverImageIndex ?? this.coverImageIndex,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

class DevsNotification {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'mention'
  final String userName;
  final String userUsername;
  final String userAvatarUrl;
  final String actionDetails;
  final String timeAgo;

  DevsNotification({
    required this.id,
    required this.type,
    required this.userName,
    required this.userUsername,
    required this.userAvatarUrl,
    required this.actionDetails,
    required this.timeAgo,
  });
}
