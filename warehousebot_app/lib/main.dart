import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/splash/splashScreen.dart';

void main() {
  runApp(const WarehouseBotApp());
}

class WarehouseBotApp extends StatelessWidget {
  const WarehouseBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WarehouseBot App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
