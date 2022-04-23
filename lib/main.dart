import 'package:caror/data/shared_preferences.dart';
import 'package:caror/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ui/home/home.dart';

void main() async {
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await AppPreferences.init();

  //TODO #HOWTO: Why don't have SystemNavigationBar in iOS?
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
