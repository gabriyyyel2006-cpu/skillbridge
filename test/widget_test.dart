
import 'package:flutter_test/flutter_test.dart';
import 'package:skillbridge/main.dart';

void main() {
  testWidgets('SkillBridge app loads successfully', (WidgetTester tester) async {
    // Launch the SkillBridge application.
    await tester.pumpWidget(const SkillBridgeApp());

    // Verify that the registration screen is displayed.
    expect(find.text('SkillBridge'), findsOneWidget);
  });
}
