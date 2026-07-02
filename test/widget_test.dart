import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devs/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeGoTrueClient extends GoTrueClient {
  FakeGoTrueClient() : super(autoRefreshToken: false);

  @override
  Stream<AuthState> get onAuthStateChange => Stream.value(
        AuthState(AuthChangeEvent.initialSession, null),
      );

  @override
  User? get currentUser => null;
}

class FakeSupabaseClient extends SupabaseClient {
  FakeSupabaseClient()
      : super(
          'https://gjyjvetyuqunkohmichl.supabase.co',
          'mockKey',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );

  @override
  late final auth = FakeGoTrueClient();
}

void main() {
  testWidgets('Devs app smoke test', (WidgetTester tester) async {
    // Initialize standard Supabase instance first so that Supabase.instance doesn't throw.
    await Supabase.initialize(
      url: 'https://gjyjvetyuqunkohmichl.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqeWp2ZXR5dXF1bmtvaG1pY2hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTE1NDEsImV4cCI6MjA5Nzg2NzU0MX0.oFhF_cMQXeYk5h5wbLLKm9YUhDpF0YUGUmuPKgMmKfI',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
      ),
    );

    // Override the client with our Fake version to mock stream and prevent network hangs
    Supabase.instance.client = FakeSupabaseClient();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.dark));

    // Allow internal streams to emit and the state to settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that "Welcome Back" is rendered in the UI on the auth screen.
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
