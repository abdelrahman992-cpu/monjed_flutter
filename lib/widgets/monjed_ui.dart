import 'package:flutter/material.dart';

class MonjedColors {
  static const bg = Color(0xFFF6F8FC);
  static const card = Colors.white;
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF718096);
  static const line = Color(0xFFDCE3EC);
  static const blue = Color(0xFF2455D6);
  static const blueSoft = Color(0xFFEAF0FF);
  static const green = Color(0xFF1E9B8A);
  static const greenSoft = Color(0xFFE4F6F3);
  static const amber = Color(0xFFF0A11A);
  static const red = Color(0xFFD94A6A);
}

class MonjedShell extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final Widget child;
  final List<Widget>? actions;
  final bool showBack;

  const MonjedShell({
    super.key,
    required this.title,
    required this.child,
    this.eyebrow,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonjedColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: MonjedColors.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    const _Brand(),
                    const SizedBox(width: 36),
                    if (MediaQuery.sizeOf(context).width > 720) ...[
                      _nav(context, 'Home', '/'),
                      _nav(context, 'Map', '/map'),
                      _nav(context, 'Report', '/report'),
                      _nav(context, 'Request help', '/help'),
                    ],
                    const Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBack)
                          TextButton.icon(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back'),
                            style: TextButton.styleFrom(
                              foregroundColor: MonjedColors.muted,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        if (eyebrow != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            eyebrow!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 2.2,
                              color: Color(0xFF5E7DCB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: MonjedColors.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        child,
                      ],
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

  Widget _nav(BuildContext context, String label, String route) {
    return TextButton(
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      ),
      child: Text(
        label,
        style: const TextStyle(color: MonjedColors.muted, fontSize: 13),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD8E2F4), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.radio_button_checked, size: 13, color: MonjedColors.blue),
          ),
        ),
        const SizedBox(width: 9),
        const Text('MONJED', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: MonjedColors.ink)),
      ],
    );
  }
}

class MonjedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const MonjedCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MonjedColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  const StatCard({super.key, required this.label, required this.value, required this.icon, this.tint = MonjedColors.blueSoft});
  @override
  Widget build(BuildContext context) => MonjedCard(
        child: Row(
          children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: MonjedColors.blue, size: 21)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: MonjedColors.muted, letterSpacing: .4)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: MonjedColors.ink))])),
          ],
        ),
      );
}

InputDecoration monjedInput(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFABB7C6), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: MonjedColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: MonjedColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: MonjedColors.blue)),
    );
