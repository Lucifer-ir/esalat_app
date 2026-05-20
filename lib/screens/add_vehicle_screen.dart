import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/database_helper.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // کنترلرهای فیلدها
  final _carNameController = TextEditingController();
  final _carModelController = TextEditingController();
  final _engineLocController = TextEditingController();
  final _engineFormatController = TextEditingController();
  final _chassisLocController = TextEditingController();
  final _chassisFormatController = TextEditingController();
  final _specsPlateController = TextEditingController();
  final _chassisPlateController = TextEditingController();
  final _labelLocController = TextEditingController();
  final _vinLocController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedGroup;
  bool _isLoading = false;

  final List<String> _groups = [
    'ایران خودرو', 'سایپا', 'کرمان موتور', 'مدیران خودرو', 'بهمن موتور', 
    'پارس خودرو', 'موتور سیکلت', 'وارداتی جدید', 'وانت و پیکاپ', 'سایر گروه‌ها'
  ];

  void _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, dynamic> vehicle = {
        'manufacturer_group': _selectedGroup,
        'car_name': _carNameController.text.trim(),
        'car_model': _carModelController.text.trim(),
        'engine_number_location': _engineLocController.text.trim(),
        'engine_number_format': _engineFormatController.text.trim(),
        'chassis_number_location': _chassisLocController.text.trim(),
        'chassis_number_format': _chassisFormatController.text.trim(),
        'specs_plate_location': _specsPlateController.text.trim(),
        'chassis_plate_location': _chassisPlateController.text.trim(),
        'label_location': _labelLocController.text.trim(),
        'vin_location': _vinLocController.text.trim(),
        'other_notes': _notesController.text.trim(),
        'is_synced': 0, // هنوز به سرور ارسال نشده
      };

      try {
        await DatabaseHelper().insertVehicle(vehicle);
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خودرو با موفقیت در گوشی ذخیره شد', style: TextStyle(fontFamily: 'Vazir')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // برگشت به صفحه اصلی
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره‌سازی: $e', style: const TextStyle(fontFamily: 'Vazir')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGlassTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white, fontFamily: 'Vazir'),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Vazir'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                if (label.contains('*') && (value == null || value.isEmpty)) {
                  return 'این فیلد الزامی است';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: const Text('ثبت خودرو جدید', style: TextStyle(fontFamily: 'Vazir', color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // انتخاب گروه (دراپ داون شیشه ای)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGroup,
                          hint: const Text('گروه خودرو *', style: TextStyle(color: Colors.white70, fontFamily: 'Vazir')),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Vazir', fontSize: 16),
                          items: _groups.map((String group) {
                            return DropdownMenuItem<String>(
                              value: group,
                              child: Text(group),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() => _selectedGroup = newValue);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              _buildGlassTextField('نام خودرو *', _carNameController),
              _buildGlassTextField('مدل خودرو', _carModelController),
              _buildGlassTextField('محل حک شماره موتور', _engineLocController),
              _buildGlassTextField('فرمت شماره موتور', _engineFormatController),
              _buildGlassTextField('محل حک شماره شاسی', _chassisLocController),
              _buildGlassTextField('فرمت شماره شاسی', _chassisFormatController),
              _buildGlassTextField('محل نصب پلاکت مشخصات', _specsPlateController),
              _buildGlassTextField('محل نصب پلاکت شاسی', _chassisPlateController),
              _buildGlassTextField('محل نصب لیبل', _labelLocController),
              _buildGlassTextField('محل نصب VIN', _vinLocController),
              _buildGlassTextField('توضیحات', _notesController, maxLines: 3),
              
              const SizedBox(height: 20),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton.icon(
                      onPressed: _saveVehicle,
                      icon: const Icon(Icons.save),
                      label: const Text('ذخیره در گوشی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}