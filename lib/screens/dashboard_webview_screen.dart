import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'; // برای اندروید
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

  void _setupWebView() {
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
            // اگر اینترنت قطع بود یا سایت لود نشد
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // چک کردن دکمه خروج سایت
            if (request.url.contains('logout=1') || request.url.contains('action=logout')) {
              _handleLogout();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // تزریق کوکی به وب‌ویو (بسیار مهم برای رد نشدن از لاگین سایت)
    if (_controller.platform is AndroidWebViewController) {
      final androidController = _controller.platform as AndroidWebViewController;
      androidController.loadRequest(
        LoadRequestParams(
          uri: Uri.parse('https://esalatcar.ir/dashboard.php'),
          headers: {
            'Cookie': ApiService._sessionCookie ?? '', // فرستادن کوکی فلاتر به سایت
          },
        ),
      );
    } else {
      _controller.loadRequest(
        Uri.parse('https://esalatcar.ir/dashboard.php'),
      );
    }
  }

  void _handleLogout() async {
    await ApiService.loadSessionCookie();
    if (ApiService.isLoggedIn) {
      // پاک کردن کوکی‌ها در فلاتر
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('session_cookie');
      ApiService._sessionCookie = null;

      // رفتن به صفحه لاگین
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
        // اگر کاربر دکمه برگشت گوشی را زد، در وب‌ویو به صفحه قبلی برگردد
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (_hasError)
                NoInternetScreen(onRetry: _ReloadWebView) // نمایش صفحه قطعی
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