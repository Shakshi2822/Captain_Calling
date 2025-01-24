import 'package:Caption_Calling/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key, required String userId, required List primarySports});

  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imageUrl;
  final _teamNameController = TextEditingController();
  final _homeGroundNameController = TextEditingController();
  final _homeGroundLatitudeController = TextEditingController();
  final _homeGroundLongitudeController = TextEditingController();
  final _homeGroundLandmarkController = TextEditingController();
  final _aboutTeamController = TextEditingController();
  String? _teamLevel;
  String? _selectedPrimarySport;
  final _viceCaptainController = TextEditingController();

  List<String> _primarySports = [];
  String? _userId;
  bool _isLoading = false;

  final _storage = FlutterSecureStorage();

  Future<void> _fetchData() async {
    try {
      final userId = await _storage.read(key: 'userId');
      if (userId != null && userId.isNotEmpty) {
        setState(() {
          _userId = userId;
        });
      }

      setState(() {
        _primarySports = ['Football', 'Basketball', 'Cricket', 'Tennis']; // Example static data
      });
    } catch (e) {
      print("Error retrieving data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null || _userId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in!')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final homeGround = {
        'name': _homeGroundNameController.text,
        'latitude': double.tryParse(_homeGroundLatitudeController.text),
        'longitude': double.tryParse(_homeGroundLongitudeController.text),
        'landmark': _homeGroundLandmarkController.text,
      };

      homeGround.removeWhere((key, value) => value == null || value == '');

      final formData = {
        'uniqueId': DateTime.now().millisecondsSinceEpoch.toString(),
        'image': _imageUrl ?? '',
        'teamName': _teamNameController.text,
        'homeGround': homeGround.isEmpty ? null : homeGround,
        'teamLevel': _teamLevel,
        'primarySport': _selectedPrimarySport,
        'aboutTeam': _aboutTeamController.text,
        'captain': _userId,
        'viceCaptain': _viceCaptainController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/teams/create/$_userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team created successfully!')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create team: ${response.body}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _imageUrl == null
                  ? Image.asset('assets/images/img.png', height: 200, fit: BoxFit.cover)
                  : Image.asset(_imageUrl!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a team name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homeGroundNameController,
                decoration: const InputDecoration(labelText: 'Home Ground Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homeGroundLatitudeController,
                decoration: const InputDecoration(labelText: 'Home Ground Latitude', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homeGroundLongitudeController,
                decoration: const InputDecoration(labelText: 'Home Ground Longitude', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homeGroundLandmarkController,
                decoration: const InputDecoration(labelText: 'Home Ground Landmark', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPrimarySport,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPrimarySport = newValue;
                  });
                },
                items: _primarySports
                    .map((sport) => DropdownMenuItem<String>(value: sport, child: Text(sport)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Primary Sport', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please select a primary sport' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutTeamController,
                decoration: const InputDecoration(labelText: 'About the Team', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _teamLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    _teamLevel = newValue;
                  });
                },
                items: ['Beginners', 'Intermediate', 'Expert']
                    .map((level) => DropdownMenuItem<String>(value: level, child: Text(level)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Team Level', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please select a team level' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _viceCaptainController,
                decoration: const InputDecoration(labelText: 'Vice-Captain', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: const Text('Create Team'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
