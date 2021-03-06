import 'package:flutter/services.dart';
import 'package:web/main_tabs/main_tabs.dart';
import 'package:web/utils/authentication.dart';
import 'package:web/utils/styles.dart';
import 'package:web/utils/validation.dart';
import 'package:web/utils/custom_widgets.dart';
import 'package:flutter/material.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  _SignUpWidgetState();

  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool _registerFailed = false;
  String _feedback = '';
  bool _validationActivated = false;
  late String _name, _email, _password, _phone;
  final passwordOneController = TextEditingController();

  final FocusNode _passwordOneFocusNode = FocusNode();
  final FocusNode _passwordTwoFocusNode = FocusNode();

  void _toggleVisiblePassword() {
    setState(() {
      _visiblePassword = !_visiblePassword;
    });
  }

  void _onFieldChanged() {
    if (_registerFailed) {
      setState(() {
        _registerFailed = false;
      });
    }

    if (_validationActivated) {
      _formKey.currentState!.save();
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Form(
            key: _formKey,
            child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle,
                        size: 130, color: Colors.black),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        key: const Key('inputName'),
                        textCapitalization: TextCapitalization.words,
                        validator: (input) => validateName(input!.trim()),
                        onSaved: (input) => _name = input!.trim(),
                        onChanged: (_) {
                          _onFieldChanged();
                        },
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) => _createUserAndSignIn(),
                        decoration: customInputDecoration(
                            labelText: 'Fullt navn', icon: Icons.badge)),
                    const InputFieldSpacer(),
                    TextFormField(
                        key: const Key('inputEmail'),
                        validator: (input) => validateEmail(input),
                        onSaved: (input) => _email = input.toString(),
                        onChanged: (_) {
                          _onFieldChanged();
                        },
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) => _createUserAndSignIn(),
                        decoration: customInputDecoration(
                            labelText: 'E-post', icon: Icons.mail)),
                    const InputFieldSpacer(),
                    RawKeyboardListener(
                        focusNode: _passwordOneFocusNode,
                        onKey: (RawKeyEvent event) {
                          if (event.logicalKey == LogicalKeyboardKey.tab) {
                            _passwordOneFocusNode.nextFocus();
                          }
                        },
                        child: TextFormField(
                            controller: passwordOneController,
                            key: const Key('inputPasswordOne'),
                            validator: (input) => validatePassword(input),
                            onSaved: (input) => _password = input.toString(),
                            onChanged: (_) {
                              _onFieldChanged();
                            },
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (value) => _createUserAndSignIn(),
                            obscureText: !_visiblePassword,
                            decoration: customInputDecoration(
                                labelText: 'Passord',
                                icon: Icons.lock,
                                passwordField: true,
                                isVisible: _visiblePassword,
                                onPressed: _toggleVisiblePassword))),
                    const InputFieldSpacer(),
                    RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          if (event.logicalKey == LogicalKeyboardKey.tab) {
                            _passwordTwoFocusNode.nextFocus();
                          }
                        },
                        child: TextFormField(
                            key: const Key('inputPasswordTwo'),
                            focusNode: _passwordTwoFocusNode,
                            validator: (input) => validatePasswords(
                                passwordOneController.text, input),
                            onChanged: (_) {
                              _onFieldChanged();
                            },
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (value) => _createUserAndSignIn(),
                            obscureText: !_visiblePassword,
                            decoration: customInputDecoration(
                                labelText: 'Gjenta passord',
                                icon: Icons.lock,
                                passwordField: true,
                                isVisible: _visiblePassword,
                                onPressed: _toggleVisiblePassword))),
                    const InputFieldSpacer(),
                    TextFormField(
                        key: const Key('inputPhone'),
                        validator: (input) => validatePhone(input),
                        onSaved: (input) => _phone = input.toString(),
                        onChanged: (_) {
                          _onFieldChanged();
                        },
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) => _createUserAndSignIn(),
                        decoration: customInputDecoration(
                            labelText: 'Telefon', icon: Icons.phone)),
                    const InputFieldSpacer(),
                    AnimatedOpacity(
                      opacity: _registerFailed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _feedback,
                        key: const Key('feedback'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: _createUserAndSignIn,
                        child: const Text('Opprett brukerkonto',
                            style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(250, 60)))
                  ],
                ))));
  }

  void _createUserAndSignIn() async {
    final formState = _formKey.currentState;

    setState(() {
      _validationActivated = true;
    });

    if (formState!.validate()) {
      formState.save();
      try {
        String? response = await createUser(
            name: _name, email: _email, password: _password, phone: _phone);

        setState(() {
          _registerFailed = response == null ? false : true;
          _feedback = response ?? '';
        });
        if (response == null) {
          Navigator.pushNamed(context, MainTabs.route);
        }
      } catch (e) {
        _feedback = 'Kunne ikke opprette bruker';
        if (mounted) {
          setState(() {
            _validationActivated = true;
            _registerFailed = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    passwordOneController.dispose();
    _passwordOneFocusNode.dispose();
    _passwordTwoFocusNode.dispose();
    super.dispose();
  }
}
