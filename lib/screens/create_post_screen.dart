import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';

class CreatePostScreen extends StatefulWidget {
  final VoidCallback onPostPublished;

  const CreatePostScreen({
    super.key,
    required this.onPostPublished,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _codeController = TextEditingController();
  final _projTitleController = TextEditingController();
  final _projDescController = TextEditingController();

  String _selectedType = 'text'; // 'text', 'code', 'project', 'screenshot'
  String _selectedLanguage = 'dart';
  String _selectedScreenshotMock = 'dashboard';

  @override
  void initState() {
    super.initState();
    // Rebuild preview on text edits
    _contentController.addListener(_updatePreview);
    _codeController.addListener(_updatePreview);
    _projTitleController.addListener(_updatePreview);
    _projDescController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _codeController.dispose();
    _projTitleController.dispose();
    _projDescController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {}); // Rebuild widget to show live preview
  }

  void _publishPost(AppState appState) {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    appState.addPost(
      content: content,
      type: _selectedType,
      codeSnippet: _selectedType == 'code' ? _codeController.text : null,
      codeLanguage: _selectedType == 'code' ? _selectedLanguage : null,
      screenshotPlaceholderType: _selectedType == 'screenshot' ? _selectedScreenshotMock : null,
      projectTitle: _selectedType == 'project' ? _projTitleController.text : null,
      projectDescription: _selectedType == 'project' ? _projDescController.text : null,
    );

    // Reset controllers
    _contentController.clear();
    _codeController.clear();
    _projTitleController.clear();
    _projDescController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post published successfully!', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    widget.onPostPublished();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final appState = Provider.of<AppState>(context, listen: false);

    // Dynamic Preview Post model for rendering in live preview card
    final previewPost = Post(
      id: "preview",
      authorName: appState.currentUser.name,
      authorUsername: appState.currentUser.username,
      authorAvatarUrl: appState.currentUser.avatarUrl,
      content: _contentController.text.isEmpty ? 'Type some details to see preview...' : _contentController.text,
      type: _selectedType,
      codeSnippet: _selectedType == 'code' ? (_codeController.text.isEmpty ? '// code editor' : _codeController.text) : null,
      codeLanguage: _selectedLanguage,
      screenshotPlaceholderType: _selectedScreenshotMock,
      projectTitle: _selectedType == 'project' ? (_projTitleController.text.isEmpty ? 'My Project Title' : _projTitleController.text) : null,
      projectDescription: _selectedType == 'project' ? (_projDescController.text.isEmpty ? 'Short project description...' : _projDescController.text) : null,
      likesCount: 0,
      isLiked: false,
      commentsCount: 0,
      isSaved: false,
      timeAgo: "Just now",
      comments: [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _contentController.text.trim().isEmpty ? null : () => _publishPost(appState),
              style: TextButton.styleFrom(
                backgroundColor: _contentController.text.trim().isEmpty
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Selector tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeSelector('text', LucideIcons.fileText, 'Text'),
                    _buildTypeSelector('code', LucideIcons.code, 'Code Snippet'),
                    _buildTypeSelector('project', LucideIcons.folder, 'Project Showcase'),
                    _buildTypeSelector('screenshot', LucideIcons.image, 'IDE Mockup'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Text Content Input
              Text(
                'Description',
                style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                style: TextStyle(color: textPrimary, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What are you building in public today?',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Type-specific Editor Forms
              if (_selectedType == 'code') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Code Block',
                      style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    // Language picker
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                      underline: Container(),
                      items: ['dart', 'kotlin', 'python', 'javascript', 'html', 'css'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedLanguage = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  style: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 12),
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Paste or write code snippet here...',
                    hintStyle: GoogleFonts.jetBrainsMono(color: textSecondary, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_selectedType == 'project') ...[
                Text(
                  'Project Meta',
                  style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _projTitleController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Project Title',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _projDescController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Short Project Description...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_selectedType == 'screenshot') ...[
                Text(
                  'Choose Mockup Style',
                  style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMockupSelectCard('dashboard', LucideIcons.layoutGrid, 'Dashboard Grid'),
                    const SizedBox(width: 12),
                    _buildMockupSelectCard('editor', LucideIcons.code, 'Code Editor'),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Live Preview Layout Block
              Text(
                'Live Preview',
                style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AbsorbPointer(
                child: PostCard(
                  post: previewPost,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            border: Border.all(color: isSelected ? AppTheme.primaryBlue : borderCol),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockupSelectCard(String style, IconData icon, String label) {
    final isSelected = _selectedScreenshotMock == style;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedScreenshotMock = style;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : borderCol,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
