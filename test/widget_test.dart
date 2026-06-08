
import 'package:flutter_test/flutter_test.dart';
import 'package:santriku_app/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SantrikuApp());

    // Verify the login screen is displayed
    expect(find.text('Santriku'), findsOneWidget);
    expect(find.text('Masuk sebagai'), findsOneWidget);
  });
}
