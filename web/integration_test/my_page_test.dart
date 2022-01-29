import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/my_page/my_page.dart';

import 'firebaseSetup.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await firebaseSetup();

  testWidgets('Initial layout and content', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyPage()));

    expect(find.text('Gård'), findsOneWidget);
    expect(find.text('Øremerker'), findsOneWidget);
    expect(find.text('Slips'), findsOneWidget);
    expect(find.text('Oppsynspersonell'), findsOneWidget);

    expect(find.byIcon(Icons.gite), findsOneWidget);
    expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    expect(find.byIcon(Icons.groups_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.groups_outlined), findsNothing);
    expect(find.byIcon(Icons.groups), findsOneWidget);
  });
}
