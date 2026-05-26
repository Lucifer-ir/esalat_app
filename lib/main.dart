// lib/main.dart
import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/auth_screen.dart';

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
      theme: AppTheme.lightTheme, // اعتم تم یکدست و فونت پیودا
      home: const AuthScreen(), // شروع از صفحه لاگین
    );
  }
}