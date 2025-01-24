

import 'package:Caption_Calling/features/profile/widget/otpscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _primarySportController = TextEditingController();
  final TextEditingController _secondarySportController = TextEditingController();
  
  // Sport roles map
  final Map<String, List<String>> sportRoles = {
    'Cricket': ["Batsman", "Bowler", "Wicket Keeper"],
    'Football': ["Striker", "Midfielder", "Defender", "Goalkeeper"],
    'Volleyball': ["Outside Hitter", "Setter", "Libero", "Opposite Hitter"],
    'Kabaddi': ["Raider", "Defender", "All-Rounder"],
  };

  String? _selectedSport;
  String? _selectedPrimarySportRole;
  String? _selectedSecondarySport;
  String? _selectedSecondarySportRole;
  
  // New feature variables for age group and sports level
  String? _selectedAgeGroup;
  String? _selectedSportLevel;

  // Constants for age groups and sports levels
  final List<String> ageGroups = ["<13", "13-17", "17-21", "21-23", "23-45", ">45"];
  final List<String> sportsLevels = ["Beginner", "Intermediate", "Advanced", "Professional"];

  // API URL for registering a new account
  final String apiUrl = 'https://captain-calling-dev-744600285710.asia-south1.run.app/api/v1/auth/register';

  // Function to post the data to the API
  Future<void> _createAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      print("Form validated, proceeding with API call.");

      final Map<String, dynamic> accountData = {
        "name": _nameController.text,
        "phone": _phoneController.text,
        "countryCode": "+91",  // Assuming the country code is India
        "address": {
          "pinCode": _pinCodeController.text,
          "district": _districtController.text,
          "state": _stateController.text,
          "country": _countryController.text,
        },
        "primarySport": _selectedSport,
        "primarySportRole": _selectedPrimarySportRole,
        "secondarySport": _selectedSecondarySport,
        "secondarySportRole": _selectedSecondarySportRole,
        "ageGroup": _selectedAgeGroup,
        "sportLevel": _selectedSportLevel,
      };

      // Log the request body before sending it to verify it's correct
      print("Request Body: ${jsonEncode(accountData)}");

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(accountData),
        );

        // Log the response status and body
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("API Response: $data");

          if (data['success'] == true) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );

            // Navigate to OTP screen for registration verification
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: _phoneController.text)),
            );
          } else {
            // Handle any specific error messages returned from the API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Account creation failed.')),
            );
          }
        } else {
          // If the response is not successful, handle the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User already registered please Login.')),
          );
        }
      } catch (e) {
        // Handle errors in case the API call fails
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pinCodeController,
                decoration: InputDecoration(labelText: 'Pin Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pin code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your district';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Primary Sport'),
                value: _selectedSport,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSport = newValue;
                    _selectedPrimarySportRole = null;  // Reset the primary sport role when sport changes
                  });
                },
                items: sportRoles.keys.map((sport) {
                  return DropdownMenuItem(
                    value: sport,
                    child: Text(sport),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a primary sport';
                  }
                  return null;
                },
              ),
              if (_selectedSport != null)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Primary Sport Role'),
                  value: _selectedPrimarySportRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPrimarySportRole = newValue;
                    });
                  },
                  items: sportRoles[_selectedSport]!.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role for your primary sport';
                    }
                    return null;
                  },
                ),
              // Secondary Sport Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Secondary Sport'),
                value: _selectedSecondarySport,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSecondarySport = newValue;
                    _selectedSecondarySportRole = null;  // Reset the secondary sport role when sport changes
                  });
                },
                items: sportRoles.keys
                    .where((sport) => sport != _selectedSport)  // Exclude primary sport from secondary sport options
                    .map((sport) {
                      return DropdownMenuItem(
                        value: sport,
                        child: Text(sport),
                      );
                    }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a secondary sport';
                  }
                  return null;
                },
              ),
              if (_selectedSecondarySport != null)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Secondary Sport Role'),
                  value: _selectedSecondarySportRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSecondarySportRole = newValue;
                    });
                  },
                  items: sportRoles[_selectedSecondarySport]!.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role for your secondary sport';
                    }
                    return null;
                  },
                ),
              // Age Group Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Age Group'),
                value: _selectedAgeGroup,
                onChanged: (newValue) {
                  setState(() {
                    _selectedAgeGroup = newValue;
                  });
                },
                items: ageGroups.map((ageGroup) {
                  return DropdownMenuItem(
                    value: ageGroup,
                    child: Text(ageGroup),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your age group';
                  }
                  return null;
                },
              ),
              // Sports Level Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Sports Level'),
                value: _selectedSportLevel,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSportLevel = newValue;
                  });
                },
                items: sportsLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your sports level';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAccount,  // Calls the function to post data and navigate to OTP screen
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
