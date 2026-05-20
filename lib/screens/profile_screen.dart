import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 40, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 20),
          const Text('حساب کاربری', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
          const SizedBox(height: 10),
          const Text('نام کاربری: 09123456789', style: TextStyle(fontFamily: 'Peyda', color: Colors.grey)),
        ],
      ),
    );
  }
}