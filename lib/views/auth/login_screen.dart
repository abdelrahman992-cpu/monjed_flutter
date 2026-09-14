import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../models/Auth_and_User_Models.dart';
import 'otp_verification_screen.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email/phone and password.')),
      );
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _authController.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      if (result is OTPRequiredResponse) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              userId: result.userId,
              email: result.email,
              successRoute: AppRoutes.map,
            ),
          ),
        );
        return;
      }

      if (result is AuthResponse) {
        
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.map,
          (route) => false,
        );
        return;
      }

      throw Exception('Unexpected login response.');
    } catch (e) {
      if (!mounted) return;
      var message = e.toString().replaceFirst('Exception: ', '');
      if (message.contains('SocketException')) {
        message = 'Cannot connect to MONJED server.';
      } else if (message.isEmpty) {
        message = 'Login failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================
            Container(
              height: 52,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFD9E0EA),
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD9E5F5),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.radio_button_checked,
                            size: 14,
                            color: Color(0xFF2455D6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'MONJED',
                        style: TextStyle(
                          color: Color(0xFF273348),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================================
            // CONTENT
            // ==========================================================
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // SMALL TITLE
                          // ==================================================
                          const Text(
                            'SIGN IN  ·  ALERTS READY',
                            style: TextStyle(
                              color: Color(0xFF5F83D7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // TITLE
                          // ==================================================
                          const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFF101827),
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Log in with the email or phone you registered with to open the map, report, and request help.',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // EMAIL / PHONE
                          // ==================================================
                          const Text(
                            'Email or phone',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'you@example.com or +2547...',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB1BDCC),
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 17,
                                color: Color(0xFF8291A5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2455D6),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // PASSWORD
                          // ==================================================
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 17,
                                color: Color(0xFF8291A5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: const Color(0xFF8291A5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2455D6),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // LOGIN BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2455D6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // LINKS (Create an account)
                          // ==================================================
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'New here? ',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.signup,
                                    );
                                  },
                                  child: const Text(
                                    'Create an account',
                                    style: TextStyle(
                                      color: Color(0xFF2455D6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // VOLUNTEER / OPS SIGN-IN LINK
                          // ==================================================
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Volunteer or operations staff? ',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.adminLogin,
                                    );
                                  },
                                  child: const Text(
                                    'Use the volunteer / ops sign-in.',
                                    style: TextStyle(
                                      color: Color(0xFF2455D6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================================
            // FOOTER
            // ==========================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD9E0EA),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED',
                      style: TextStyle(
                        color: Color(0xFF8B9AAF),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'LIVE API · COMMUNITY REPORT',
                    style: TextStyle(
                      color: Color(0xFF8B9AAF),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
