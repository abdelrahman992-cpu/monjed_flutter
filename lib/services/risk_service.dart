import 'dart:convert';

import '../core/network/api_client.dart';
import '../models/risk_snapshot.dart';

class RiskService {
  static Future<List<RiskSnapshot>> getRiskSnapshots() async {
    final response = await ApiClient.get('/api/risk/');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load risk data: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (item) => RiskSnapshot.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
