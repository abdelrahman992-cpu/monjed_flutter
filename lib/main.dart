import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

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

      initialRoute: AppRoutes.home,

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
