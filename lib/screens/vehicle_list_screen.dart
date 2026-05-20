import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VehicleListScreen extends StatefulWidget {
  final String groupName;
  const VehicleListScreen({super.key, required this.groupName});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  void _loadCars() async {
    var result = await ApiService.getRequest('getGroupCars', extraParams: {'group': widget.groupName});
    if (result['success']) {
      setState(() {
        cars = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'خطا', style: const TextStyle(fontFamily: 'Peyda'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: const TextStyle(fontFamily: 'Peyda', color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
              ? const Center(child: Text('خودرویی یافت نشد', style: TextStyle(fontFamily: 'Peyda', fontSize: 16)))
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    var car = cars[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(Icons.directions_car, color: Colors.blue.shade900),
                        ),
                        title: Text(car['car_name'], style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(car['car_model'] ?? 'بدون مدل', style: const TextStyle(fontFamily: 'Peyda', color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                        onTap: () {
                          // نمایش جزئیات خودرو (موتور، شاسی و غیره) در یک دیالوگ یا صفحه جدید
                          _showCarDetails(car);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showCarDetails(Map car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(car['car_name'], style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('محل حک موتور', car['engine_number_location']),
              _buildDetailRow('فرمت موتور', car['engine_number_format']),
              _buildDetailRow('محل حک شاسی', car['chassis_number_location']),
              _buildDetailRow('فرمت شاسی', car['chassis_number_format']),
              _buildDetailRow('پلاکت مشخصات', car['specs_plate_location']),
              _buildDetailRow('توضیحات', car['other_notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن', style: TextStyle(fontFamily: 'Peyda', color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(child: Text(value.toString(), style: const TextStyle(fontFamily: 'Peyda', color: Colors.black54))),
        ],
      ),
    );
  }
}