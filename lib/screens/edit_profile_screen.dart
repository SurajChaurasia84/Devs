import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:iconsax/iconsax.dart';
import '../data/mock_data.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';
import 'project_form_screen.dart';
import 'link_form_screen.dart';
import '../widgets/profile_link_tile.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _aboutController;
  late TextEditingController _skillInputController;
  late TextEditingController _interestInputController;

  // Local state copies
  String _selectedAvatarUrl = "";
  String _selectedBannerUrl = "";
  List<String> _skills = [];
  List<String> _interests = [];
  List<Project> _projects = [];
  List<ProfileLink> _links = [];

  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;
      
      _nameController = TextEditingController(text: user.name);
      _usernameController = TextEditingController(text: user.username);
      _bioController = TextEditingController(text: user.bio);
      _aboutController = TextEditingController(text: user.about ?? "");
      _skillInputController = TextEditingController();
      _interestInputController = TextEditingController();

      _selectedAvatarUrl = user.avatarUrl;
      _selectedBannerUrl = user.bannerImage ?? "";
      _skills = List<String>.from(user.skills);
      _interests = List<String>.from(user.interests);
      _projects = List<Project>.from(appState.projects);
      _links = List<ProfileLink>.from(user.links);

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _aboutController.dispose();
    _skillInputController.dispose();
    _interestInputController.dispose();
    super.dispose();
  }

  bool _hasChanges(UserProfile user, List<Project> originalProjects) {
    if (_nameController.text != user.name) return true;
    if (_usernameController.text != user.username) return true;
    if (_bioController.text != user.bio) return true;
    if (_aboutController.text != (user.about ?? "")) return true;
    if (_selectedAvatarUrl != user.avatarUrl) return true;
    if (_selectedBannerUrl != (user.bannerImage ?? "")) return true;
    
    // Skills
    if (_skills.length != user.skills.length) return true;
    for (int i = 0; i < _skills.length; i++) {
      if (_skills[i] != user.skills[i]) return true;
    }
    
    // Interests
    if (_interests.length != user.interests.length) return true;
    for (int i = 0; i < _interests.length; i++) {
      if (_interests[i] != user.interests[i]) return true;
    }
    
    // Links
    if (_links.length != user.links.length) return true;
    for (int i = 0; i < _links.length; i++) {
      if (_links[i].platform != user.links[i].platform) return true;
      if (_links[i].url != user.links[i].url) return true;
    }
    
    // Projects
    if (_projects.length != originalProjects.length) return true;
    for (int i = 0; i < _projects.length; i++) {
      if (_projects[i].id != originalProjects[i].id) return true;
      if (_projects[i].title != originalProjects[i].title) return true;
      if (_projects[i].description != originalProjects[i].description) return true;
      if (_projects[i].demoUrl != originalProjects[i].demoUrl) return true;
    }
    
    return false;
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Unsaved Changes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to discard your edits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  // Curated premium options for Avatars & Banners
  final List<String> _presetAvatars = [
    "S", // Text Initial Fallback
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200"
  ];

  final List<String> _presetBanners = [
    "grid_default", // Flag for the Grid schematic banner
    "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1607799279861-4dd421887fb3?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1629654297299-c8506221ca97?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&q=80&w=600"
  ];

  void _showImagePickerModal({required bool isProfile}) {
    final theme = Theme.of(context);
    final urlController = TextEditingController(
      text: isProfile ? (_selectedAvatarUrl.startsWith("http") ? _selectedAvatarUrl : "") : (_selectedBannerUrl.startsWith("http") ? _selectedBannerUrl : ""),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isProfile ? 'Change Profile Picture' : 'Change Banner Image',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Predefined Option:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: isProfile ? _presetAvatars.length : _presetBanners.length,
                  itemBuilder: (context, index) {
                    final item = isProfile ? _presetAvatars[index] : _presetBanners[index];
                    final isSelected = isProfile ? _selectedAvatarUrl == item : _selectedBannerUrl == item;
                    
                    Widget preview;
                    if (item == "S") {
                      preview = const CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      );
                    } else if (item == "grid_default") {
                      preview = Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(LucideIcons.layoutGrid, size: 24, color: Colors.white54),
                      );
                    } else {
                      preview = ClipRRect(
                        borderRadius: BorderRadius.circular(isProfile ? 40 : 8),
                        child: Image.network(
                          item,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isProfile) {
                            _selectedAvatarUrl = item;
                          } else {
                            _selectedBannerUrl = item;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: isProfile ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: isProfile ? null : BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: preview,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Or Paste Custom Image URL:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = urlController.text.trim();
                      if (val.isNotEmpty) {
                        setState(() {
                          if (isProfile) {
                            _selectedAvatarUrl = val;
                          } else {
                            _selectedBannerUrl = val;
                          }
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProjectForm({Project? project}) async {
    final result = await Navigator.of(context).push<Project>(
      MaterialPageRoute(
        builder: (context) => ProjectFormScreen(project: project),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (project == null) {
          _projects.add(result);
        } else {
          final idx = _projects.indexWhere((p) => p.id == project.id);
          if (idx != -1) {
            _projects[idx] = result;
          }
        }
      });
    }
  }

  void _navigateToLinkForm({ProfileLink? link}) async {
    final result = await Navigator.of(context).push<ProfileLink>(
      MaterialPageRoute(
        builder: (context) => LinkFormScreen(link: link),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (link == null) {
          _links.add(result);
        } else {
          final idx = _links.indexOf(link);
          if (idx != -1) {
            _links[idx] = result;
          }
        }
      });
    }
  }



  Future<bool> _showDeleteConfirmationDialog({required String title, required String itemType}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Simulate saving latency
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    
    // Construct updated profile
    final updatedProfile = appState.currentUser.copyWith(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      about: _aboutController.text.trim(),
      avatarUrl: _selectedAvatarUrl,
      bannerImage: _selectedBannerUrl,
      skills: _skills,
      interests: _interests,
      links: _links,
    );

    // Update global state
    appState.updateProfile(updatedProfile);

    // Save updated projects
    // First, delete ones not in local copy
    final currentProjIds = _projects.map((p) => p.id).toSet();
    for (var p in List<Project>.from(appState.projects)) {
      if (!currentProjIds.contains(p.id)) {
        appState.deleteProject(p.id);
      }
    }
    // Add/Edit
    final origProjIds = appState.projects.map((p) => p.id).toSet();
    for (var p in _projects) {
      if (origProjIds.contains(p.id)) {
        appState.editProject(p);
      } else {
        appState.addProject(p);
      }
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          centerTitle: true,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            onPressed: () async {
              if (_hasChanges(appState.currentUser, appState.projects)) {
                final discard = await _showDiscardDialog();
                if (discard && context.mounted) Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: borderCol, width: 0.8)),
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text('Save Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Banner & Avatar Header Stack
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          // Banner image container
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 150,
                            child: GestureDetector(
                              onTap: () => _showImagePickerModal(isProfile: false),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _selectedBannerUrl.startsWith("http")
                                        ? Image.network(_selectedBannerUrl, fit: BoxFit.cover)
                                        : Container(
                                            color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF2F2F2),
                                            child: GridPaper(
                                              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E5E5),
                                              interval: 14,
                                              subdivisions: 1,
                                              child: Container(),
                                            ),
                                          ),
                                  ),
                                  // Edit Banner Overlay
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    alignment: Alignment.center,
                                    child: const Icon(LucideIcons.camera, color: Colors.white, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Overlapping Avatar container
                          Positioned(
                            left: 20,
                            top: 110,
                            child: GestureDetector(
                              onTap: () => _showImagePickerModal(isProfile: true),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                    ),
                                    alignment: Alignment.center,
                                    child: _selectedAvatarUrl.length == 1
                                        ? CircleAvatar(
                                            radius: 36,
                                            backgroundColor: AppTheme.primaryBlue,
                                            child: Text(
                                              _selectedAvatarUrl,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 32,
                                              ),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(36),
                                            child: Image.network(
                                              _selectedAvatarUrl,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.profile_circle5, size: 72),
                                            ),
                                          ),
                                  ),
                                  // Edit Avatar Badge
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(LucideIcons.camera, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // 1. Basic Information Section
                          _buildSectionCard(
                            title: 'BASIC INFORMATION',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildInputLabel('Name *'),
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your name',
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Username *'),
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter username',
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Username is required' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('Tagline / Bio'),
                                TextFormField(
                                  controller: _bioController,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Briefly describe yourself',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: borderCol.withValues(alpha: 0.4), thickness: 0.6, height: 32),

                          // 2. About Section
                          _buildSectionCard(
                            title: 'ABOUT',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildInputLabel('Developer Story (Multi-line)'),
                                TextFormField(
                                  controller: _aboutController,
                                  maxLines: 5,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Tell the community about your coding journey...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: borderCol.withValues(alpha: 0.4), thickness: 0.6, height: 32),

                          // 3. Skills Section
                          _buildSectionCard(
                            title: 'SKILLS',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _skillInputController,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Flutter',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        final text = _skillInputController.text.trim();
                                        if (text.isNotEmpty && !_skills.contains(text)) {
                                          setState(() {
                                            _skills.add(text);
                                          });
                                          _skillInputController.clear();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: textPrimary,
                                        foregroundColor: isDark ? Colors.black : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _skills.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          'No skills added yet.',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _skills.map((skill) {
                                          return Chip(
                                            label: Text(skill, style: const TextStyle(fontSize: 11)),
                                            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                                            side: BorderSide(color: borderCol),
                                            padding: const EdgeInsets.all(4),
                                            deleteIcon: const Icon(LucideIcons.x, size: 12),
                                            onDeleted: () {
                                              setState(() {
                                                _skills.remove(skill);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                          Divider(color: borderCol.withValues(alpha: 0.4), thickness: 0.6, height: 32),

                          // 4. Interests Section
                          _buildSectionCard(
                            title: 'INTERESTS',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _interestInputController,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Open Source',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        final text = _interestInputController.text.trim();
                                        if (text.isNotEmpty && !_interests.contains(text)) {
                                          setState(() {
                                            _interests.add(text);
                                          });
                                          _interestInputController.clear();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: textPrimary,
                                        foregroundColor: isDark ? Colors.black : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _interests.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          'No interests added yet.',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _interests.map((interest) {
                                          return Chip(
                                            label: Text(interest, style: const TextStyle(fontSize: 11)),
                                            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                                            side: BorderSide(color: borderCol),
                                            padding: const EdgeInsets.all(4),
                                            deleteIcon: const Icon(LucideIcons.x, size: 12),
                                            onDeleted: () {
                                              setState(() {
                                                _interests.remove(interest);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                          Divider(color: borderCol.withValues(alpha: 0.4), thickness: 0.6, height: 32),

                          // 5. Projects Section
                          _buildSectionCard(
                            title: 'PROJECTS',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._projects.map((proj) {
                                  return GestureDetector(
                                    onTap: () => _navigateToProjectForm(project: proj),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.folder, color: AppTheme.primaryBlue, size: 18),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(proj.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  proj.description,
                                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(LucideIcons.trash2, size: 14, color: Colors.red.shade200),
                                            onPressed: () async {
                                              final confirm = await _showDeleteConfirmationDialog(
                                                title: 'Delete Project',
                                                itemType: 'project',
                                              );
                                              if (confirm) {
                                                setState(() {
                                                  _projects.removeWhere((p) => p.id == proj.id);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                if (_projects.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'No projects added yet.',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => _navigateToProjectForm(),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                  label: const Text('Add Project', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: borderCol.withValues(alpha: 0.4), thickness: 0.6, height: 32),

                          // 6. Generic Links Section
                          _buildSectionCard(
                            title: 'LINKS',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._links.map((link) {
                                  return ProfileLinkTile(
                                    link: link,
                                    onTap: () => _navigateToLinkForm(link: link),
                                    onDelete: () async {
                                      final confirm = await _showDeleteConfirmationDialog(
                                        title: 'Delete Link',
                                        itemType: 'link',
                                      );
                                      if (confirm) {
                                        setState(() {
                                          _links.remove(link);
                                        });
                                      }
                                    },
                                  );
                                }),
                                if (_links.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'No links added yet.',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => _navigateToLinkForm(),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                  label: const Text('Add Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Full screen saving loader
            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
