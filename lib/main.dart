import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // استرجاع حالة تسجيل الدخول المحفوظة
  await AuthService.initialize();

  runApp(const MonjedApp());
}

class MonjedApp extends StatelessWidget {
  const MonjedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MONJED',

      initialRoute: AppRoutes.home,

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}