import 'dart:convert';
import 'package:Caption_Calling/features/teams/widgets/jointeam_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'my_teams_page.dart';
// Import for the Team Info Page

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  List<dynamic> teams = []; // List to hold team data
  bool isLoading = true; // State to indicate loading
  String errorMessage = ""; // Error message if API call fails

  // Function to fetch teams from the API
  Future<void> fetchTeams() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String url =
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/user/allteams/${userId ?? ""}'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          final Map<String, dynamic> json = jsonDecode(response.body);
          final List<dynamic> jsonList = json['data'];
          final List<Team> data = jsonList.map((dynamic item) {
            return Team.fromJson(item as Map<String, dynamic>);
          }).toList();
          teams = data;
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          errorMessage = "No teams added.";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load teams.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeams(); // Fetch teams on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : teams.isEmpty
                  ? const Center(
                      child: Text(
                        'No teams found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        Team team = teams[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                team.teamImage ?? '',
                              ),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.sports),
                            ),
                            title: Text(team.teamName ?? 'Unnamed Team'),
                            subtitle: Text(
                              "${team.sport ?? ''} (created by you)",
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.chat),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamInfoPage(
                                    teamId: team.teamID, // Pass team ID
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
