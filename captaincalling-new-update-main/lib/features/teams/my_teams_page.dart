import 'dart:convert';
import 'package:Caption_Calling/features/teams/widgets/jointeam_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamInfoPage extends StatefulWidget {
  final String teamId;

  const TeamInfoPage({super.key, required this.teamId});

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  Map<String, dynamic> teamInfo = {}; // Team details
  List<dynamic> players = []; // List of players
  bool isLoading = true;

  // Function to fetch team details from API
  Future<void> fetchTeamInfo() async {
    final url = Uri.parse(
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/details/${widget.teamId}'); // Dynamically insert teamId

    try {
      final response = await http.get(url);

      // Log the raw response for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Log the raw body

      if (response.statusCode == 200) {
        // Check if the response is not empty
        if (response.body.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No team data found.')),
          );
          return;
        }

        final data = json.decode(response.body);

        // Debugging - print the parsed data
        print('Parsed Data: $data');

        setState(() {
          teamInfo = data['data']; // Handle null case
          players =
              List.from(data['data']['players'] ?? []); // Ensure it's a list
          isLoading = false;
        });
      } else {
        // Handle non-200 status codes (e.g., 404, 500)
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load team details.')),
        );
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Add player to the team
  Future<void> addPlayer(String input, bool isPhone) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = Uri.parse(
        'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/add-player/${widget.teamId}/${userId}');
    // https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/add-player/:teamId/:userId
    final payload = isPhone
        ? {"phone": input}
        : {"playerId": input}; // Choose payload based on input type

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player added successfully!')),
        );
        fetchTeamInfo(); // Refresh team info after successful addition
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add player: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Show dialog to add player
  void showAddPlayerDialog() {
    final TextEditingController inputController = TextEditingController();
    bool isPhone = false; // Flag to toggle between phone and playerId

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: StatefulBuilder(builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: inputController,
                decoration: InputDecoration(
                  labelText: isPhone ? 'Phone Number' : 'Player ID',
                  hintText: isPhone ? 'Enter phone number' : 'Enter player ID',
                ),
                keyboardType:
                    isPhone ? TextInputType.phone : TextInputType.text,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Use Phone'),
                  Switch(
                    value: isPhone,
                    onChanged: (value) {
                      setDialogState(() {
                        isPhone = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = inputController.text.trim();
              if (input.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Input cannot be empty.')),
                );
                return;
              }
              addPlayer(input, isPhone);
              Navigator.of(context).pop();
            },
            child: const Text('Add Player'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTeamInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Info'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle refresh action
              setState(() {
                isLoading = true;
              });
              fetchTeamInfo();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          // Display team image, fallback icon if image is missing
                          Image.network(
                            teamInfo['image'] ?? '',
                            height: 100,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.sports),
                          ),
                          const SizedBox(height: 10),
                          // Display team name, default if not available
                          Text(
                            teamInfo['teamName'] ?? 'Unnamed Team',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(teamInfo['teamLevel'] ?? ''),
                          Text(teamInfo['primarySport'] ?? ''),
                          Text("${teamInfo['captain']['name']} (Captain)"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons for join requests, edit, etc.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Column(
                          children: [
                            Icon(Icons.group, size: 36),
                            Text('Join Requests'),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.edit, size: 36),
                            Text('Edit Team'),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.sports_handball, size: 36),
                            Text('Challenge'),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.request_page, size: 36),
                            Text('Tournament Requests'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Players",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // List of players
                    ListView.builder(
                      itemCount: players.isEmpty ? 1 : players.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (players.isEmpty) {
                          return const Center(child: Text('No players found.'));
                        }
                        final player = players[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              player['image'] ?? '',
                            ),
                          ),
                          title: Text(player['name'] ?? 'Unknown'),
                        );
                      },
                    ),
                    // Button to add players (you can implement this functionality)
                    ElevatedButton.icon(
                      onPressed: () {
                        showAddPlayerDialog();
                        // Handle add player functionality
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Players'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
