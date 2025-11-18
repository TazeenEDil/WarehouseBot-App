import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/validators.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TokenManager.init(); // now inside validators.dart

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
