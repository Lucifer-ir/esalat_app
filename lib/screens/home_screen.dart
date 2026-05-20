import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'vehicle_list_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List groups = [];
  bool _isLoading = true;
  String monthlyPrice = 'در حال بارگذاری...';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    var result = await ApiService.getRequest('getGroups');
    
    if (result['success']) {
      setState(() {
        groups = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'خطا', style: const TextStyle(fontFamily: 'Peyda'))),
      );
    }

    // گرفتن قیمت اشتراک از سرور
    var settings = await ApiService.getRequest('getUserInfo'); 
    // توجه: در api.php شما اکشنی برای گرفتن فقط قیمت ندارید، اما فرض میکنیم در آینده اضافه میکنید
    // فعلا قیمت را استاتیک یا از یک تنظیمات دیگر می‌خوانیم. اینجا یک نمونه است.
    setState(() {
      monthlyPrice = '399,000 تومان'; // این باید از سرور گرفته شود
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'car': return Icons.directions_car;
      case 'caravan': return Icons.airport_shuttle;
      case 'car-side': return Icons.time_to_leave;
      case 'truck': return Icons.local_shipping;
      case 'motorcycle': return Icons.motorcycle;
      case 'globe': return Icons.public;
      case 'truck-pickup': return Icons.local_shipping;
      case 'truck-moving': return Icons.local_shipping;
      case 'tractor': return Icons.agriculture;
      case 'bus': return Icons.directions_bus;
      case 'camera': return Icons.camera_alt;
      case 'images': return Icons.collections;
      case 'ellipsis-h': return Icons.more_horiz;
      default: return Icons.category;
    }
  }

  // صفحات نوار پایین
  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    // ساخت صفحات در بیلد برای دسترسی به context
    final pages = [
      _buildDashboardPage(),
      const SubscriptionScreen(),
      const AboutScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اصالت خودرو', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(), // منوی همبرگری
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.blue.shade900,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'ثبت خودرو'),
              BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: 'اشتراک'),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: 'درباره ما'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حساب کاربری'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // صفحه داشبورد (تب اول)
  // ==========================================
  Widget _buildDashboardPage() {
    return RefreshIndicator(
      onRefresh: () async => _loadInitialData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // کارت قیمت اشتراک
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.lightBlue.shade400]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اشتراک ماهانه', style: TextStyle(color: Colors.white70, fontFamily: 'Peyda')),
                      SizedBox(height: 5),
                      Text('دسترسی نامحدود', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
                    ],
                  ),
                  Text(monthlyPrice, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text('دسته‌بندی خودروها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Peyda', color: Colors.black87)),
            ),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        var group = groups[index];
                        return GestureDetector(
                          onTap: () {
                            if (group['name'] == 'ثبت تصاویر') {
                              // هدایت به صفحه ثبت تصویر (بعدا می‌سازیم)
                            } else {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => VehicleListScreen(groupName: group['name']),
                              ));
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getIcon(group['icon'] ?? ''), size: 35, color: Colors.blue.shade900),
                                    const SizedBox(height: 8),
                                    Text(
                                      group['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontFamily: 'Peyda'),
                                    ),
                                    if (group['count'] > 0)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade900,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          group['count'].toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Peyda'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // منوی همبرگری (Drawer)
  // ==========================================
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.car_repair, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text('اصالت خودرو', style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
                  Text('پنل کاربری', style: TextStyle(color: Colors.white70, fontFamily: 'Peyda')),
                ],
              ),
            ),
            _buildDrawerItem(Icons.receipt, 'ارسال رسید اشتراک'),
            _buildDrawerItem(Icons.headset_mic, 'پشتیبانی و تیکت‌ها'),
            _buildDrawerItem(Icons.settings, 'تنظیمات'),
            _buildDrawerItem(Icons.change_circle, 'تغییر رمز عبور'),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'خروج از حساب', color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color == Colors.black87 ? Colors.blue.shade900 : color),
      title: Text(title, style: TextStyle(fontFamily: 'Peyda', color: color, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        // پیاده‌سازی رفتار هر آیتم
      },
    );
  }
}