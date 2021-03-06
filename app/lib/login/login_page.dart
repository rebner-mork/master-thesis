import 'package:app/login/login_widget.dart';
import 'package:app/sign_up/sign_up_page.dart';
import 'package:app/trip/start_trip_page.dart';
import 'package:app/utils/other.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String route = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  bool _isConnectivityCheckComplete = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isConnectivityCheckComplete) {
      _connectionStartUpRoutine();
    }
  }

  Future<void> _connectionStartUpRoutine() async {
    bool isConnected = await isConnectedToInternet();
    if (!isConnected) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const StartTripPage(isOfflineMode: true)));
    }
    _isConnectivityCheckComplete = true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FractionallySizedBox(
      widthFactor: 0.65,
      child: Column(
        children: [
          const Spacer(flex: 3),
          const Flexible(
            child: LoginWidget(),
            flex: 12,
          ),
          Flexible(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, SignUpPage.route);
                },
                child: const Text('Registrer ny bruker')),
            flex: 2,
          )
        ],
      ),
    ));
  }
}
