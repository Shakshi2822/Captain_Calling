import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/teams/widgets/jointeam_model.dart';
import 'location_service.dart'; // Import location_service.dart

import 'package:geolocator/geolocator.dart';

// Fetching teams from the API
Future<List<Team>> fetchTeams() async {
  final response = await http.get(Uri.parse('https://example.com/api/teams'));

  if (response.statusCode == 200) {
    List<dynamic> teamsJson = json.decode(response.body);
    return teamsJson.map((team) => Team.fromJson(team)).toList();
  } else {
    throw Exception('Failed to load teams');
  }
}

// Function to get the teams and sort them by distance
Future<List<Team>> getSortedTeams() async {
  try {
    Position position = await getCurrentLocation(); // Get current user location
    List<Team> teams = await fetchTeams();

    // Calculate distance for each team
    for (var team in teams) {
      double distance = calculateDistance(position.latitude, position.longitude, team.latitude, team.longitude);
      team.distance = distance; // Store distance in each team
    }

    // Sort teams by distance
    teams.sort((a, b) => a.distance.compareTo(b.distance));

    return teams;
  } catch (e) {
    throw Exception('Failed to load and sort teams');
  }
}
