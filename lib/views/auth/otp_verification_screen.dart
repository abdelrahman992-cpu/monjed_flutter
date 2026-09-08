
import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;

  /// Optional route to go to after successful verification.
  /// Example: '/volunteer'
  final String successRoute;

  const OtpVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
    this.successRoute = '/volunteer',
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final ApiService _api = ApiService();

  final TextEditingController _otpController =
      TextEditingController();

  bool _verifying = false;

  // OTP expires after 10 minutes on the backend.
  int _secondsRemaining = 600;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 600;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();

    if (code.length != 6) {
      _showMessage(
        'Please enter the 6-digit verification code.',
        isError: true,
      );
      return;
    }

    if (_verifying) return;

    setState(() {
      _verifying = true;
    });

    try {
      final response = await _api.post(
        '/auth/verify-otp',
        body: {
          'user_id': widget.userId,
          'code': code,
        },
      );

      if (!mounted) return;

      /*
       * Expected FastAPI response:
       *
       * {
       *   "access_token": "...",
       *   "token_type": "bearer",
       *   "user": {
       *      "user_id": "...",
       *      "display_name": "...",
       *      "role": "volunteer",
       *      ...
       *   }
       * }
       */

      final accessToken =
          response['access_token']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception(
          'No access token returned from server.',
        );
      }

      // ----------------------------------------------------------
      // TODO:
      // Save accessToken locally using SharedPreferences
      // or your AuthController/AuthService.
      //
      // For now we keep it available in this screen and continue.
      // ----------------------------------------------------------

      _timer?.cancel();

      _showMessage(
        'Email verified successfully.',
        isError: false,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        widget.successRoute,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _cleanErrorMessage(e),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _verifying = false;
        });
      }
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('expired')) {
      return 'The verification code has expired. Please request a new one.';
    }

    if (message.contains('Invalid verification code')) {
      return 'Invalid verification code.';
    }

    if (message.contains('No verification request')) {
      return 'No active verification request was found.';
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081214),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFF163237),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2D5C63),
                        ),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: Color(0xFFE8F0E8),
                        size: 38,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  const Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'We sent a 6-digit verification code to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE8F0E8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ------------------------------------------------
                  // OTP FIELD
                  // ------------------------------------------------

                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.20),
                        fontSize: 26,
                        letterSpacing: 8,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF101D20),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF7FA9A9),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      _verifyOtp();
                    },
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // TIMER
                  // ------------------------------------------------

                  if (_secondsRemaining > 0)
                    Text(
                      'Code expires in $_formattedTime',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.60),
                        fontSize: 14,
                      ),
                    )
                  else
                    const Text(
                      'This verification code has expired.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // VERIFY BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _verifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE8F0E8),
                        foregroundColor:
                            const Color(0xFF081214),
                        disabledBackgroundColor:
                            const Color(0xFF596363),
                        disabledForegroundColor:
                            Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Verify code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // DEMO OTP
                  // ------------------------------------------------

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101D20),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF253B3E),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Development mode',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'You can use the DEMO_MASTER_OTP configured on the backend.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // BACK
                  // ------------------------------------------------

                  TextButton(
                    onPressed: _verifying
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFFB7C7C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


