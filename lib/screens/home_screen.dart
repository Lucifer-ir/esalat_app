import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'add_vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List groups = [];
  List offlineVehicles = []; // لیست خودروهای آفلاین
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // لود همزمان اطلاعات سرور و دیتابیس محلی
  void _loadInitialData() async {
    setState(() => _isLoading = true);
    
    // لود خودروهای آفلاین از دیتابیس گوشی
    var dbVehicles = await DatabaseHelper().getVehicles();
    
    // لود گروه‌ها از سرور
    var result = await ApiService.getRequest('getGroups');
    
    if (mounted) {
      setState(() {
        offlineVehicles = dbVehicles;
        if (result['success']) {
          groups = result['data'];
        }
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('اصالت خودرو', style: TextStyle(fontFamily: 'Vazir', color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadInitialData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بخش گروه‌های سرور
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Text('دسته‌بندی خودروها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Vazir', color: Colors.black87)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GridView.builder(
                        shrinkWrap: true, // برای اینکه داخل اسکرول ویو قرار بگیرد
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
                              // TODO: رفتن به صفحه لیست خودروهای این گروه
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.blue.withOpacity(0.4)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_getIcon(group['icon'] ?? ''), size: 35, color: Colors.blue.shade900),
                                      const SizedBox(height: 8),
                                      Text(
                                        group['name'] ?? '',
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

                    // بخش خودروهای ثبت شده آفلاین در گوشی
                    if (offlineVehicles.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 30, 16, 10),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android, color: Colors.grey, size: 18),
                            SizedBox(width: 5),
                            Text('خودروهای ذخیره شده در گوشی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Vazir', color: Colors.black87)),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offlineVehicles.length,
                        itemBuilder: (context, index) {
                          var car = offlineVehicles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(Icons.directions_car, color: Colors.blue.shade900),
                              ),
                              title: Text(car['car_name'], style: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold)),
                              subtitle: Text(car['manufacturer_group'], style: const TextStyle(fontFamily: 'Vazir', color: Colors.grey)),
                              trailing: car['is_synced'] == 1
                                  ? const Icon(Icons.cloud_done, color: Colors.green) // اگر به سرور رفته
                                  : const Icon(Icons.cloud_off, color: Colors.orange), // اگر فقط در گوشی است
                            ),
                          );
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 80), // فضای خالی برای دکمه شناور پایین صفحه
                  ],
                ),
              ),
            ),

      // دکمه شناور ثبت خودرو
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
          // اگر کاربر خودروای ثبت کرد، لیست آفلاین رو آپدیت کن
          if (result == true) {
            _loadInitialData();
          }
        },
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ثبت خودرو', style: TextStyle(color: Colors.white, fontFamily: 'Vazir', fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}