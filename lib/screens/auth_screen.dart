import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../core/app_theme.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  Timer? _timer;
  int _start = 120; // 2 دقیقه
  bool _isTimerActive = false;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _showPhoneSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPhoneUI(),
    );
  }

  void _showOtpSheet() {
    Navigator.pop(context); // بستن شیت شماره
    _startTimer();
    _startListeningOtp();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOtpUI(),
    );
  }

  void _startTimer() {
    setState(() {
      _start = 120;
      _isTimerActive = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start == 0) {
          _timer?.cancel();
          _isTimerActive = false;
        } else {
          _start--;
        }
      });
    });
  }

  void _startListeningOtp() async {
    await SmsAutoFill().listenForCode;
  }

  void _sendCodeToServer() {
    if (_phoneController.text.length != 11) {
      _showAlert('شماره موبایل نامعتبر است', isError: true);
      return;
    }
    // شبیه‌سازی لودینگ دکمه
    // در واقعیت اینجا به PHP درخواست زده میشود
    _showOtpSheet();
  }

  void _verifyOtp() {
    if (_otpController.text.length < 4) {
      _showAlert('کد تایید ناقص است', isError: true);
      return;
    }
    // موفقیت فرضی
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _showAlert(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Peyda')),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // بلافاصله بعد از باز شدن صفحه، شیت شماره را نمایش بده
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPhoneSheet());
    
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.shrink(), // فقط پس‌زمینه
    );
  }

  // --------------------------------- UI شماره موبایل ---------------------------------
  Widget _buildPhoneUI() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('ورود / ثبت‌نام', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('لطفا شماره موبایل خود را وارد کنید', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  labelText: 'شماره موبایل',
                  hintText: '0912',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  floatingLabelStyle: const TextStyle(color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.mattedGrey,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendCodeToServer,
                child: const Text('ادامه'),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    children: [
                      TextSpan(text: 'ورود شما به معنای پذیرش '),
                      TextSpan(text: 'شرایط اصالت خودرو', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' و '),
                      TextSpan(text: 'حریم خصوصی', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' است.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------- UI کد تایید ---------------------------------
  Widget _buildOtpUI() {
    String formattedTime = "${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}";

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('کد تایید', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  if (_isTimerActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mattedGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(formattedTime, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        // ارسال مجدد کد
                        _sendCodeToServer();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.mattedGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('ارسال مجدد', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('لطفا کد ارسال شده به شماره ${_phoneController.text} را وارد کنید', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              PinFieldAutoFill(
                controller: _otpController,
                codeLength: 4,
                keyboardType: TextInputType.number,
                onCodeChanged: (code) {
                  if (code != null && code.length == 4) {
                    _verifyOtp();
                  }
                },
                decoration: BoxLooseDecoration(
                  gapSpace: 4, // 4 پیکسل فاصله بین باکس‌ها
                  strokeColorBuilder: const FixedColorBuilder(AppColors.primary),
                  bgColorBuilder: const FixedColorBuilder(AppColors.mattedGrey),
                  radius: const Radius.circular(8),
                  strokeWidth: 2,
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    fontFamily: 'Peyda',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // برگشت به شیت شماره
                    _timer?.cancel();
                  },
                  child: const Text('ویرایش شماره موبایل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text('ورود'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}