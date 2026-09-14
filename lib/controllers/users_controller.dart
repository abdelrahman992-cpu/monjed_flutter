import '../services/api_service.dart';
import '../models/Auth_and_User_Models.dart';
class UsersController {
  final ApiService api = ApiService();

  Future<dynamic> getUsers() async {
    return await api.get(
      '/users',
    );
  }

  Future<dynamic> getProfile(
    String userId,
  ) async {
    return await api.get(
      '/users/$userId/profile',
    );
  }

  Future<dynamic> updateProfile(
    String userId,
    Map<String, dynamic> body,
  ) async {
    return await api.patch(
      '/users/$userId/profile',
      body: body,
    );
  }
}
