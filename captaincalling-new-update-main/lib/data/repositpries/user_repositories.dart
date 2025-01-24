import '../models/user.dart';

class UserRepository {
  Future<User> fetchUserById(String id) async {
    // Placeholder for API call
    return User(id: id, name: 'John Doe', email: 'johndoe@example.com');
  }
}
