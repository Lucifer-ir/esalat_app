import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _checkConnectionAndAuth();
  }

  Future<void> _checkConnectionAndAuth() async {
    setState(() { _hasError = false; });
    try {
      // تست اتصال به سرور شما
      final response = await http.get(Uri.parse('https://esalatcar.ir/api.php')).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('user_token');
        
        // اگر توکن بود برو صفحه اصلی، اگر نبود برو لاگین
        if (token != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      } else {
        setState(() { _hasError = true; _errorMsg = 'خطا در پاسخگویی سرور'; });
      }
    } catch (e) {
      setState(() { _hasError = true; _errorMsg = 'اتصال ناموفق؛ اینترنت خود را بررسی کنید'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('اصالت خودرو', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            if (_hasError) ...[
              Text(_errorMsg, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _checkConnectionAndAuth,
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
              )
            ] else ...[
              const CircularProgressIndicator(color: Colors.white),
            ]
          ],
        ),
      ),
    );
  }
}