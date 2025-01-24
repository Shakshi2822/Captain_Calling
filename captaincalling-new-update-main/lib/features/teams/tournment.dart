import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  _TournamentPageState createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> exploreTournaments = [];
  List<dynamic> manageTournaments = [];
  bool isLoading = true;
  String errorMessage = "";
  bool isCaptain = true; // This should be set dynamically based on user role.

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTournaments(); // Fetch tournaments on initialization
  }

  // Function to fetch tournaments from API
  Future<void> fetchTournaments() async {
    const url = 'https://captain-calling-server-v1.vercel.app/api/v1/tournament/active-tournaments'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exploreTournaments = data['explore']; // Assuming API response contains "explore" data
          manageTournaments = data['manage'];   // Assuming API response contains "manage" data
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load tournaments.";
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

  // Function to handle "End Tournament"
  Future<void> endTournament(String tournamentId) async {
    final url = Uri.parse(
        'https://your-api-url.com/api/v1/tournaments/end/$tournamentId'); // Replace with your API endpoint

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament ended successfully!')),
        );
        fetchTournaments(); // Refresh tournaments
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to end tournament.')),
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
      appBar: AppBar(
        title: const Text('Tournaments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'EXPLORE'),
            Tab(text: 'MANAGE'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Explore Tab
          ListView.builder(
            itemCount: exploreTournaments.length,
            itemBuilder: (context, index) {
              final tournament = exploreTournaments[index];
              return _buildExploreTournamentCard(tournament);
            },
          ),
          // Manage Tab
          isCaptain
              ? ListView.builder(
            itemCount: manageTournaments.length,
            itemBuilder: (context, index) {
              final tournament = manageTournaments[index];
              return _buildManageTournamentCard(tournament);
            },
          )
              : const Center(
            child: Text(
              "Only captains can manage tournaments.",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle "Add Tournament" action
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget to build tournament card for Explore Tab
  Widget _buildExploreTournamentCard(dynamic tournament) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              tournament['imageUrl'] ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament['name'] ?? 'Unnamed Tournament',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '${tournament['startDate']} - ${tournament['endDate']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build tournament card for Manage Tab
  Widget _buildManageTournamentCard(dynamic tournament) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              tournament['imageUrl'] ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament['name'] ?? 'Unnamed Tournament',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '${tournament['startDate']} - ${tournament['endDate']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  tournament['status'] ?? 'Status: Ongoing',
                  style: const TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle Manage button action
                  },
                  child: const Text('Manage'),
                ),
                TextButton(
                  onPressed: () {
                    endTournament(tournament['id']); // End Tournament
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('End Tournament'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
