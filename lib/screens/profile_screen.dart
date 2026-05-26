import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import 'password_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // طوسی خیلی کم رنگ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), 
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text(
          'حساب کاربری', 
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuItem(
              context, 
              icon: Icons.lock_outline, 
              title: 'رمز عبور', 
              onTap: () => _handlePasswordTap(context)
            ),
            const SizedBox(height: 8),
            
            _buildMenuItem(
              context, 
              icon: Icons.headset_mic_outlined, 
              title: 'تماس با ما', 
              onTap: () {}
            ),
            const SizedBox(height: 8),
            
            _buildMenuItem(
              context, 
              icon: Icons.info_outline, 
              title: 'درباره ما', 
              onTap: () {}
            ),
            const SizedBox(height: 8),
            
            _buildMenuItem(
              context, 
              icon: Icons.security_outlined, 
              title: 'حریم خصوصی و امنیت', 
              onTap: () {}
            ),
            const SizedBox(height: 8),
            
            _buildMenuItem(
              context, 
              icon: Icons.question_answer_outlined, 
              title: 'سوالات متداول', 
              onTap: () {}
            ),
            const SizedBox(height: 8),
            
            _buildMenuItem(
              context, 
              icon: Icons.group_outlined, 
              title: 'دعوت از دوستان', 
              onTap: () {}
            ),
            
            const Spacer(), // فضای خالی برای اینکه دکمه خروج بره پایین
            
            _buildMenuItem(
              context, 
              icon: Icons.exit_to_app, 
              title: 'خروج از حساب', 
              color: AppColors.danger, // رنگ قرمز برای دکمه خروج
              onTap: () => _showLogoutSheet(context)
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ویجت ساخت تک‌تک آیتم‌های لیست
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color color = AppColors.textPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // فلش سمت چپ
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            // عنوان و آیکون سمت راست
            Row(
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontFamily: 'Peyda', 
                    fontWeight: FontWeight.w500, 
                    color: color
                  )
                ),
                const SizedBox(width: 12),
                Icon(icon, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // مدیریت کلیک روی رمز عبور (چک میکند آیا قبلا رمز دارد یا خیر)
  void _handlePasswordTap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPassword = prefs.getBool('hasPassword') ?? false;

    if (hasPassword) {
      _showPasswordOptionsSheet(context); // اگر رمز داشت، منوی ویرایش/حذف باز شود
    } else {
      // اگر رمز نداشت، مستقیم بره صفحه تنظیم رمز
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.set)));
    }
  }

  // منوی بازشو برای ویرایش یا حذف رمز عبور
  void _showPasswordOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: 40, height: 4, 
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('ویرایش رمز عبور', style: TextStyle(fontFamily: 'Peyda')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.confirmForEdit)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('حذف رمز عبور', style: TextStyle(fontFamily: 'Peyda', color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.confirmForRemove)));
              },
            ),
          ],
        ),
      ),
    );
  }

  // منوی بازشو برای خروج از حساب
  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const SizedBox(height: 16),
            const Text(
              'آیا تمایل برای خروج از حساب کاربری خود را دارید؟', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, fontSize: 16)
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // پاک کردن کل کش و اطلاعات ورود
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const AuthScreen()), 
                    (route) => false
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  elevation: 0
                ),
                child: const Text('خروج', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text('انصراف', style: TextStyle(fontFamily: 'Peyda', color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}