import 'package:flutter/material.dart';

class AppColors {
  // Industrial + modern blend (mix of both figma designs)
  static const Color primary = Color(0xFF0D47A1); // deep industrial blue
  static const Color accent = Color(0xFF0BB3A8); // teal accent
  static const Color card = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF4F6F9);
  static const Color onBg = Color(0xFF0F1724);
  static const Color muted = Color(0xFF7B8896);
}

class Constants {
  // === MUST update these ===
  static const String apiBaseUrl = "http://10.0.2.2:3000"; // change to your backend
  static const String webotsLiveUrl = "http://10.0.2.2:8080"; // change to your Webots UI or stream
  static const Duration sessionDuration = Duration(minutes: 60);
  // Storage keys
  static const String storageTokenKey = "wb_token";
  static const String storageExpiryKey = "wb_token_expiry";
}
