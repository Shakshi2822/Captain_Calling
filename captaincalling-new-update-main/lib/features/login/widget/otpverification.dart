import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import secure storage

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({required this.phoneNumber, super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false; // Loading state
  final FlutterSecureStorage _storage = FlutterSecureStorage();  // Initialize secure storage

  // Function to verify OTP
  Future<void> verifyOTP(BuildContext context) async {
    String otp = otpController.text.trim();

    // Validate OTP input
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP format. Please enter a valid 4-digit OTP.')),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      // Sending POST request to verify OTP
      final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("SharedPreferences initialized.");
      final response = await http.post(
        Uri.parse('https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/auth/verify-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': widget.phoneNumber, 'otp': otp}),
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await prefs.setString('userId', data['data'] ?? '');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP Verified Successfully!')),
          );

          // Save uniqueId and authToken to secure storage
          final String uniqueId = data['data'] ?? '';
          //final String token = data['data']['token'] ?? '';

          if (uniqueId.isNotEmpty) {
            await _storage.write(key: 'userId', value: uniqueId);  // Store user ID securely
            print("User ID saved securely: $uniqueId");
          }

         // if (token.isNotEmpty) {
       //     await _storage.write(key: 'authToken', value: token);  // Store auth token securely
       //     print("Auth Token saved securely: $token");
         // }

          // Navigate to Home screen after successful OTP verification
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Invalid OTP.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to verify OTP. Please try again.')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgimg.jpeg', // Replace with your asset path
              fit: BoxFit.cover,
            ),
          ),
          // OTP Verification Form
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter the OTP sent to ${widget.phoneNumber}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Phone number display (read-only)
                TextField(
                  controller: TextEditingController(text: widget.phoneNumber),
                  readOnly: true,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                // OTP input field
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                // Verify OTP button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => verifyOTP(context), // Disable button while loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Verify OTP'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
