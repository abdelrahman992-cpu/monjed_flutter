import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class LoginScreenVolunteer extends StatefulWidget {
  const LoginScreenVolunteer({super.key});

  @override
  State<LoginScreenVolunteer> createState() => _LoginScreenVolunteerState();
}

class _LoginScreenVolunteerState extends State<LoginScreenVolunteer> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email/phone and password.',
          ),
        ),
      );
      return;
    }

    // TODO:
    // Connect this later to:
    // POST /auth/login
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
                  padding: const EdgeInsets.only(
                    left: 92,
                  ),
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
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // BACK
                          // ==================================================

                          TextButton.icon(
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.home,
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.arrow_back,
                              size: 17,
                              color: Color(0xFF71829A),
                            ),

                            label: const Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFF71829A),
                                fontSize: 13,
                              ),
                            ),

                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                          ),

                          const SizedBox(height: 45),

                          // ==================================================
                          // SMALL TITLE
                          // ==================================================

                          const Text(
                            'VOLUNTEER ACCESS',
                            style: TextStyle(
                              color: Color(0xFF5F83D7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                            ),
                          ),

                          const SizedBox(height: 13),

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

                          const SizedBox(height: 10),

                          const Text(
                            'Log in with the email or phone you registered as a volunteer.',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 25),

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
                            keyboardType:
                                TextInputType.emailAddress,

                            decoration: InputDecoration(
                              hintText:
                                  'you@example.com or +2547...',

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

                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
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
                                  color: const Color(
                                    0xFF8291A5,
                                  ),
                                ),

                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                              ),

                              filled: true,
                              fillColor: Colors.white,

                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
                                  color: Color(0xFFD6DEE9),
                                ),
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(6),

                                borderSide:
                                    const BorderSide(
                                  color: Color(0xFF2455D6),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // LOGIN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 37,

                            child: ElevatedButton(
                              onPressed: _login,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2455D6),

                                foregroundColor:
                                    Colors.white,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                              ),

                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // ==================================================
                          // LINKS
                          // ==================================================

                          Center(
                            child: Wrap(
                              alignment:
                                  WrapAlignment.center,

                              children: [
                                // ------------------------------------------------
                                // REGISTER AS VOLUNTEER
                                // ------------------------------------------------

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.volunteerSignup,
                                    );
                                  },

                                  style:
                                      TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize
                                            .shrinkWrap,
                                  ),

                                  child: const Text(
                                    'Register as a volunteer',
                                    style: TextStyle(
                                      color:
                                          Color(0xFF3563C7),
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const Text(
                                  ' · ',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF3563C7),
                                  ),
                                ),

                                // ------------------------------------------------
                                // STAFF LOGIN
                                // ------------------------------------------------

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.adminLogin,
                                    );
                                  },

                                  style:
                                      TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize
                                            .shrinkWrap,
                                  ),

                                  child: const Text(
                                    'Staff login',
                                    style: TextStyle(
                                      color:
                                          Color(0xFF3563C7),
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w600,
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
              height: 35,
              width: double.infinity,

              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD9E0EA),
                  ),
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 92,
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: const [
                    Text(
                      'FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED',
                      style: TextStyle(
                        color: Color(0xFF8B9AAF),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),

                    Text(
                      'LIVE API: FLOOD RISK · COMMUNITY REPORT ANALYZE',
                      style: TextStyle(
                        color: Color(0xFF8B9AAF),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
