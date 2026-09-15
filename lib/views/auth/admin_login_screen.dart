import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/Auth_and_User_Models.dart';
import '../../routes/app_routes.dart';
import '../../widgets/monjed_ui.dart';
import 'otp_verification_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();

  final AuthController _authController = AuthController();

  bool _busy = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _id.text.trim();
    final password = _pw.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email/phone and password.'),
        ),
      );
      return;
    }

    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      final result = await _authController.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      // ==========================================================
      // OTP REQUIRED
      // ==========================================================

      if (result is OTPRequiredResponse) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              userId: result.userId,
              email: result.email,
              successRoute: AppRoutes.admin,
            ),
          ),
        );

        return;
      }

      // ==========================================================
      // DIRECT LOGIN
      // ==========================================================

      if (result is AuthResponse) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.admin,
          (_) => false,
        );

        return;
      }

      throw Exception('Unexpected login response.');
    } catch (e) {
      if (!mounted) return;

      var message = e.toString().replaceFirst('Exception: ', '');

      if (message.contains('401')) {
        message = 'Invalid email/phone or password.';
      } else if (message.contains('403')) {
        message = 'This account does not have admin access.';
      } else if (message.contains('SocketException')) {
        message = 'Cannot connect to MONJED server.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonjedColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: MonjedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADMIN ACCESS',
                      style: TextStyle(
                        color: Color(0xFF5E7DCB),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Admin login',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Sign in to manage MONJED operations, reports and response requests.',
                      style: TextStyle(
                        color: MonjedColors.muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Email or phone',
                      style: TextStyle(
                        fontSize: 10,
                        color: MonjedColors.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _id,
                      enabled: !_busy,
                      decoration: monjedInput('admin@example.com'),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 10,
                        color: MonjedColors.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _pw,
                      enabled: !_busy,
                      obscureText: true,
                      decoration: monjedInput('Password'),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MonjedColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Log in as admin'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.volunteerLogin,
                                ),
                        icon: const Icon(
                          Icons.volunteer_activism_outlined,
                        ),
                        label: const Text('Volunteer login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MonjedColors.blue,
                          side: const BorderSide(
                            color: MonjedColors.line,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}