import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MonjedApp());
}

class MonjedApp extends StatelessWidget {
  const MonjedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MONJED',
      home: const HealthTestPage(),
    );
  }
}

class HealthTestPage extends StatefulWidget {
  const HealthTestPage({super.key});

  @override
  State<HealthTestPage> createState() => _HealthTestPageState();
}

class _HealthTestPageState extends State<HealthTestPage> {
  final ApiService apiService = ApiService();

  String result = 'اضغط الزر لاختبار الاتصال';

  Future<void> testApi() async {
    try {
      final response = await apiService.get('/health');

      setState(() {
        result = response.toString();
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MONJED API Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: testApi,
              child: const Text('Test FastAPI'),
            ),
          ],
        ),
      ),
    );
  }
}
