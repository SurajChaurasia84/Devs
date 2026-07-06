import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/mock_data.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gjyjvetyuqunkohmichl.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqeWp2ZXR5dXF1bmtvaG1pY2hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTE1NDEsImV4cCI6MjA5Nzg2NzU0MX0.oFhF_cMQXeYk5h5wbLLKm9YUhDpF0YUGUmuPKgMmKfI',
  );

  final prefs = await SharedPreferences.getInstance();
  final themeModeString = prefs.getString('theme_mode');
  ThemeMode initialThemeMode = ThemeMode.system;
  if (themeModeString == 'dark') {
    initialThemeMode = ThemeMode.dark;
  } else if (themeModeString == 'light') {
    initialThemeMode = ThemeMode.light;
  }

  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(initialThemeMode: initialThemeMode),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final isDark = appState.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ));
          return MaterialApp(
            title: 'Devs',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: StreamBuilder<AuthState>(
              stream: Supabase.instance.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                      ),
                    ),
                  );
                }

                final session = snapshot.data?.session;
                if (session == null) {
                  return const AuthScreen();
                }

                // User is authenticated, check if their profile is complete
                return ProfileCheckScreen(userId: session.user.id);
              },
            ),
          );
        },
      ),
    );
  }
}

class ProfileCheckScreen extends StatefulWidget {
  final String userId;
  const ProfileCheckScreen({super.key, required this.userId});

  @override
  State<ProfileCheckScreen> createState() => _ProfileCheckScreenState();
}

class _ProfileCheckScreenState extends State<ProfileCheckScreen> {
  late Future<bool> _profileCheckFuture;

  @override
  void initState() {
    super.initState();
    _profileCheckFuture = Provider.of<AppState>(context, listen: false)
        .checkAndLoadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileCheckFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
          );
        }

        final hasProfile = profileSnapshot.data ?? false;
        if (hasProfile) {
          return const MainNavigationScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

