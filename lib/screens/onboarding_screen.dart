import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("No active session found.");
      }

      final name = _nameController.text.trim();
      final username = _usernameController.text.trim().toLowerCase();
      final bio = _bioController.text.trim();

      // 1. Check uniqueness of username in Supabase profiles table
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (res != null && res['id'] != user.id) {
        throw Exception("Username '$username' is already taken.");
      }

      // 2. Upsert the profile row
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'username': username,
        'bio': bio,
        'email': user.email,
        'avatar_url': 'https://api.dicebear.com/7.x/bottts/png?seed=${user.id}',
      });

      // 3. Load user profile in AppState
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
        String errMsg = e.toString().replaceAll("Exception:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // Ambient Background Blurred Circles (Notion/Linear style)
          if (isDark) ...[
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5),
                              border: Border.all(color: borderCol, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.rocket_launch_outlined,
                              color: AppTheme.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tell the developer community a bit about yourself.',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Card Form Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                          border: Border.all(color: borderCol, width: 1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _nameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.badge_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _usernameController,
                              hintText: 'Username',
                              prefixIcon: Icons.alternate_email_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Username is required';
                                }
                                if (val.trim().length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val.trim())) {
                                  return 'Username can only contain letters, numbers, and underscores';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _bioController,
                              hintText: 'Short Bio (e.g. Flutter Developer | Designer)',
                              prefixIcon: Icons.info_outline,
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Bio is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              text: 'Complete Profile & Enter',
                              onPressed: _completeOnboarding,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
