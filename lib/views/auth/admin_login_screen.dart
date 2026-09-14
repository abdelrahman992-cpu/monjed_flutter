import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/monjed_ui.dart';
import '../../routes/app_routes.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;
  final _repo = AuthRepository(apiService: ApiService());

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_id.text.trim().isEmpty || _pw.text.isEmpty) return;

    setState(() => _busy = true);
    try {
      final r = await _repo.adminLogin(
        identifier: _id.text.trim(),
        password: _pw.text,
      );

      final api = ApiService();
      await api.saveToken(r.accessToken);
      await api.saveUserData(
        userId: r.user.userId,
        role: r.user.role,
        displayName: r.user.displayName ?? 'Admin',
        email: r.user.email ?? '',
        phone: r.user.phone,
        zoneId: r.user.zoneId,
        country: r.user.country,
      );

      if (!mounted) return;
      AuthService.login();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.admin,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                        icon: const Icon(Icons.volunteer_activism_outlined),
                        label: const Text('Volunteer login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MonjedColors.blue,
                          side: const BorderSide(color: MonjedColors.line),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
