// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:campy/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampyApp());
    // Verifikasi bahwa app dapat di-render tanpa error
    expect(find.byType(CampyApp), findsOneWidget);
  });
}
