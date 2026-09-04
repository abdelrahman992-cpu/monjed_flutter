import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';

import '../views/home/landing_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/admin_login_screen.dart';
import '../views/map/map_screen.dart';
import '../views/reports/report_screen.dart';
import '../views/help/help_screen.dart';
import '../views/volunteer/volunteer_screen.dart';
import '../views/contact/contact_screen.dart';
import '../views/trends/trends_screen.dart';
import '../views/dashboard/admin_screen.dart';
import '../views/dashboard/volunteer_dashboard_screen.dart';
import '../views/not_found/not_found_screen.dart';
import '../views/about/about.dart';
import '../views/auth/signup_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String map = '/map';
  static const String report = '/report';
  static const String help = '/help';
  static const String volunteer = '/volunteer';
  static const String contact = '/contact';
  static const String trends = '/trends';
  static const String admin = '/admin';
  static const String volunteerDashboard = '/volunteer-dashboard';
  static const String notFound = '/404';
  static const String about = '/about';
  static const String signup = '/signup';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ============================================================
      // HOME
      // ============================================================

      case home:
        return MaterialPageRoute(
          builder: (_) => const LandingScreen(),
        );

      // ============================================================
      // LOGIN
      // ============================================================

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
        case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );

      // ============================================================
      // ADMIN LOGIN
      // ============================================================

      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
        );

      // ============================================================
      // MAP - PROTECTED
      // ============================================================

      case map:
        if (!AuthService.isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const MapScreen(),
        );

      // ============================================================
      // REPORT
      // ============================================================

      case report:
        return MaterialPageRoute(
          builder: (_) => const ReportScreen(),
        );

      // ============================================================
      // HELP
      // ============================================================

      case help:
        return MaterialPageRoute(
          builder: (_) => const HelpScreen(),
        );

      // ============================================================
      // VOLUNTEER - PROTECTED
      // ============================================================

      case volunteer:
        if (!AuthService.isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const VolunteerScreen(),
        );

      // ============================================================
      // CONTACT
      // ============================================================

      case contact:
        return MaterialPageRoute(
          builder: (_) => const ContactScreen(),
        );

      // ============================================================
      // TRENDS
      // ============================================================

      case trends:
        return MaterialPageRoute(
          builder: (_) => const TrendsScreen(),
        );

      // ============================================================
      // ADMIN
      // ============================================================

      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminScreen(),
        );

      // ============================================================
      // VOLUNTEER DASHBOARD
      // ============================================================

      case volunteerDashboard:
        return MaterialPageRoute(
          builder: (_) => const VolunteerDashboardScreen(),
        );

      // ============================================================
      // 404
      // ============================================================
case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
        
    }
  }
}
