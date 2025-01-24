import 'dart:convert';
import 'package:http/http.dart' as http;
 
class ApiService {
  final String baseUrl = "https://captain-calling-dev-744600285710.asia-south1.run.app/"; // Replace with your API base URL
 
  // Method to send OTP to the user's phone
  Future<bool> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phoneNumber}),
    );
 
    if (response.statusCode == 200) {
      // OTP sent successfully
      return true;
    } else {
      // OTP sending failed
      return false;
    }
  }
 
  // Method to verify OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/verify-login-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phoneNumber,
        'otp': otp,
      }),
    );
 
    if (response.statusCode == 200) {
      // OTP verified successfully
      return true;
    } else {
      // OTP verification failed
      return false;
    }
  }
}