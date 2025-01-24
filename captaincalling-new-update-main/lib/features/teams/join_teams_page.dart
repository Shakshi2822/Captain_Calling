import 'package:Caption_Calling/features/teams/widgets/jointeam_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  _JoinTeamPageState createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  List<Team> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  // Fetch teams from the API (or load from local storage)
  Future<List<Team>> fetchTeams() async {
    final url = Uri.parse(
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/all'); // Replace with your API URL
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> jsonList = json['data']['teams'];
        final List<Team> data = jsonList.map((dynamic item) {
          return Team.fromJson(item as Map<String, dynamic>);
        }).toList();
        return data;
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      rethrow;
    }
  }

  // Load the stored teams (or create new teams locally)
  Future<void> loadTeams() async {
    try {
      // Fetch current location
      Position position = await getCurrentLocation();

      // Fetch the teams (either from the API or from local storage)
      List<Team> fetchedTeams = await fetchTeams();
      // Additionally, load the locally created team (if any)
      final prefs = await SharedPreferences.getInstance();
      String? storedTeamJson = prefs.getString('createdTeam');
      if (storedTeamJson != null) {
        // Parse the stored team and add to the list
        final storedTeam = Team.fromJson(jsonDecode(storedTeamJson));
        fetchedTeams.add(storedTeam);
      }

      // Calculate the distance from current location to each team
      for (var team in fetchedTeams) {
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          team.latitude,
          team.longitude,
        );
        team.distance = distanceInMeters;
      }

      // Sort the teams by distance first, then by sport
      fetchedTeams.sort((a, b) {
        int distanceComparison = a.distance.compareTo(b.distance);
        if (distanceComparison == 0) {
          return a.sport.compareTo(b.sport);
        }
        return distanceComparison;
      });

      setState(() {
        teams = fetchedTeams;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading teams: $e');
    }
  }

  // Send join request to the API
  Future<void> joinTeam(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = Uri.parse(
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/join/$userId'); // Replace with your API URL
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Include authorization headers if needed
        },
        body: jsonEncode({
          'teamId': teamId,
          'userId': 'currentUserId', // Replace with the current user's ID
        }),
      );

      if (response.statusCode == 200) {
        // Assume the API returns a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Join request sent to the team captain.')),
        );
      } else {
        // Handle API errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send join request: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error sending join request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Team')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: Image.network(
                      team.teamImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.red,
                        ); // You can replace this with any widget you like.
                      },
                    ),
                    title: Text(team.teamName),
                    subtitle: Text('Captain: ${team.captainName}\n'
                        'Players: ${team.numberOfPlayers}\n'
                        'Level: ${team.level}\n'
                        'Sport: ${team.sport}\n'
                        'Distance: ${(team.distance / 1000).toStringAsFixed(2)} km'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await joinTeam(team.id); // Send join request
                      },
                      child: const Text('Join'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
