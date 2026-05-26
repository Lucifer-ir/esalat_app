// lib/screens/auth_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_theme.dart';
import 'terms_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late OTPTextEditController _otpController;
  final OTPInteractor _otpInteractor = OTPInteractor();
  
  Timer? _timer;
  int _start = 120;
  bool _isTimerActive = false;
  bool _isOtpFocused = false;
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoadingBtn = false;

  final List<Map<String, dynamic>> _slides = [
    {'icon': Icons.verified_user, 'title': 'استعلام اصالت', 'desc': 'با یک کلیک، اصالت هر خودرو را استعلام کنید و از خرید خودروی تصادفی در امان باشید.'},
    {'icon': Icons.history, 'title': 'تاریخچه خودرو', 'desc': 'تمامی سوابق تصادفات، تعمیرات و تغییرات رنگ خودرو را به راحتی مشاهده کنید.'},
    {'icon': Icons.security, 'title': 'خرید امن', 'desc': 'پیش از انجام معامله، از سلامت و اصالت خودرو با اطمینان کامل مطلع شوید.'},
  ];

  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(120);
  final ValueNotifier<bool> _timerActiveNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initOtpController();
  }

  void _initOtpController() {
    _otpController = OTPTextEditController(
      codeLength: 4,
      onCodeReceive: (code) {
        if (code.length == 4) {
          _verifyOtp();
        }
      },
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{4})');
          return exp.firstMatch(code ?? '')?.group(0) ?? ''; // اصلاح خطای String?
        },
      );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _pageController.dispose();
    _timerNotifier.dispose();
    _timerActiveNotifier.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  void _setLoggedIn(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    DateTime expireDate = DateTime.now().add(const Duration(days: 7));
    await prefs.setString('subExpire', expireDate.toIso8601String());
    await prefs.setBool('isSubActive', true);
  }

  void _showAlert(String message, {bool isError = false}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isError ? AppColors.danger : Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }

  void _onNextPressed() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _showPhoneSheet();
    }
  }

  // --------------------------------- شیت شماره موبایل ---------------------------------
  void _showPhoneSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 100),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 24),
                      const Text('ورود / ثبت‌نام', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Peyda')),
                      const SizedBox(height: 8),
                      const Text('لطفا شماره موبایل خود را وارد کنید', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Peyda')),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontFamily: 'Peyda', letterSpacing: 2),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          labelText: 'شماره موبایل',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Peyda'),
                          floatingLabelStyle: const TextStyle(color: AppColors.primary, fontFamily: 'Peyda'),
                          filled: true, fillColor: AppColors.mattedGrey,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoadingBtn ? null : () async {
                            if (_phoneController.text.length != 11) {
                              _showAlert('شماره موبایل نامعتبر است', isError: true);
                              return;
                            }
                            setModalState(() => _isLoadingBtn = true);
                            
                            try {
                              var response = await http.post(
                                Uri.parse("http://websera.ir/auth.php?action=send_code"),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({"phone": _phoneController.text}),
                              );
                              var data = jsonDecode(response.body);
                              if (data['status'] == 'success') {
                                _showAlert('کد تایید ارسال شد', isError: false);
                                Navigator.pop(context);
                                _showOtpSheet();
                              } else {
                                _showAlert(data['message'] ?? 'خطا در ارسال کد', isError: true);
                              }
                            } catch (e) {
                              _showAlert('خطا در اتصال به سرور', isError: true);
                            }
                            
                            setModalState(() => _isLoadingBtn = false);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                          child: _isLoadingBtn 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('ادامه', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text('ورود شما به معنای پذیرش ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Peyda')),
                            GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen(title: 'شرایط', content: 'متن طولانی شرایط...'))), child: const Text('شرایط اصالت خودرو', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Peyda'))),
                            const Text(' و ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Peyda')),
                            GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen(title: 'حریم خصوصی', content: 'متن طولانی حریم خصوصی...'))), child: const Text('حریم خصوصی', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Peyda'))),
                            const Text(' است.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Peyda')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------- شیت کد تایید ---------------------------------
  void _showOtpSheet() {
    _startTimer();
    _otpController.startListenUserConsent(
      (code) {
        final exp = RegExp(r'(\d{4})');
        return exp.firstMatch(code ?? '')?.group(0) ?? ''; // اصلاح خطای String?
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 100),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('کد تایید', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Peyda')),
                          ValueListenableBuilder<bool>(
                            valueListenable: _timerActiveNotifier,
                            builder: (context, isActive, child) {
                              if (isActive) {
                                return ValueListenableBuilder<int>(
                                  valueListenable: _timerNotifier,
                                  builder: (context, timeValue, child) {
                                    String formattedTime = "${(timeValue ~/ 60).toString().padLeft(2, '0')}:${(timeValue % 60).toString().padLeft(2, '0')}";
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)),
                                      child: Text(formattedTime, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Peyda')),
                                    );
                                  },
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    _resendCode();
                                    setModalState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)),
                                    child: const Text('ارسال مجدد', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Peyda')),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('لطفا کد ارسال شده به شماره ${_phoneController.text} را وارد کنید', style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Peyda')),
                      const SizedBox(height: 24),
                      
                      // فیلد کد تایید استایل‌دهی شده شبیه 4 باکس مجزا
                      GestureDetector(
                        onTapDown: (_) => setModalState(() => _isOtpFocused = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: _isOtpFocused ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: AppColors.mattedGrey, width: 2),
                            color: AppColors.mattedGrey.withOpacity(0.3),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 4,
                              style: const TextStyle(
                                fontSize: 24, 
                                color: AppColors.textPrimary, 
                                fontFamily: 'Peyda', 
                                fontWeight: FontWeight.w700,
                                letterSpacing: 32, // فاصله بین اعداد برای ایجاد حس 4 باکس مجزا
                              ),
                              cursorColor: AppColors.primary,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "", // حذف شمارنده کاراکتر
                                hintText: '⁣ − − − −',
                                hintStyle: TextStyle(color: Colors.grey, letterSpacing: 16, fontSize: 20),
                              ),
                              onChanged: (code) {
                                if (code.length == 4) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _timer?.cancel();
                            _showPhoneSheet();
                          },
                          child: const Text('ویرایش شماره موبایل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontFamily: 'Peyda')),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(elevation: 0),
                          child: const Text('ورود', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timerNotifier.value = 120;
    _timerActiveNotifier.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerNotifier.value == 0) {
        timer.cancel();
        _timerActiveNotifier.value = false;
      } else {
        _timerNotifier.value--;
      }
    });
  }

  void _resendCode() async {
    try {
      var response = await http.post(
        Uri.parse("http://websera.ir/auth.php?action=send_code"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": _phoneController.text}),
      );
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _startTimer();
        _showAlert('کد مجدداً ارسال شد', isError: false);
      } else {
        _showAlert(data['message'] ?? 'خطا در ارسال کد', isError: true);
      }
    } catch (e) {
      _showAlert('خطا در اتصال به سرور', isError: true);
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length < 4) {
      _showAlert('کد تایید ناقص است', isError: true);
      return;
    }
    
    try {
      var response = await http.post(
        Uri.parse("http://websera.ir/auth.php?action=verify_code"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": _phoneController.text, "code": _otpController.text}),
      );
      var data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        _setLoggedIn(_phoneController.text);
        _showAlert('ورود با موفقیت انجام شد', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if(mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } else {
        _showAlert(data['message'] ?? 'کد تایید اشتباه است', isError: true);
      }
    } catch (e) {
      _showAlert('خطا در اتصال به سرور', isError: true);
    }
  }

  // --------------------------------- ساختار اصلی صفحه (اسلایدر) ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _buildSlideContent(
                    icon: _slides[index]['icon'] as IconData,
                    title: _slides[index]['title']!,
                    desc: _slides[index]['desc']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 10, height: 10,
                    decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(5)),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _currentPage == 0 ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _currentPage == 0 ? Colors.white24 : Colors.white, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('قبل', style: TextStyle(color: Colors.white, fontFamily: 'Peyda')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == _slides.length - 1 ? Colors.white : AppColors.primary,
                          foregroundColor: _currentPage == _slides.length - 1 ? AppColors.primary : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white, width: 2)),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1 ? 'ورود / ثبت‌نام' : 'بعدی',
                          style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.white),
          const SizedBox(height: 32),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Peyda')),
          const SizedBox(height: 16),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5, fontFamily: 'Peyda')),
        ],
      ),
    );
  }
}