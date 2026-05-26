// lib/main.dart
import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart'; // تغییر مسیر به اسپلش

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اصالت خودرو',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // شروع از صفحه اسپلش و لودینگ اولیه
    );
  }
}