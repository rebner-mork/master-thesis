import 'package:app/register_user/register_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_setup.dart';

const _email = 'testregister@gmail.com';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await firebaseSetup();

  testWidgets('Integration test register', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterUserPage()));

    var registerButton = find.text('Opprett bruker');
    var emailField = find.byKey(const Key('inputEmail'));
    var passwordOneField = find.byKey(const Key('inputPasswordOne'));
    var passwordTwoField = find.byKey(const Key('inputPasswordTwo'));
    var phoneField = find.byKey(const Key('inputPhone'));

    // Assert user does not exist
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: password);
      fail('signIn did not throw exception as expected');
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') {
        fail('User already exists');
      }
    }

    // Register user
    await tester.enterText(emailField, _email);
    await tester.enterText(passwordOneField, password);
    await tester.enterText(passwordTwoField, password);
    await tester.enterText(phoneField, phone);

    await tester.tap(registerButton);
    await tester.pump(const Duration(seconds: 2));

    // Assert user is signed in
    expect(FirebaseAuth.instance.currentUser, isNotNull);

    // Assert phone number exists
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot user = await users.where('email', isEqualTo: _email).get();

    expect(user.docs.first.get('phone'), phone);
  });
}
