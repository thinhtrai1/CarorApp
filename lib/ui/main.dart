import 'package:caror/data/shared_preferences.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'home/home.dart';

void main() async {
  //TODO #HOWTO: Why don't have SystemNavigationBar in iOS?
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  initializeDateFormatting();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MaterialApp(
      title: 'Caror',
      key: App.navigatorKey,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: AppTheme.primaryColor,
        primarySwatch: AppTheme.primarySwatch,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    ),
  );
}
