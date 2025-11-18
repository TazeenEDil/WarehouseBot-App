import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    String? token = TokenManager.getToken();
    String? tokenErr = Validators.validateTokenFormat(token);

    await Future.delayed(const Duration(seconds: 2));

    if (tokenErr != null || TokenManager.isExpired()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) =>  DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // or your app primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/robot_splashscreen.png', // path to your image
              width: 150,
              height: 150,
            ),
             const SizedBox(height: 20),
             const Text(
              "WarehouseBot App",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}