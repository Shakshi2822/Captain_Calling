import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> verifyOtp(String otp, String phone) async {
  final url = Uri.parse(
      'https://captain-calling-server-v1.vercel.app/api/v1/auth/verify-otp');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'phone': phone,
      'otp': otp,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success']) {
      if (kDebugMode) {
        print("OTP verified successfully");
      }
    } else {
      if (kDebugMode) {
        print("Invalid OTP");
      }
    }
  } else {
    if (kDebugMode) {
      print("Failed to connect to server");
    }
  }
}
