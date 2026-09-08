import '../core/network/api_service.dart';

class AuthController {
  final ApiService api = ApiService();

  Future<dynamic> register(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/auth/register',
      body: body,
    );
  }

  Future<dynamic> login(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/auth/login',
      body: body,
    );
  }

  Future<dynamic> admin(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/auth/admin',
      body: body,
    );
  }

  Future<dynamic> contact(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/auth/contact',
      body: body,
    );
  }
}
