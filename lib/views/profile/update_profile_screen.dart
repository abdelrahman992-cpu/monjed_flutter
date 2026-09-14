import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../controllers/users_controller.dart';
import '../../models/Auth_and_User_Models.dart';
import '../../services/api_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/monjed_ui.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _users = UsersController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _zone = TextEditingController();
  final _country = TextEditingController();
  final _organization = TextEditingController();
  final _roleTitle = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _notificationConsent = true;
  String _role = 'volunteer';
  String _originalEmail = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _zone.dispose();
    _country.dispose();
    _organization.dispose();
    _roleTitle.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = await _api.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('Your account session could not be found.');
      }

      try {
        final response = await _users.getProfile(userId);
        if (response is Map) {
          final raw = response['data'] is Map ? response['data'] : response;
          final data = Map<String, dynamic>.from(raw);
          _name.text = '${data['display_name'] ?? data['displayName'] ?? ''}';
          _email.text = '${data['email'] ?? data['work_email'] ?? ''}';
          _phone.text = '${data['phone'] ?? ''}';
          _zone.text = '${data['zone_id'] ?? data['zoneId'] ?? ''}';
          _country.text = '${data['country'] ?? ''}';
          _organization.text = '${data['organization'] ?? ''}';
          _roleTitle.text = '${data['role_title'] ?? data['roleTitle'] ?? ''}';
          _notificationConsent = data['notification_consent'] != false;
        }
      } catch (_) {
        // Use cached values below when the profile API is temporarily down.
      }

      if (_name.text.isEmpty) _name.text = await _api.getDisplayName() ?? '';
      if (_email.text.isEmpty) _email.text = await _api.getUserEmail() ?? '';
      if (_zone.text.isEmpty) _zone.text = await _api.getZoneId() ?? '';
      if (_country.text.isEmpty) _country.text = await _api.getCountry() ?? 'Egypt';
      _role = (await AuthService.getRole() ?? await _api.getUserRole() ?? 'volunteer')
          .trim()
          .toLowerCase();
      _originalEmail = _email.text.trim();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    final userId = await _api.getUserId();
    if (userId == null || userId.isEmpty) {
      _show('Session expired. Please log in again.', error: true);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final emailChanged = _email.text.trim() != _originalEmail;

    try {
      final update = UserProfileUpdate(
        displayName: _name.text.trim(),
        roleTitle: _roleTitle.text.trim().isEmpty ? null : _roleTitle.text.trim(),
        organization: _organization.text.trim().isEmpty ? null : _organization.text.trim(),
        workEmail: _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        zoneId: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
        country: _country.text.trim().isEmpty ? null : _country.text.trim(),
        notificationConsent: _notificationConsent,
      );

      final response = await _users.updateProfile(userId, update.toJson());

      // Persist the updated account locally. This is also what lets Home
      // reopen the volunteer dashboard without asking for login again.
      await _api.saveUserData(
        userId: userId,
        role: _role,
        displayName: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        zoneId: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
        country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      );
      await AuthService.login();
      await AuthService.setRole(_role);

      final data = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
      final requiresOtp = data['requires_otp'] == true ||
          data['email_verification_required'] == true ||
          data['verification_required'] == true;

      if (emailChanged && requiresOtp) {
        _show('A verification code was sent to your new email.');
      } else if (emailChanged) {
        _show('Account updated. Check your email for the verification message.');
      } else {
        _show('Account updated successfully.');
      }

      _originalEmail = _email.text.trim();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      _show(_error!, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? MonjedColors.red : MonjedColors.green,
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: MonjedColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: MonjedColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: MonjedColors.blue, width: 1.3),
        ),
      );

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboardType, bool required = false}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      decoration: _decoration(label, icon),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonjedColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 22, 28, 40),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(Icons.arrow_back, size: 16),
                                  label: const Text('Back'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: MonjedColors.muted,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text('Update profile', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: MonjedColors.ink)),
                                const SizedBox(height: 6),
                                const Text('Update your MONJED responder account. Email changes may require verification.', style: TextStyle(color: MonjedColors.muted, fontSize: 12)),
                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9E1E8), border: Border.all(color: const Color(0xFFF2B9C7)), borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: const TextStyle(color: MonjedColors.red))),
                                ],
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: MonjedColors.line), borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ACCOUNT', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: Color(0xFF5E7DCB), fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(builder: (context, c) {
                                        final fields = [
                                          _field(_name, 'Display name', Icons.person_outline, required: true),
                                          _field(_email, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, required: true),
                                          _field(_phone, 'Phone', Icons.phone_outlined, keyboardType: TextInputType.phone),
                                          _field(_roleTitle, 'Role title', Icons.badge_outlined),
                                          _field(_organization, 'Organization', Icons.business_outlined),
                                          _field(_zone, 'Zone ID', Icons.location_on_outlined),
                                          _field(_country, 'Country', Icons.public_outlined),
                                        ];
                                        if (c.maxWidth <= 600) {
                                          return Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 14), child: f)).toList());
                                        }
                                        final rows = <Widget>[];
                                        for (var i = 0; i < fields.length; i += 2) {
                                          rows.add(Row(children: [Expanded(child: fields[i]), const SizedBox(width: 14), Expanded(child: i + 1 < fields.length ? fields[i + 1] : const SizedBox())]));
                                          rows.add(const SizedBox(height: 14));
                                        }
                                        return Column(children: rows);
                                      }),
                                      SwitchListTile.adaptive(
                                        contentPadding: EdgeInsets.zero,
                                        value: _notificationConsent,
                                        onChanged: (v) => setState(() => _notificationConsent = v),
                                        title: const Text('Email notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        subtitle: const Text('Allow MONJED to send account and response updates.', style: TextStyle(fontSize: 11, color: MonjedColors.muted)),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: _saving ? null : _save,
                                          icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined, size: 17),
                                          label: Text(_saving ? 'Saving...' : 'Save changes'),
                                          style: ElevatedButton.styleFrom(backgroundColor: MonjedColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text('Your session and volunteer role stay saved after an update, so returning to Home does not require another login.', style: TextStyle(color: MonjedColors.muted, fontSize: 10, height: 1.4)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: MonjedColors.line))),
      child: Row(
        children: [
          const _Brand(),
          const SizedBox(width: 36),
          TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false), child: const Text('Home')),
          const Spacer(),
          Text(_role.toUpperCase(), style: const TextStyle(fontSize: 10, color: MonjedColors.muted, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(children: [Icon(Icons.radio_button_checked, color: MonjedColors.blue, size: 22), SizedBox(width: 8), Text('MONJED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MonjedColors.ink))]);
}
