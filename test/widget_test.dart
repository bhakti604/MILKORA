import 'package:flutter_test/flutter_test.dart';
import 'package:milkora_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MilkoraApp initialization test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MilkoraApp());
    await tester.pumpAndSettle();

    // Verify that MILKORA welcome screen renders with Get Started button
    expect(find.text('Get Started'), findsOneWidget);
  });
}
