import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_webview_screen.dart';

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

    try {
      final result = await InternetAddress.lookup('esalatcar.ir');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _navigateToNextScreen();
      } else {
        _showNoInternet();
      }
    } on SocketException catch (_) {
      _showNoInternet();
    }
  }

  void _navigateToNextScreen() async {
    await ApiService.loadSessionCookie();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (ApiService.isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardWebviewScreen()));
    } else {
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
                onPressed: _startApp,
                // حذف کلمه const به دلیل استفاده از shade900
                icon: Icon(Icons.refresh, color: Colors.blue.shade900),
                label: Text('تلاش مجدد', style: TextStyle(color: Colors.blue.shade900, fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
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