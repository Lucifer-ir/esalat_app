import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 80, color: Colors.blue.shade200),
            const SizedBox(height: 20),
            const Text('خرید اشتراک', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
            const SizedBox(height: 10),
            const Text('برای استفاده از تمامی امکانات اپلیکیشن، اشتراک ماهانه خود را فعال کنید.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Peyda', color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('پرداخت و تمدید', style: TextStyle(fontFamily: 'Peyda', color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}