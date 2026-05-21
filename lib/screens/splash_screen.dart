import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_webview_screen.dart'; // ایمپورت صفحه وب‌ویو

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInternet = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    setState(() {
      _isChecking = true;
      _hasInternet = true;
    });

    // چک کردن اتصال اینترنت
    try {
      final result = await InternetAddress.lookup('esalatcar.ir');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // اینترنت وصل است
        _navigateToNextScreen();
      } else {
        _showNoInternet();
      }
    } on SocketException catch (_) {
      // اینترنت قطع است
      _showNoInternet();
    }
  }

  void _navigateToNextScreen() async {
    await ApiService.loadSessionCookie();
    
    // تاخیر کوتاه برای نمایش لوگو
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (ApiService.isLoggedIn) {
      // اگر کوکی سشن داشت، برو صفحه داشبورد سایت (وب‌ویو)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardWebviewScreen()));
    } else {
      // اگر نداشت، برو صفحه لاگین فلاتر
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _showNoInternet() {
    if (!mounted) return;
    setState(() {
      _hasInternet = false;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_repair, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('اصالت خودرو', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
            const SizedBox(height: 40),
            
            if (_isChecking && _hasInternet)
              const CircularProgressIndicator(color: Colors.white),
              
            if (!_hasInternet) ...[
              const Icon(Icons.wifi_off, size: 60, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                'اتصال اینترنت خود را بررسی کنید',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Peyda'),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _startApp, // تلاش مجدد
                icon: const Icon(Icons.refresh, color: Colors.blue.shade900),
                label: const Text('تلاش مجدد', style: TextStyle(color: Colors.blue.shade900, fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}