import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}