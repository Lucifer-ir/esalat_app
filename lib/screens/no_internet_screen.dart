import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'اتصال ناموفق',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Peyda', color: Colors.black87),
                ),
                const SizedBox(height: 10),
                const Text(
                  'لطفاً اتصال اینترنت خود را بررسی کرده و دوباره تلاش کنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: 'Peyda', color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('تلاش مجدد', style: TextStyle(fontFamily: 'Peyda', color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}