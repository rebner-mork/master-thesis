import 'package:app/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_setup.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await firebaseSetup(createUser: true);

  testWidgets('Integration test login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    var emailField = find.byKey(const Key('inputEmail'));
    var passwordField = find.byKey(const Key('inputPassword'));
    var loginButton = find.text('Logg inn');

    // Assert user is not logged in
    expect(FirebaseAuth.instance.currentUser, null);

    // Enter login information and log in
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.tap(loginButton);
    await tester.pump(const Duration(seconds: 2));

    // Assert user is logged in
    expect(FirebaseAuth.instance.currentUser, isNotNull);
    expect(FirebaseAuth.instance.currentUser, const TypeMatcher<User>());
  });
}
