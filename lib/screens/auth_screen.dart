// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../core/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpStage = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // ارسال شماره برای دریافت کد
  void _sendOtp() {
    if (_phoneController.text.length == 11) {
      // TODO: درخواست به بکند PHP برای ارسال پیامک
      setState(() {
        _isOtpStage = true;
      });
      _startListeningOtp(); // شروع به گوش دادن برای پر کردن خودکار کد
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شماره موبایل نامعتبر است')),
      );
    }
  }

  // گوش دادن به پیامک‌های ورودی برای Auto-fill
  void _startListeningOtp() async {
    await SmsAutoFill().listenForCode;
  }

  // تایید کد ورود
  void _verifyOtp() {
    if (_otpController.text.length == 4 || _otpController.text.length == 5) {
      // TODO: درخواست به بکند PHP برای تایید کد
      // بعد از تایید موفق ناوبری به صفحه هوم
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // لوگوی اپلیکیشن (اینجا یک آیکون گذاشتم، می‌تونی عکس بذاری)
                const Icon(Icons.directions_car, size: 80, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'اصالت خودرو',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'برای ادامه شماره موبایل خود را وارد کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                
                if (!_isOtpStage) ...[
                  // فیلد شماره موبایل
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Peyda',
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: '۰۹۱۲۳۴۵۶۷۸۹',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _sendOtp,
                    child: const Text('دریافت کد تایید'),
                  ),
                ] else ...[
                  // فیلد کد تایید (OTP) با قابلیت Auto-fill
                  PinFieldAutoFill(
                    controller: _otpController,
                    codeLength: 5, // بستگی به طول کد شما در بکند PHP دارد
                    keyboardType: TextInputType.number,
                    onCodeChanged: (code) {
                      if (code != null && code.length == 5) {
                        _verifyOtp(); // اگر کد کامل شد خودکار وارد شود
                      }
                    },
                    decoration: BoxLooseDecoration(
                      bgColor: AppColors.surface,
                      radius: Radius.circular(8),
                      strokeWidth: 2,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                        fontFamily: 'Peyda',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('ورود به برنامه'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}