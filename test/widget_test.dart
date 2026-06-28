// Smoke test: the app boots and shows the login screen.

import 'package:flutter_test/flutter_test.dart';

import 'package:parking_app/main.dart';
import 'package:parking_app/screens/login_screen.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Parking Management'), findsOneWidget);
  });
}
