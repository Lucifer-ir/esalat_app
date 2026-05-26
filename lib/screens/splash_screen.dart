import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/app_theme.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;
  bool _hasConnection = true;
  bool _serverOk = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndServer();
  }

  Future<void> _checkConnectionAndServer() async {
    setState(() {
      _isChecking = true;
      _hasConnection = true;
      _serverOk = false;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _hasConnection = false;
        _isChecking = false;
      });
      _showNoInternetSheet();
      return;
    }

    // شبیه‌سازی چک کردن سرور PHP
    await Future.delayed(const Duration(seconds: 2));
    bool serverIsUp = true; // در واقعیت اینجا وبسرویس رو چک می‌کنید

    if (serverIsUp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      setState(() {
        _serverOk = false;
        _isChecking = false;
      });
    }
  }

  void _showNoInternetSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text(
                'خطا در اتصال',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'فیلترشکن خود را خاموش کنید و اتصال به اینترنت را برقرار نمایید.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => AppSettings.openWIFISettings(),
                      child: const Text('وای‌فای'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => AppSettings.openCellularSettings(),
                      child: const Text('داده همراه'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // لوگو وسط صفحه
          Icon(Icons.directions_car, size: 100, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('اصالت خودرو', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (_isChecking) 
            const CircularProgressIndicator(color: AppColors.primary),
          
          if (!_isChecking && !_hasConnection) 
            const SizedBox.shrink(), // شیت باز میشود

          if (!_isChecking && _hasConnection && !_serverOk)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _checkConnectionAndServer,
                  child: const Text('تلاش مجدد'),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}