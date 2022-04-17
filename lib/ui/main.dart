import 'package:caror/data/data_service.dart';
import 'package:caror/data/shared_preferences.dart';
import 'package:caror/themes/theme.dart';
import 'package:caror/widget/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caror',
      key: App.navigatorKey,
      theme: ThemeData(fontFamily: 'Montserrat', primaryColor: AppTheme.primaryColor, primarySwatch: AppTheme.primarySwatch),
      home: const LoginPage(title: 'Caror'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final _emailController = TextEditingController(text: 'thinhtrai1');
  final _passwordController = TextEditingController(text: '1');
  var _showLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: "Email",
                    ),
                    style: const TextStyle(fontFamily: "Montserrat"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      style: const TextStyle(fontFamily: "Montserrat"),
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Password",
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text(
                        "Forgot password?",
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: CupertinoButton.filled(
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Montserrat"),
                        ),
                      ),
                      onPressed: () {
                        _login(_emailController.text, _passwordController.text);
                      },
                    ),
                  ),
                  CupertinoButton.filled(
                    child: const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Scan without account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: "Montserrat"),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(createRoute(const HomePage()));
                    },
                  ),
                  TextButton(
                    child: const Text("Or register an account"),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            if (_showLoading) SimpleProgressBar(),
          ],
        ),
      ),
    );
  }

  _login(String username, String password) {
    setState(() {
      _showLoading = true;
    });
    DataService.login(username, password).then((user) {
      if (user != null) {
        toast('Welcome ' + user.lastName);
        AppPreferences.setAccessToken(user.token);
        Navigator.pushAndRemoveUntil(context, createRoute(const HomePage()), (route) => false,);
      }
      setState(() {
        _showLoading = false;
      });
    });
  }
}
