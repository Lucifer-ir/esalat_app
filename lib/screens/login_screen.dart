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
        SnackBar(content: Text(result['message'] ?? 'خطا در ورود', style: const TextStyle(fontFamily: 'Vazir')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.lightBlue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.car_repair, size: 60, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text('ورود به اصالت خودرو', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
                      const SizedBox(height: 20),
                      _buildTextField('شماره موبایل', Icons.phone, _usernameController),
                      _buildTextField('رمز عبور', Icons.lock, _passwordController, obscure: true),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade900,
                                minimumSize: const Size(double.infinity, 50),
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
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontFamily: 'Vazir'),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}