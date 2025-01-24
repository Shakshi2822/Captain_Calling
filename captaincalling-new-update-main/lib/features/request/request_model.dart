import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define the Request model
class Request {
  final String title;
  final String description;
  final String requestId;

  Request({
    required this.title,
    required this.description,
    required this.requestId,
  });
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<Request> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final response = await http.get(Uri.parse('https://yourapi.com/api/team/requests'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        requests = data.map((e) => Request(
            title: e['title'],
            description: e['description'],
            requestId: e['id']
        )).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load requests')));
    }
  }

  Future<void> approveRequest(String requestId) async {
    final response = await http.post(
      Uri.parse('https://yourapi.com/api/team/requests/$requestId/approve'),
    );
    if (response.statusCode == 200) {
      fetchRequests(); // Refresh the request list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request approved')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve request')));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final response = await http.post(
      Uri.parse('https://yourapi.com/api/team/requests/$requestId/reject'),
    );
    if (response.statusCode == 200) {
      fetchRequests(); // Refresh the request list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request rejected')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reject request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(request.title),
              subtitle: Text(request.description),
              trailing: Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => approveRequest(request.requestId),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => rejectRequest(request.requestId),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
