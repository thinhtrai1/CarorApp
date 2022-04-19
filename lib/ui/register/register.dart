import 'package:caror/themes/util.dart';
import 'package:caror/ui/login/login.dart';
import 'package:flutter/material.dart';

import '../../data/data_service.dart';
import '../../data/shared_preferences.dart';
import '../../themes/theme.dart';
import '../../widget/widget.dart';
import '../home/home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPagePageState();
}

class _RegisterPagePageState extends State<RegisterPage> {
  bool _passwordVisible = false;
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _firstnameController = TextEditingController(text: '');
  final _lastnameController = TextEditingController(text: '');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackgroundContainer(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 64),
        headerHeight: 120,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const CommonTitleText('Sign Up'),
              const SizedBox(height: 32),
              LoginTextFieldBackground(
                controller: _usernameController,
                label: 'Username',
              ),
              const SizedBox(height: 16),
              LoginTextFieldBackground(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontFamily: "Montserrat"),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LoginTextFieldBackground(
                controller: _emailController,
                label: 'Email',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    child: LoginTextFieldBackground(
                      controller: _firstnameController,
                      label: 'Firstname',
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: LoginTextFieldBackground(
                      controller: _lastnameController,
                      label: 'Lastname',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 56),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  _doValidate();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _doValidate() {
    if (_usernameController.text.trim().isEmpty) {
      showToast('Please enter username!');
      return;
    } else if (_passwordController.text.trim().isEmpty) {
      showToast('Please enter password!');
      return;
    } else if (_emailController.text.trim().isEmpty) {
      showToast('Please enter email!');
      return;
    } else if (!isValidEmail(_emailController.text.trim())) {
      showToast('Please enter valid email!');
      return;
    } else if (_firstnameController.text.trim().isEmpty) {
      showToast('Please enter firstname!');
      return;
    } else if (_lastnameController.text.trim().isEmpty) {
      showToast('Please enter lastname!');
      return;
    }
    _register(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
      _emailController.text.trim(),
      _firstnameController.text.trim(),
      _lastnameController.text.trim(),
    );
  }

  _register(String username, String password, email, firstname, lastname) {
    showLoading(context, message: 'Signing up...');
    DataService.register(username, password, email, firstname, lastname).then((user) {
      Navigator.pop(context);
      if (user != null) {
        AppPreferences.setAccessToken(user.token);
        Navigator.pushAndRemoveUntil(
          context,
          createRoute(const HomePage()),
          (route) => false,
        );
      }
    });
  }
}
