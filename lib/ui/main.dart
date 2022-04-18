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
      home: const HomePage(),
    );
  }
}
