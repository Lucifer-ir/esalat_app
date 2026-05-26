import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'password_screen.dart';
import 'subscription_screen.dart'; // صفحه خرید اشتراک

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

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.history_edit_outlined, 'title': 'استعلام اصالت', 'route': 'auth'},
    {'icon': Icons.directions_car_filled_outlined, 'title': 'مشخصات فنی', 'route': 'tech'},
    {'icon': Icons.build_outlined, 'title': 'سابقه تعمیرات', 'route': 'repair'},
    {'icon': Icons.local_shipping_outlined, 'title': 'سابقه تصادف', 'route': 'accident'},
    {'icon': Icons.color_lens_outlined, 'title': 'تغییر رنگ', 'route': 'color'},
    {'icon': Icons.assignment_outlined, 'title': 'نمایش خلافی', 'route': 'fine'},
    {'icon': Icons.price_check_outlined, 'title': 'ارزش‌گذاری', 'route': 'price'},
    {'icon': Icons.local_gas_station_outlined, 'title': 'مصرف سوخت', 'route': 'fuel'},
  ];

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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.lockScreen), fullscreenDialog: true)).then((isSuccess) {
      if (isSuccess == true) { setState(() => _isUnlocked = true); _loadHomeData(); } 
      else { SystemNavigator.pop(); }
    });
  }

  void _loadHomeData() {
    setState(() { _checkingLock = false; _isUnlocked = true; });
    _checkSubscription();
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _isLoading = false); });
  }

  void _checkSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expireStr = prefs.getString('subExpire');
    if (expireStr != null) {
      DateTime expireDate = DateTime.parse(expireStr);
      if (DateTime.now().isBefore(expireDate)) { setState(() => _hasSubscription = true); }
    }
  }

  void _toggleTheme() async {
    bool isCurrentlyDark = widget.themeNotifier.value == ThemeMode.dark;
    widget.themeNotifier.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isCurrentlyDark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock || !_isUnlocked) {
      return const Scaffold(backgroundColor: AppColors.primary, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    bool isDark = widget.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA),
        elevation: 0, centerTitle: false, automaticallyImplyLeading: false,
        title: Text('اصالت خودرو', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: 'Peyda')),
        actions: [
          _buildAppBarAction(context: context, isDark: isDark, icon: Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          _buildAppBarAction(context: context, isDark: isDark, icon: Icons.notifications_none, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          _buildAppBarAction(context: context, isDark: isDark, icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, onTap: _toggleTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBanner(isDark),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 12),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        if (_isLoading) return _buildSkeletonGrid(isDark);
                        return _buildGridItem(_menuItems[index], isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(isDark),
        ],
      ),
    );
  }

  // بنر تبلیغاتی
  Widget _buildBanner(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _isLoading 
        ? Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.white,
            child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(16))),
          )
        : GestureDetector(
            onTap: () {
              // لینک بنر از سایت خوانده می‌شود
              launchUrl(Uri.parse('http://websera.ir/offer'));
            },
            child: CachedNetworkImage(
              imageUrl: 'http://websera.ir/banner.jpg', // آدرس تصویر بنر از سایت شما
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                highlightColor: isDark ? Colors.grey[700]! : Colors.white,
                child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150, width: double.infinity, decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
              ),
            ),
          ),
    );
  }

  // آیتم‌های گرید 4 در 2
  Widget _buildGridItem(Map<String, dynamic> item, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (!_hasSubscription) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای دسترسی نیاز به خرید اشتراک دارید'), backgroundColor: AppColors.danger));
        } else {
          // ناوبری به صفحه مربوطه
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(item['icon'] as IconData, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(item['title'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary, fontFamily: 'Peyda', fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid(bool isDark) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.white,
          child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.circle, size: 28)),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.white,
          child: Container(width: 50, height: 10, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(4))),
        ),
      ],
    );
  }

  // دو دکمه پایین صفحه
  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () { /* ثبت خودرو */ },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                label: const Text('ثبت خودروی جدید', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () { /* ثبت تصویر */ },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                label: const Text('ثبت تصویر', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction({required BuildContext context, required bool isDark, required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 42, height: 42, margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2C) : Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 22), onPressed: onTap),
    );
  }
}