import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isLoading = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final res = await AuthService.loginUser(
      email: _email.text,
      password: _password.text,
      role: "user", // change role if needed
    );

    setState(() => isLoading = false);

    if (res['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome to WarehouseBot App",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _email,
                validator: Validators.validateEmail,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _password,
                validator: Validators.validatePassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
