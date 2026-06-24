import 'package:flutter/material.dart';
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
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(initialDarkMode: isDarkMode),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Devs',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
                return FutureBuilder<bool>(
                  future: Provider.of<AppState>(context, listen: false)
                      .checkAndLoadProfile(session.user.id),
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
              },
            ),
          );
        },
      ),
    );
  }
}
