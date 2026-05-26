// lib/screens/auth_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TextEditingController _otpController = TextEditingController();
  
  Timer? _timer;
  int _start = 120;
  bool _isTimerActive = false;
  
  // متغیرهای اسلایدر
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoadingBtn = false;

  // داده‌های اسلایدر
  final List<Map<String, String>> _slides = [
    {
      'icon': Icons.verified_user,
      'title': 'استعلام اصالت',
      'desc': 'با یک کلیک، اصالت هر خودرو را استعلام کنید و از خرید خودروی تصادفی در امان باشید.',
    },
    {
      'icon': Icons.history,
      'title': 'تاریخچه خودرو',
      'desc': 'تمامی سوابق تصادفات، تعمیرات و تغییرات رنگ خودرو را به راحتی مشاهده کنید.',
    },
    {
      'icon': Icons.security,
      'title': 'خرید امن',
      'desc': 'پیش از انجام معامله، از سلامت و اصالت خودرو با اطمینان کامل مطلع شوید.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _pageController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // بررسی کش (اگر وارد شده بود مستقیم بره هوم)
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  // ذخیره ورود در کش
  void _setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // نمایش الرت شناور تمام عرض
  void _showAlert(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Peyda', color: Colors.white)),
        backgroundColor: isError ? AppColors.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // لاجیک دکمه‌های اسلایدر
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
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
                          filled: true,
                          fillColor: AppColors.mattedGrey,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoadingBtn ? null : () async {
                            if (_phoneController.text.length != 11) {
                              _showAlert('شماره موبایل نامعتبر است', isError: true);
                              return;
                            }
                            setModalState(() => _isLoadingBtn = true);
                            await Future.delayed(const Duration(seconds: 2)); // شبیه‌سازی درخواست سرور
                            setModalState(() => _isLoadingBtn = false);
                            
                            // رفتن به مرحله کد تاید (بستن این شیت و باز شدن شیت کد)
                            Navigator.pop(context);
                            _showOtpSheet();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: _isLoadingBtn 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('ادامه', style: TextStyle(fontFamily: 'Peyda')),
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
                      const SizedBox(height: 16),
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
    _startListeningOtp();

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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
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
                          if (_isTimerActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)), // انحنای 8 پیکسل
                              child: Text("${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Peyda')),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                setModalState(() { _start = 120; _isTimerActive = true; });
                                _startTimer(); // ارسال مجدد
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)),
                                child: const Text('ارسال مجدد', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Peyda')),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('لطفا کد ارسال شده به شماره ${_phoneController.text} را وارد کنید', style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Peyda')),
                      const SizedBox(height: 24),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: PinFieldAutoFill(
                          controller: _otpController,
                          codeLength: 4,
                          keyboardType: TextInputType.number,
                          onCodeChanged: (code) {
                            if (code != null && code.length == 4) {
                              _verifyOtp();
                            }
                          },
                          decoration: BoxLooseDecoration(
                            gapSpace: 12, // فاصله بین باکس‌ها
                            strokeColorBuilder: const FixedColorBuilder(Colors.grey), // بوردر پیش‌فرض خاکستری
                            bgColorBuilder: const FixedColorBuilder(Colors.transparent), // حذف پس‌زمینه طوسی
                            radius: const Radius.circular(8), // انحنای باکس‌ها
                            strokeWidth: 1, // ضخامت بوردر 1
                            textStyle: const TextStyle(fontSize: 20, color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _timer?.cancel();
                            _showPhoneSheet(); // برگشت به شیت شماره
                          },
                          child: const Text('ویرایش شماره موبایل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontFamily: 'Peyda')),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          child: const Text('ورود', style: TextStyle(fontFamily: 'Peyda')),
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
    setState(() { _start = 120; _isTimerActive = true; });
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

  void _verifyOtp() async {
    if (_otpController.text.length < 4) {
      _showAlert('کد تایید ناقص است', isError: true);
      return;
    }
    // شبیه‌سازی موفقیت
    _setLoggedIn();
    _showAlert('ورود با موفقیت انجام شد', isError: false);
    await Future.delayed(const Duration(seconds: 1));
    if(mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                onPageChanged: (index) {
                  setState(() { _currentPage = index; });
                },
                itemBuilder: (context, index) {
                  return _buildSlideContent(
                    icon: _slides[index]['icon'] as IconData,
                    title: _slides[index]['title']!,
                    desc: _slides[index]['desc']!,
                  );
                },
              ),
            ),
            // نقطه‌های نشانه‌گذاری
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
            // دکمه‌های پایین صفحه
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _currentPage == 0 ? null : () {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _currentPage == 0 ? Colors.white24 : Colors.white),
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
                          backgroundColor: _currentPage == _slides.length - 1 ? Colors.white : AppColors.primary, // آبی کم رنگ/سفید در صفحه آخر
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ویجت محتوای اسلایدر
  Widget _buildSlideContent({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.white),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Peyda'),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5, fontFamily: 'Peyda'),
          ),
        ],
      ),
    );
  }
}