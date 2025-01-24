import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  _RequestStatusPageState createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  String requestStatus = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchRequestStatus();
  }

  Future<void> fetchRequestStatus() async {
    final response = await http.get(Uri.parse('https://yourapi.com/api/user/request-status'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        requestStatus = data['status']; // Assuming response contains a status field
      });
    } else {
      setState(() {
        requestStatus = 'Failed to load status';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Status')),
      body: Center(
        child: Text('Your join request status: $requestStatus'),
      ),
    );
  }
}
