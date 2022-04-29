import 'package:caror/generated/l10n.dart';
import 'package:caror/ui/register/register.dart';
import 'package:flutter/material.dart';

import '../../data/data_service.dart';
import '../../data/shared_preferences.dart';
import '../../themes/theme.dart';
import '../../widget/widget.dart';
import '../home/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final _usernameController = TextEditingController(text: 'thinhtrai1');
  final _passwordController = TextEditingController(text: '1');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackgroundContainer(
        padding: const EdgeInsets.only(left: 32, right: 32),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 64),
              CommonTitleText(S.current.sign_in),
              const SizedBox(height: 32),
              LoginTextFieldBackground(
                controller: _usernameController,
                label: S.current.username,
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
                    labelText: S.current.password,
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text(
                    S.current.forgot_password,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 32),
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
                child: Text(
                  S.current.sign_in,
                  style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  _doValidate();
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                child: Text(S.current.or_register_an_account),
                onPressed: () => Navigator.of(context).push(createRoute(const RegisterPage())),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  _doValidate() {
    if (_usernameController.text.trim().isEmpty) {
      showToast(S.current.please_enter_password);
      return;
    } else if (_passwordController.text.trim().isEmpty) {
      showToast(S.current.please_enter_password);
      return;
    }
    _login(_usernameController.text.trim(), _passwordController.text.trim());
  }

  _login(String username, String password) {
    showLoading(context, message: S.current.signing_in);
    DataService.login(username, password).then((user) {
      Navigator.pop(context);
      if (user != null) {
        AppPreferences.setAccessToken(user.token);
        AppPreferences.setUsername(username);
        AppPreferences.setPassword(password);
        Navigator.pushAndRemoveUntil(
          context,
          createRoute(const HomePage(loginState: LoginState.loggedIn)),
          (route) => false,
        );
      }
    });
  }
}
