import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // State variables
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  bool? _usernameAvailable;
  List<String> _suggestions = [];
  Timer? _debounceTimer;

  // Selected assets
  String _selectedAvatarUrl = "";
  String _selectedBannerUrl = "";
  File? _localAvatarFile;
  File? _localBannerFile;

  // Pre-curated premium assets
  final List<String> _presetAvatars = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200"
  ];

  final List<String> _presetBanners = [
    "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1607799279861-4dd421887fb3?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1629654297299-c8506221ca97?auto=format&fit=crop&q=80&w=600",
    "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&q=80&w=600"
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _pageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- STEP 1 LOGIC ---

  void _onFirstNameChanged(String val) {
    if (val.trim().isNotEmpty) {
      _generateSuggestions(val.trim());
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _generateSuggestions(String firstName) {
    // Strip non-alphanumeric and convert to lower
    final cleanName = firstName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (cleanName.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final candidates = [
      cleanName,
      '${cleanName}_dev',
      '${cleanName}01',
      '${cleanName}_codes',
      '${cleanName}_tech',
    ];

    _checkCandidatesAvailability(candidates);
  }

  Future<void> _checkCandidatesAvailability(List<String> candidates) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .inFilter('username', candidates);
      
      final occupied = (res as List).map((r) => r['username'].toString().toLowerCase()).toSet();
      final available = candidates.where((c) => !occupied.contains(c)).toList();

      if (mounted) {
        setState(() {
          _suggestions = available;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = candidates; // Fallback to all if database is not reachable
        });
      }
    }
  }

  void _onUsernameChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    final username = val.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() {
        _usernameAvailable = null;
        _isCheckingUsername = false;
      });
      return;
    }

    // Validate small letters, numbers, and underscores only
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameAvailable = false;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        final res = await Supabase.instance.client
            .from('profiles')
            .select('id')
            .eq('username', username)
            .maybeSingle();
        
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            if (res == null || (user != null && res['id'] == user.id)) {
              _usernameAvailable = true;
            } else {
              _usernameAvailable = false;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _usernameAvailable = null;
          });
        }
      }
    });
  }

  // --- IMAGE PICKER SHEET ---

  void _showImagePickerOptions({required bool isProfile}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Presets'),
                    Tab(text: 'Device Gallery'),
                  ],
                  indicatorColor: AppTheme.primaryBlue,
                  labelColor: AppTheme.primaryBlue,
                ),
                Expanded(
                  child: SizedBox(
                    height: 220,
                    child: TabBarView(
                      children: [
                        // TAB 1: Presets
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isProfile ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: isProfile ? 1.0 : 1.8,
                          ),
                          itemCount: isProfile ? _presetAvatars.length : _presetBanners.length,
                          itemBuilder: (context, index) {
                            final item = isProfile ? _presetAvatars[index] : _presetBanners[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isProfile) {
                                    _selectedAvatarUrl = item;
                                    _localAvatarFile = null;
                                  } else {
                                    _selectedBannerUrl = item;
                                    _localBannerFile = null;
                                  }
                                });
                                Navigator.pop(context);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(isProfile ? 40 : 8),
                                child: Image.network(
                                  item,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                        // TAB 2: Device Gallery
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.image, size: 36, color: AppTheme.primaryBlue),
                                onPressed: () => _pickImageFromGallery(isProfile: isProfile),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Select from device photo library',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _cropImage(String filePath, {required bool isProfile}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatio: isProfile 
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : const CropAspectRatio(ratioX: 3, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isProfile ? 'Crop Profile' : 'Crop Banner',
          toolbarColor: AppTheme.primaryBlue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: isProfile 
              ? CropAspectRatioPreset.square 
              : CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: isProfile ? 'Crop Profile' : 'Crop Banner',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return croppedFile?.path;
  }

  Future<void> _pickImageFromGallery({required bool isProfile}) async {
    Navigator.pop(context); // Close sheet
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isProfile ? 400 : 900,
        maxHeight: isProfile ? 400 : 300,
        imageQuality: isProfile ? 85 : 80,
      );

      if (pickedFile != null) {
        final croppedPath = await _cropImage(pickedFile.path, isProfile: isProfile);
        if (croppedPath != null) {
          setState(() {
            if (isProfile) {
              _localAvatarFile = File(croppedPath);
              _selectedAvatarUrl = "";
            } else {
              _localBannerFile = File(croppedPath);
              _selectedBannerUrl = "";
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting photo: $e')),
        );
      }
    }
  }

  // --- DATABASE SUBMISSION ---

  Future<void> _submitProfile({required bool isSkipped}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Session expired. Please log in again.");

      final name = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      final username = _usernameController.text.trim().toLowerCase();

      // Upload local images to Supabase Storage if selected, otherwise fallback to presets/URLs
      String avatarUrl = _selectedAvatarUrl;
      String bannerUrl = _selectedBannerUrl;

      if (!isSkipped) {
        final appState = Provider.of<AppState>(context, listen: false);
        if (_localAvatarFile != null) {
          try {
            avatarUrl = await appState.uploadProfileImage(_localAvatarFile!, isProfile: true);
          } catch (e) {
            throw Exception("Failed to upload avatar to Supabase Storage. Please ensure you have created a public bucket named 'avatars' in your Supabase storage dashboard. Error: $e");
          }
        }
        if (_localBannerFile != null) {
          try {
            bannerUrl = await appState.uploadProfileImage(_localBannerFile!, isProfile: false);
          } catch (e) {
            throw Exception("Failed to upload banner to Supabase Storage. Please ensure you have created a public bucket named 'avatars' in your Supabase storage dashboard. Error: $e");
          }
        }
      }

      if (avatarUrl.isEmpty) {
        // Fallback default avatar
        avatarUrl = 'https://api.dicebear.com/7.x/bottts/png?seed=${user.id}';
      }

      // Upsert user profile row in database
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'username': username,
        'bio': 'Joined Devs community!',
        'email': user.email,
        'avatar_url': avatarUrl,
        'banner_image': bannerUrl.isEmpty ? 'grid_default' : bannerUrl,
      });

      // Load updated user details inside State Provider
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.loadUserProfile();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- STEP SWITCH NAVIGATION ---

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    if (_usernameAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or type an available username.')),
      );
      return;
    }
    
    setState(() {
      _currentStep = 1;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // --- UI BUILDING BLOCKS ---

  Widget _buildCircularProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: _currentStep == 0 ? 0.5 : 1.0,
              strokeWidth: 2.5,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          Text(
            _currentStep == 0 ? '1/2' : '2/2',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Enter your first name',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This helps people identify you inside the community.',
              style: TextStyle(fontSize: 13, color: textSecondary.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 28),
            
            // Name Fields Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                border: Border.all(color: borderCol, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  AuthTextField(
                    controller: _firstNameController,
                    hintText: 'First Name',
                    prefixIcon: Icons.badge_outlined,
                    onChanged: _onFirstNameChanged,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'First name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _lastNameController,
                    hintText: 'Last Name (Optional)',
                    prefixIcon: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Username Label & Availability Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose a Username',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                if (_isCheckingUsername)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
                  )
                else if (_usernameAvailable != null)
                  Text(
                    _usernameAvailable! ? '✓ Available' : '✗ Already taken / Invalid',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _usernameAvailable! ? Colors.green : Colors.redAccent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Username field Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                border: Border.all(color: borderCol, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    prefixIcon: Icons.alternate_email_rounded,
                    onChanged: _onUsernameChanged,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Username is required';
                      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(val.trim().toLowerCase())) {
                        return 'Only small letters, numbers, and underscores allowed';
                      }
                      return null;
                    },
                  ),
                  
                  // Username Suggestion list chips
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSuggestionChips(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            'Available usernames:',
            style: TextStyle(
              fontSize: 11,
              color: textSecondary.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              final isSelected = _usernameController.text == suggestion;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _usernameController.text = suggestion;
                      setState(() {
                        _usernameAvailable = true;
                      });
                    }
                  },
                  backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5),
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 0.8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Set up your profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add photos to personalize your account style.',
            style: TextStyle(fontSize: 13, color: textSecondary.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 28),

          // Banner Image Container Card
          Text(
            'Profile Banner',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textSecondary),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImagePickerOptions(isProfile: false),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9),
                border: Border.all(color: borderCol),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_localBannerFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_localBannerFile!, width: double.infinity, height: 120, fit: BoxFit.cover),
                    )
                  else if (_selectedBannerUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(_selectedBannerUrl, width: double.infinity, height: 120, fit: BoxFit.cover),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: (_localBannerFile != null || _selectedBannerUrl.isNotEmpty) ? 0.3 : 0.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Icon(
                    LucideIcons.camera,
                    color: (_localBannerFile != null || _selectedBannerUrl.isNotEmpty) ? Colors.white70 : textSecondary.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Profile Image Picker
          Center(
            child: Column(
              children: [
                Text(
                  'Profile Picture',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textSecondary),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showImagePickerOptions(isProfile: true),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: 'avatar_hero',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9),
                            border: Border.all(color: borderCol, width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: _localAvatarFile != null
                                ? Image.file(_localAvatarFile!, width: 100, height: 100, fit: BoxFit.cover)
                                : _selectedAvatarUrl.isNotEmpty
                                    ? Image.network(_selectedAvatarUrl, width: 100, height: 100, fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : 'D',
                                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          _buildCircularProgressIndicator(),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient circles
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),

                // FIXED BOTTOM BUTTONS WRAPPER
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_currentStep == 0)
                          AuthButton(
                            text: 'Next',
                            onPressed: _nextStep,
                          )
                        else ...[
                          // Skip button
                          TextButton(
                            onPressed: _isLoading ? null : () => _submitProfile(isSkipped: true),
                            child: Text(
                              'Skip picture setup',
                              style: TextStyle(
                                color: textSecondary.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthButton(
                            text: 'Continue',
                            onPressed: () => _submitProfile(isSkipped: false),
                            isLoading: _isLoading,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
