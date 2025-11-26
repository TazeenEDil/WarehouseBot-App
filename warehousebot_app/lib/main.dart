import 'package:flutter/material.dart';
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
      home: const SplashScreen(),
    );
  }
}
