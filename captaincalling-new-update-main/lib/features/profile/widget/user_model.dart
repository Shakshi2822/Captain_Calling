class User {
  String name;
  String phoneNumber;
  String email;
  String sport;
  String role;

  User({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.sport,
    required this.role,
  });

  // Method to update user data after successful registration
  static User? currentUser;
  
  // Method to initialize or update user data
  static void updateUser(User user) {
    currentUser = user;
  }

  // Method to fetch user data
  static User? getUser() {
    return currentUser;
  }
}