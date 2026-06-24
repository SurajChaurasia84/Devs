import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  // Password strength tracking
  double _passwordStrength = 0.0;
  String _passwordStrengthText = "";
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = "";
      });
      return;
    }

    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthText = "Weak";
        _passwordStrengthColor = Colors.redAccent;
      } else if (strength <= 0.75) {
        _passwordStrengthText = "Medium";
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = "Strong";
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // --- LOGIN FLOW ---
        final identifier = _loginIdentifierController.text.trim();
        final password = _loginPasswordController.text;
        String email = identifier;
        bool profileExists = false;

        // Check if input is a Username (does not contain @)
        if (!identifier.contains('@')) {
          final res = await Supabase.instance.client
              .from('profiles')
              .select('email')
              .eq('username', identifier.toLowerCase())
              .maybeSingle();

          if (res == null || res['email'] == null) {
            throw Exception("No account found for this username. Please create one.");
          }
          email = res['email'] as String;
          profileExists = true;
        } else {
          // Check if this email exists in profiles
          final res = await Supabase.instance.client
              .from('profiles')
              .select('id')
              .eq('email', identifier.toLowerCase())
              .maybeSingle();
          profileExists = res != null;
        }

        // Perform Sign In
        AuthResponse response;
        try {
          response = await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } on AuthException catch (e) {
          if (e.message.contains("Invalid login credentials")) {
            if (profileExists) {
              throw Exception("Incorrect password.");
            } else {
              throw Exception("No account found. Please create one.");
            }
          }
          rethrow;
        }

        if (response.user != null && mounted) {
          // Check if profile exists and is complete
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('name, username')
              .eq('id', response.user!.id)
              .maybeSingle();

          if (mounted) {
            final hasCompleteProfile = profile != null && 
                profile['name'] != null && 
                profile['name'].toString().isNotEmpty && 
                profile['username'] != null && 
                profile['username'].toString().isNotEmpty;

            if (hasCompleteProfile) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              );
            }
          }
        }
      } else {
        // --- SIGN UP FLOW ---
        final email = _signupEmailController.text.trim();
        final password = _signupPasswordController.text;

        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null && mounted) {
          // Show confirmation message
          final isConfirmRequired = response.session == null; // session is null if email confirmation is required
          
          if (isConfirmRequired) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                title: const Text('Confirm Email', style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text(
                  'A confirmation link has been sent to your email. Please click it to complete registration, then log in here.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isLogin = true;
                      });
                    },
                    child: const Text('OK', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          } else {
            // Instantly logged in (email confirmation disabled in Supabase settings)
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString().replaceAll("Exception:", "").trim();
        if (errMsg.contains("Invalid login credentials")) {
          errMsg = "Incorrect password or email/username.";
        }
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
          // 1. Ambient Background Blurred Circles (Notion/Linear style)
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
            Positioned(
              bottom: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          
          // 2. Main Content
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
                          // App Logo Minimal Representation
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5),
                              border: Border.all(color: borderCol, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.code_rounded,
                              color: AppTheme.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isLogin 
                                ? 'Sign in to access your developer feed.' 
                                : 'Join the modern ecosystem built for devs.',
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
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _isLogin ? _buildLoginFields() : _buildSignupFields(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toggle Auth Method Bottom Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? "Don't have an account? " : "Already have an account? ",
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _formKey.currentState?.reset();
                              });
                            },
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Log In',
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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

  List<Widget> _buildLoginFields() {
    return [
      AuthTextField(
        controller: _loginIdentifierController,
        hintText: 'Email or Username',
        prefixIcon: Icons.person_outline,
        keyboardType: TextInputType.emailAddress,
        validator: (val) => val == null || val.trim().isEmpty ? 'Enter email or username' : null,
      ),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _loginPasswordController,
        hintText: 'Password',
        prefixIcon: Icons.lock_outline,
        isPassword: true,
        validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
      ),
      const SizedBox(height: 12),
      
      // Forgot Password trigger
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forgot Password flow coming soon!')),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      const SizedBox(height: 16),
      
      AuthButton(
        text: 'Sign In',
        onPressed: _handleAuth,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildSignupFields() {
    return [
      AuthTextField(
        controller: _signupEmailController,
        hintText: 'Email Address',
        prefixIcon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Email is required';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
            return 'Enter a valid email address';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _signupPasswordController,
        hintText: 'Password',
        prefixIcon: Icons.lock_outline,
        isPassword: true,
        onChanged: _calculatePasswordStrength,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Password is required';
          if (val.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
      
      // Dynamic password strength bar
      if (_signupPasswordController.text.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 3.5,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _passwordStrengthText,
              style: TextStyle(color: _passwordStrengthColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
      const SizedBox(height: 16),
      AuthTextField(
        controller: _signupConfirmPasswordController,
        hintText: 'Confirm Password',
        prefixIcon: Icons.lock_outline,
        isPassword: true,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Confirm password is required';
          if (val != _signupPasswordController.text) return 'Passwords do not match';
          return null;
        },
      ),
      const SizedBox(height: 24),
      AuthButton(
        text: 'Create Account',
        onPressed: _handleAuth,
        isLoading: _isLoading,
      ),
    ];
  }
}
