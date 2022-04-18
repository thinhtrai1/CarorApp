import 'package:caror/data/shared_preferences.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
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
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: AppTheme.primaryColor,
        primarySwatch: AppTheme.primarySwatch,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}
