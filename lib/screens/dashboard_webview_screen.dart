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
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('logout=1') || request.url.contains('action=logout')) {
              _handleLogout();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // ارسال کوکی به وب‌ویو برای لاگین خودکار در سایت
    _controller.loadRequest(
      LoadRequestParams(
        uri: Uri.parse('https://esalatcar.ir/dashboard.php'),
        headers: {
          'Cookie': ApiService.getSessionCookie(),
        },
      ),
    );
  }

  void _handleLogout() async {
    // پاک کردن کوکی‌ها در فلاتر
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('session_cookie');

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
                NoInternetScreen(onRetry: _ReloadWebView)
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