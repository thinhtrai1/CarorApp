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
        onPressed: () {
          Navigator.of(context).push(createRoute(const LoginPage()));
        },
        child: const Text('Please login to enjoy!'),
      ),
    );
  }
}
