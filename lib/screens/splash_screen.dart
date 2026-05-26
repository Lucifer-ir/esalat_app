// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // بعد از ۳ ثانیه میره به صفحه ورود
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary, // پس‌زمینه آبی اصلی
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          // لوگو سفید وسط صفحه
          Icon(Icons.directions_car, size: 100, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'اصالت خودرو',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Peyda',
            ),
          ),
          Spacer(),
          // لودینگ سه نقطه سفید در پایین صفحه
          Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ],
      ),
    );
  }
}