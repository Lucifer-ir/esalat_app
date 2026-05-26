import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'password_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomeScreen({Key? key, required this.themeNotifier}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasSubscription = false;
  bool _isUnlocked = false;
  bool _checkingLock = true;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  void _checkLockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPassword = prefs.getBool('hasPassword') ?? false;
    String? savedPass = prefs.getString('appPassword');

    if (hasPassword && savedPass != null) {
      setState(() => _checkingLock = false);
      _showLockScreen();
    } else {
      _loadHomeData();
    }
  }

  void _showLockScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordScreen(mode: PasswordMode.lockScreen),
        fullscreenDialog: true,
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        setState(() => _isUnlocked = true);
        _loadHomeData();
      } else {
        SystemNavigator.pop();
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

  // لاجیک تغییر تم
  void _toggleTheme() {
    if (widget.themeNotifier.value == ThemeMode.light) {
      widget.themeNotifier.value = ThemeMode.dark;
    } else {
      widget.themeNotifier.value = ThemeMode.light;
    }
    setState(() {}); // برای آپدیت شدن آیکون دکمه
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock || !_isUnlocked) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    bool isDark = widget.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA), // پس زمینه تاریک/روشن
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA), // رنگ اپ‌بار همرنگ پس‌زمینه
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // حذف دکمه برگشت خودکار
        title: Text(
          'اصالت خودرو', 
          style: TextStyle(
            fontWeight: FontWeight.w700, 
            color: isDark ? Colors.white : AppColors.textPrimary, 
            fontFamily: 'Peyda'
          )
        ),
        actions: [
          // گزینه حساب کاربری (سفید، انحنای 8، آیکون مشکی)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.person_outline, color: isDark ? AppColors.primary : Colors.black, size: 20),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ),
          // نوتیفیکیشن
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.notifications_none, color: isDark ? AppColors.primary : Colors.black, size: 20),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
          ),
          // تغییر تم
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, // تغییر آیکون بر اساس تم
                color: isDark ? AppColors.primary : Colors.black, 
                size: 20
              ),
              onPressed: _toggleTheme,
            ),
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
            if (_isLoading) return _buildSkeletonCard(isDark);
            return _buildCarCard(index, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white, 
          borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 16),
            Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(int index, bool isDark) {
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
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                Icon(Icons.directions_car, size: 50, color: AppColors.primary),
                const SizedBox(height: 12),
                Text('خودرو ${index + 1}', style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary, 
                  fontWeight: FontWeight.w500, 
                  fontFamily: 'Peyda'
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}