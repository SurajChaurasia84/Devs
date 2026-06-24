import 'package:flutter_test/flutter_test.dart';
import 'package:devs/main.dart';

void main() {
  testWidgets('Devs app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isDarkMode: true));

    // Verify that "Devs" logo or text is rendered in the UI.
    expect(find.text('Devs'), findsWidgets);
  });
}
