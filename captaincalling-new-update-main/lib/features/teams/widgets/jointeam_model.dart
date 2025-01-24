class Team {
  final String id;
  final String teamID; // Unique identifier for the team
  final String teamName; // Name of the team
  final String captainName; // Captain of the team
  final int numberOfPlayers; // Number of players in the team
  final String level; // Skill level (e.g., Beginner, Intermediate, Expert)
  final String sport; // Type of sport (e.g., Cricket, Football)
  final String teamImage; // URL for the team's image
  final double latitude; // Team's latitude (for location-based sorting)
  final double longitude; // Team's longitude
  double
      distance; // Distance from the user's current location (calculated at runtime)

  Team({
    required this.id,
    required this.teamID,
    required this.teamName,
    required this.captainName,
    required this.numberOfPlayers,
    required this.level,
    required this.sport,
    required this.teamImage,
    required this.latitude,
    required this.longitude,
    this.distance = 0.0,
  });

  // Factory constructor to create a Team instance from JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['uniqueId'] ?? '',
      teamID: json['_id'] ?? '',
      // Use empty string if 'id' is null
      teamName: json['teamName'] ?? 'Unknown', // Provide fallback name
      captainName:
          json['captainName'] ?? 'Unknown', // Provide fallback captain name
      numberOfPlayers: json['numberOfPlayers'] ?? 0, // Provide default value
      level: json['level'] ?? 'Unknown', // Fallback level
      sport: json['sport'] ?? 'Unknown', // Fallback sport
      teamImage: json['image'] ?? '', // Fallback image URL
      latitude:
          json['latitude']?.toDouble() ?? 0.0, // Ensure latitude is a double
      longitude:
          json['longitude']?.toDouble() ?? 0.0, // Ensure longitude is a double
    );
  }

  // Method to convert a Team instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamName': teamName,
      'captainName': captainName,
      'numberOfPlayers': numberOfPlayers,
      'level': level,
      'sport': sport,
      'teamImage': teamImage,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
