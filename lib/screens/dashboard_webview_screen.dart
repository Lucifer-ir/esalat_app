import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'no_internet_screen.dart';

class DashboardWebviewScreen extends StatefulWidget {
  const DashboardWebviewScreen({super.key});

  @override
  State<DashboardWebviewScreen> createState() => _DashboardWebviewScreenState();
}

class _DashboardWebviewScreenState extends State<DashboardWebviewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() async {
    // ==========================================
    // تزریق کوکی به مرورگر درون اپلیکیشن (مهم‌ترین بخش)
    // ==========================================
    await ApiService.loadSessionCookie();
    String? rawCookie = ApiService.getSessionCookie();
    
    if (rawCookie != null) {
      // استخراج مقدار PHPSESSID (حذف کلمه PHPSESSID= از ابتدای رشته)
      String cookieValue = rawCookie.replaceAll('PHPSESSID=', '');
      
      // ذخیره کوکی در خود مرورگر وب‌ویو
      final cookieManager = WebViewCookieManager();
      await cookieManager.setCookie(
        const WebViewCookie(
          name: 'PHPSESSID', 
          value: '', // مقدار خالص آیدی سشن
          domain: 'esalatcar.ir', 
          path: '/',
        ),
      );
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.errorType == WebResourceErrorType.connect || 
                error.errorType == WebResourceErrorType.hostLookup) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // تشخیص دکمه خروج سایت
            if (request.url.contains('logout=1') || request.url.contains('action=logout')) {
              _handleLogout();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // لود کردن صفحه سایت (با روش ساده و استاندارد)
    _controller.loadRequest(
      Uri.parse('https://esalatcar.ir/dashboard.php'),
    );
  }

  void _handleLogout() async {
    // پاک کردن کوکی‌ها در فلاتر
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('session_cookie');
    
    // پاک کردن کوکی از خود مرورگر وب‌ویو
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    // خروج از اپلیکیشن و رفتن به صفحه لاگین
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _reloadWebView() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // رفتار دکمه برگشت فیزیکی گوشی
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              if (_hasError)
                NoInternetScreen(onRetry: _reloadWebView)
              else
                WebViewWidget(controller: _controller),
              
              if (_isLoading && !_hasError)
                const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}