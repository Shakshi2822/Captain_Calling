import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class ApprovalPage extends StatefulWidget {
  final String teamId;
  final String captainId;

  const ApprovalPage({required this.teamId, required this.captainId, super.key});

  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<JoinRequest> pendingRequests = [];
  late WebSocketChannel channel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setupWebSocket();
    fetchPendingRequests();
  }

  // Setup WebSocket connection
  void setupWebSocket() {
    final wsUrl = 'wss://your-websocket-url.com'; // Replace with your WebSocket URL
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // Listen for incoming messages
    channel.stream.listen((message) {
      final notification = jsonDecode(message);
      if (notification['type'] == 'join_request' &&
          notification['teamId'] == widget.teamId) {
        showJoinRequestPopup(notification);
        fetchPendingRequests(); // Refresh pending requests
      }
    });
  }

  // Show popup when a join request is received
  void showJoinRequestPopup(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Join Request'),
          content: Text('${notification['userName']} has requested to join your team.'),
          actions: [
            TextButton(
              onPressed: () {
                approveRequest(notification['requestId']);
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                rejectRequest(notification['requestId']);
                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // Fetch pending requests from the API
  Future<void> fetchPendingRequests() async {
    final url = Uri.parse('https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/join-requests/:teamId/:userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pendingRequests = data.map((json) => JoinRequest.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch pending requests');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Approve a join request
  Future<void> approveRequest(String requestId) async {
    final url = Uri.parse('https://your-api-url.com/api/v1/requests/$requestId/approve');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved successfully!')),
        );
        fetchPendingRequests(); // Refresh pending requests
      } else {
        throw Exception('Failed to approve request: ${response.body}');
      }
    } catch (e) {
      print('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Reject a join request
  Future<void> rejectRequest(String requestId) async {
    final url = Uri.parse('https://your-api-url.com/api/v1/requests/$requestId/reject');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected successfully!')),
        );
        fetchPendingRequests(); // Refresh pending requests
      } else {
        throw Exception('Failed to reject request: ${response.body}');
      }
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Requests')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          final request = pendingRequests[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(request.userName),
              subtitle: Text('User ID: ${request.userId}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await approveRequest(request.requestId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await rejectRequest(request.requestId);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}

// JoinRequest model
class JoinRequest {
  final String requestId;
  final String userId;
  final String userName;

  JoinRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      userName: json['userName'],
    );
  }
}
