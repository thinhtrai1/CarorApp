import 'package:caror/themes/theme.dart';
import 'package:caror/ui/login/login.dart';
import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(createRoute(const LoginPage()));
        },
        child: const Text('Login and enjoy now!'),
      ),
    );
  }
}
