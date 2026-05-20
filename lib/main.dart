import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const EsalatCarApp(),
    ),
  );
}

class EsalatCarApp extends StatelessWidget {
  const EsalatCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'اصالت خودرو',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1), // آبی تیره
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // پس‌زمینه روشن
        fontFamily: 'Vazir',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0D47A1)),
          titleTextStyle: TextStyle(color: Color(0xFF0D47A1), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Vazir'),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF1E88E5), // آبی روشن‌تر برای دارک
        scaffoldBackgroundColor: const Color(0xFF121212), // پس‌زمینه تاریک
        fontFamily: 'Vazir',
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}