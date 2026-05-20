import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() async {
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
        SnackBar(content: Text(result['message'] ?? 'خطا در دریافت اطلاعات', style: const TextStyle(fontFamily: 'Vazir'))),
      );
    }
  }

  // مپ کردن نام آیکون از سرور به آیکون‌های فلاتر
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'car': return Icons.directions_car;
      case 'caravan': return Icons.car_repair;
      case 'truck': return Icons.local_shipping;
      case 'motorcycle': return Icons.motorcycle;
      case 'globe': return Icons.public;
      case 'truck-pickup': return Icons.pickup;
      case 'bus': return Icons.directions_bus;
      case 'camera': return Icons.camera_alt;
      case 'images': return Icons.collections;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اصالت خودرو', style: TextStyle(fontFamily: 'Vazir')),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 باکس در هر ردیف
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  var group = groups[index];
                  return GestureDetector(
                    onTap: () {
                      // در اینجا باید به صفحه ماشین‌های این گروه بروید
                      // و اکشن getGroupCars را صدا بزنید
                    },
                    // افکت شیشه ای (Glassmorphism)
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.withOpacity(0.4)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getIcon(group['icon']), size: 35, color: Colors.blue.shade900),
                              const SizedBox(height: 8),
                              Text(
                                group['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontFamily: 'Vazir'),
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
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Vazir'),
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
    );
  }
}