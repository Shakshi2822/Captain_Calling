import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Caption_Calling/features/home/home_page.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final String otpVerificationUrl =
      'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/auth/verify-otp';

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Initialize secure storage

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text;

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter OTP')));
      return;
    }

    final Map<String, dynamic> otpData = {
      "phone": widget.phoneNumber,
      "otp": otp,
    };

    try {
      final response = await http.post(
        Uri.parse(otpVerificationUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(otpData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP Verified!')),
          );

          // Save the uniqueId (userId) securely in storage
          // final String uniqueId = data['data']['uniqueId'] ?? '';
          final String uniqueId = data['data'] ?? '';
          if (uniqueId.isNotEmpty) {
            await _storage.write(
                key: 'userId', value: uniqueId); // Store user ID securely
            print("User ID saved securely: $uniqueId");
          }

          // Optionally, you can also save a token if you have one
          // final String token = data['data']['token'] ??
          ''; // Assuming token is part of the response
          // if (token.isNotEmpty) {
          //   await _storage.write(
          //       key: 'authToken', value: token); // Store token securely
          //   print("Auth Token saved securely: $token");
          // }

          // Navigate to the HomeScreen after successful verification
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('OTP verification failed. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error during OTP verification: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/bgimg.jpeg'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A verification code has been sent to ${widget.phoneNumber}.',
                style: TextStyle(
                    color: Colors.black), // Adjust text color for visibility
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  labelStyle:
                      TextStyle(color: Colors.black), // Label text color
                  filled: true,
                  fillColor: Colors.white
                      .withOpacity(0.7), // Input field background color
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Adjust for OTP length
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtp, // Call the OTP verification function
                child: Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
