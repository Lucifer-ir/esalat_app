import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'core/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/payment_result_screen.dart'; // اضافه کردن صفحه نتیجه پرداخت

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
    _initDeepLinkListener();
  }

  void _loadSavedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // گوش دادن به لینک‌های ورودی (مثل بازگشت از درگاه پرداخت)
  void _initDeepLinkListener() async {
    // بررسی اینکه آیا اپ با کلیک روی لینک باز شده است؟
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Error handling deep link: $e");
    }

    // گوش دادن به لینک‌ها در زمانی که اپلیکیشن در پس‌زمینه است
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print("Error listening deep link: $err");
    });
  }

  // پردازش لینک بازگشت از درگاه
  void _handleDeepLink(Uri uri) {
    if (uri.host == 'payment-result') {
      String status = uri.queryParameters['status'] ?? 'fail';
      String amount = uri.queryParameters['amount'] ?? '0';
      
      bool isSuccess = status == 'success';

      // ناوبری به صفحه نتیجه پرداخت
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(isSuccess: isSuccess, amount: amount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'اصالت خودرو',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          navigatorKey: navigatorKey, // کلید ناوبری برای دسترسی از بیرون
          home: const AuthScreen(),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );
      },
    );
  }
}

// یک کلید سراسری برای ناوبری بدون context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();