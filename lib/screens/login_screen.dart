import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // چک کردن اینکه آیا کاربر قبلاً لاگین کرده یا نه
  }

  // اگر توکن ذخیره شده باشد، مستقیم وارد صفحه اصلی شو
  void _checkIfLoggedIn() async {
    await ApiService.loadToken();
    if (ApiService._token != null) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const HomeScreen())
      );
    }
  }

  void _login() async {
    setState(() => _isLoading = true);
    
    var result = await ApiService.login(_usernameController.text, _passwordController.text);
    
    setState(() => _isLoading = false);

    if (result['success']) {
      // هدایت به صفحه اصلی
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // نمایش ارور
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'خطا در ورود', style: const TextStyle(fontFamily: 'Vazir')), 
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              // کادر شیشه ای با افکت Blur واقعی
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // افکت تار کردن پس زمینه
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), // شفافیت کادر
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.car_repair, size: 70, color: Colors.white),
                        const SizedBox(height: 15),
                        const Text('اصالت خودرو', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
                        const SizedBox(height: 5),
                        const Text('برای ادامه وارد حساب خود شوید', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Vazir')),
                        const SizedBox(height: 30),
                        _buildTextField('شماره موبایل', Icons.phone, _usernameController),
                        _buildTextField('رمز عبور', Icons.lock, _passwordController, obscure: true),
                        const SizedBox(height: 25),
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade900,
                                  minimumSize: const Size(double.infinity, 55),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: const Text('ورود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: TextInputType.phone, // کیبورد اعدادی برای موبایل
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white60, fontFamily: 'Vazir'),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white38),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}