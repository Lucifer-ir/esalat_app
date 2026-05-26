import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // اضافه شود
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'password_screen.dart'; // اضافه کردن صفحه رمز

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasSubscription = false;
  bool _isUnlocked = false; // آیا قفل صفحه باز شده یا نه؟
  bool _checkingLock = true; // آیا در حال چک کردن وضعیت قفل است؟

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  // بررسی اینکه آیا رمز عبور تنظیم شده است یا خیر
  void _checkLockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPassword = prefs.getBool('hasPassword') ?? false;
    String? savedPass = prefs.getString('appPassword');

    if (hasPassword && savedPass != null) {
      // اگر رمز داشت، صفحه قفل را نمایش بده
      setState(() => _checkingLock = false);
      _showLockScreen();
    } else {
      // اگر رمز نداشت، مستقیم محتوا را لود کن
      _loadHomeData();
    }
  }

  void _showLockScreen() {
    // نمایش صفحه رمز عبور به صورت مودال (بدون امکان بستن با دکمه بک)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordScreen(mode: PasswordMode.lockScreen),
        fullscreenDialog: true, // این باعث میشه دکمه بک نداشته باشه
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        // اگر رمز درست بود، وارد صفحه اصلی شو
        setState(() => _isUnlocked = true);
        _loadHomeData();
      } else {
        // اگر رمز اشتباه بود یا صفحه رو بست، از برنامه خارج شو (یا هر لاجیک دیگری)
        // اینجا برای امنیت بیشتر می‌تونیم اپ رو ببندیم یا دوباره همون صفحه قفل رو بیاریم
        SystemNavigator.pop(); // بستن اپلیکیشن
      }
    });
  }

  void _loadHomeData() {
    setState(() {
      _checkingLock = false;
      _isUnlocked = true;
    });
    
    _checkSubscription();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _checkSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expireStr = prefs.getString('subExpire');
    if (expireStr != null) {
      DateTime expireDate = DateTime.parse(expireStr);
      if (DateTime.now().isBefore(expireDate)) {
        setState(() => _hasSubscription = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // اگر در حال چک کردن قفل است، یک صفحه خالی یا لودینگ نشان بده
    if (_checkingLock || !_isUnlocked) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // اگر قفل باز شد، محتوای اصلی را نشان بده
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'اصالت خودرو', 
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Peyda')
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            if (_isLoading) return _buildSkeletonCard();
            return _buildCarCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!, highlightColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 16),
            Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.95 + (value * 0.05), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!_hasSubscription) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('برای دسترسی نیاز به خرید اشتراک دارید'), backgroundColor: AppColors.danger),
                );
              } else {
                // دسترسی مجاز
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car, size: 50, color: AppColors.primary),
                const SizedBox(height: 12),
                Text('خودرو ${index + 1}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontFamily: 'Peyda')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}