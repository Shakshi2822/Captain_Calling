import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTeamPage extends StatefulWidget {
  final String teamId;

  const EditTeamPage({super.key, required this.teamId});

  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  String? _selectedLevel;
  bool isLoading = true;
  String errorMessage = "";

  // Function to fetch current team details
  Future<void> fetchTeamDetails() async {
    final url = Uri.parse(
        'https://your-api-url.com/api/v1/teams/details/${widget.teamId}'); // Replace with your API endpoint

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _teamNameController.text = data['teamName'] ?? '';
          _sportController.text = data['sport'] ?? '';
          _selectedLevel = data['level'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load team details.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  // Function to update team details
  Future<void> updateTeamDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final url = Uri.parse(
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/edit/:teamId/:userId'); // Replace with your API endpoint
    final body = {
      'teamName': _teamNameController.text.trim(),
      'sport': _sportController.text.trim(),
      'level': _selectedLevel ?? ''
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return success
      } else {
        setState(() {
          errorMessage = "Failed to update team details.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeamDetails(); // Fetch current team details on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Team'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Team Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Team Name",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sport",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _sportController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Sport",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Level",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    items: ['Beginner', 'Intermediate', 'Expert']
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: updateTeamDetails,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
