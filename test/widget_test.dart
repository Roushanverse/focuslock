import 'package:flutter_test/flutter_test.dart';
import 'package:focuslock/main.dart';

void main() {
  testWidgets('FocusLock app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusLockApp());
    // Verify splash screen appears
    expect(find.text('FocusLock'), findsOneWidget);
  });
}
