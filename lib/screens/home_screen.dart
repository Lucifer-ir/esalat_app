// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // شبیه‌سازی لود اطلاعات از سرور
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background, // پس‌زمینه روشن
        elevation: 0,
        title: const Text(
          'اصالت خودرو',
          style: TextStyle(
            fontWeight: FontWeight.w700, 
            color: AppColors.textPrimary, // متن تیره
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primary), // آبی ملایم
            onPressed: () {
              // ناوبری به حساب کاربری
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            if (_isLoading) {
              return _buildSkeletonCard(); // نمایش اسکلت در زمان لودینگ
            } else {
              return _buildCarCard(index); // نمایش باکس خودرو بعد از لودینگ
            }
          },
        ),
      ),
    );
  }

  // ویجت اسکلت‌لودینگ (Skeleton) - تنظیم شده برای تم روشن
  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.mattedGrey, // رنگ پایه خاکستری مات
      highlightColor: AppColors.surface, // رنگ برجسته سفید
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت باکس خودرو بعد از لود شدن
  Widget _buildCarCard(int index) {
    // انیمیشن ظاهر شدن ملایم
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)), // تاخیر جابجایی برای هر آیتم
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (value * 0.05),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface, // کارت‌های سفید
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // سایه ملایم برای کارت‌ها
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // بررسی وضعیت اشتراک کاربر
              _checkSubscriptionAndNavigate(index);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // در اینجا آیکون/تصویر خودرو قرار می‌گیرد
                const Icon(Icons.directions_car, size: 50, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  'خودرو ${index + 1}', // نام مدل خودرو
                  style: const TextStyle(
                    color: AppColors.textPrimary, // متن تیره
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بررسی اشتراک ۷ روزه
  void _checkSubscriptionAndNavigate(int index) {
    // TODO: این تابع باید وضعیت اشتراک رو از دیتابیس یا حافظه محلی بخونه
    bool hasFreeTrial = true; // فرض می‌کنیم دوره آزمایشی فعاله
    bool hasPaidSubscription = false; // فرض می‌کنیم اشتراک پولی نداره

    if (hasFreeTrial || hasPaidSubscription) {
      // اجازه دسترسی به صفحه اطلاعات خودرو
      print("Opening car details for index $index");
    } else {
      // نمایش پیام نیاز به خرید اشتراک
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برای دسترسی به اطلاعات نیاز به خرید اشتراک دارید'),
          backgroundColor: AppColors.danger, // استفاده از رنگ قرمز خطر
        ),
      );
      // یا ناوبری به صفحه خرید اشتراک
      // Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionScreen()));
    }
  }
}