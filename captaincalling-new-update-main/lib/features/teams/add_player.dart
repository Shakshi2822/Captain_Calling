import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 
class AddPlayerPage extends StatefulWidget {
  final int teamIndex;
 
  const AddPlayerPage({super.key, required this.teamIndex});
 
  @override
  _AddPlayerPageState createState() => _AddPlayerPageState();
}
 
class _AddPlayerPageState extends State<AddPlayerPage> {
  final TextEditingController _playerCodeController = TextEditingController();
  bool isLoading = false;
  String feedbackMessage = "";
 
  // Function to check if the player exists and send an invitation
  Future<void> addPlayer() async {
    setState(() {
      isLoading = true;
      feedbackMessage = ""; // Reset feedback message
    });
 
    String playerCode = _playerCodeController.text.trim();
 
    if (playerCode.isEmpty) {
      setState(() {
        feedbackMessage = "Please enter a player code.";
        isLoading = false;
      });
      return;
    }
 
    // API endpoint to check if the player exists
    final apiUrl = Uri.parse(
        'https://captain-calling-server-v1.vercel.app/api/v1/teams/add-player/${widget.teamIndex}/$playerCode');
 
    try {
      final response = await http.post(apiUrl);
 
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['found'] == true) {
          await sendInvitation(playerCode);
        } else {
          setState(() {
            feedbackMessage = "Player not found. Ensure the player is registered.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          feedbackMessage = "Error: Unable to check player.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = "Error: $e";
        isLoading = false;
      });
    }
  }
 
  // Function to send the invitation to the player
  Future<void> sendInvitation(String playerCode) async {
    final apiUrl = Uri.parse(
        'https://captain-calling-server-v1.vercel.app/api/v1/teams/join/${widget.teamIndex}/$playerCode');
 
    try {
      final response = await http.post(apiUrl);
 
      if (response.statusCode == 200) {
        setState(() {
          feedbackMessage = "Invitation sent successfully!";
          isLoading = false;
        });
      } else {
        setState(() {
          feedbackMessage = "Failed to send invitation.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = "Error: $e";
        isLoading = false;
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Player to Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Player Code:",
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _playerCodeController,
              decoration: const InputDecoration(
                labelText: "Player Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addPlayer,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Player'),
            ),
            const SizedBox(height: 20),
            if (feedbackMessage.isNotEmpty)
              Text(
                feedbackMessage,
                style: TextStyle(
                  color: feedbackMessage.contains("Error") || feedbackMessage.contains("not found")
                      ? Colors.red
                      : Colors.green,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}