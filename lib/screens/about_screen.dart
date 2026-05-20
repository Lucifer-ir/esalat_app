import 'package:flutter/material.dart';
import 'dart:ui';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // آیکون اصلی برنامه
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.car_repair, 
                          size: 60, 
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // نام برنامه
                      const Text(
                        'اصالت خودرو',
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Peyda',
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // نسخه برنامه
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'نسخه 2.0',
                          style: TextStyle(
                            fontSize: 14, 
                            fontFamily: 'Peyda', 
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // توضیحات
                      const Text(
                        'سامانه جامع بررسی و ثبت مستندات اصالت خودرو\nابزاری حرفه‌ای برای مدیریت اطلاعات وسایل نقلیه',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          fontFamily: 'Peyda', 
                          color: Colors.black54,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      // خط جداکننده
                      Divider(color: Colors.blueGrey.withOpacity(0.2), thickness: 1),
                      const SizedBox(height: 25),
                      
                      // توسعه‌دهنده
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.code, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'توسعه‌دهنده:',
                            style: TextStyle(
                              fontSize: 15, 
                              fontFamily: 'Peyda', 
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text( // کلمه const از اینجا حذف شد
                        'محمد بیرامی جم',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Peyda',
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // وب‌سایت
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language, color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'www.websera.ir',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                fontFamily: 'Peyda',
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}