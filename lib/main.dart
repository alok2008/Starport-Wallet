import 'package:flutter/material.dart';
import 'package:flutter_app/global.dart';
import 'package:flutter_app/views/mnemonic_onboarding.dart';

void main() {
  var port =
      const String.fromEnvironment('PORT', defaultValue: '1317');
  var lcdUrl =
      const String.fromEnvironment('BASE_LCD_URL', defaultValue: 'localhost');

  baseEnv.setEnv(lcdUrl, port);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder()
        )
      ),
      home: MnemonicOnboarding(),
    );
  }
}
