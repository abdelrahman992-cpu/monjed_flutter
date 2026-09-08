import '../core/network/api_service.dart';

class UsersController {
  final ApiService api = ApiService();

  Future<dynamic> getUsers() async {
    return await api.get('/users');
  }

  Future<dynamic> getUserProfile(String userId) async {
    return await api.get(
      '/users/$userId/profile',
    );
  }
}
