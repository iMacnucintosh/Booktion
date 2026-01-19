import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:booktion/main.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BooktionApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Booktion'), findsOneWidget);
  });
}
