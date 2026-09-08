import '../core/network/api_service.dart';

class PipelineController {
  final ApiService api = ApiService();

  Future<dynamic> flood(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/pipeline/flood',
      body: body,
    );
  }

  Future<dynamic> earthquake(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/pipeline/earthquake',
      body: body,
    );
  }
}
