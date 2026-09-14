import 'package:flutter/material.dart';

import '../../widgets/monjed_ui.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MonjedShell(
      title: 'How can we help?',
      eyebrow: 'MONJED · SUPPORT & RESPONSE',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 760;
          final cards = [
            _HelpCard(
              icon: Icons.volunteer_activism_outlined,
              title: 'Request help',
              text: 'Send a request for assistance and share your location and situation with the response team.',
              button: 'Request help',
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/help', (route) => false),
              highlighted: true,
            ),
            _HelpCard(
              icon: Icons.report_problem_outlined,
              title: 'Report a problem',
              text: 'Tell MONJED about flooding, damage, blocked roads, or another community risk.',
              button: 'Report a problem',
              onTap: () => Navigator.pushNamed(context, '/report'),
            ),
            _HelpCard(
              icon: Icons.map_outlined,
              title: 'Open risk map',
              text: 'View the live risk map and available risk information for your area.',
              button: 'Open map',
              onTap: () => Navigator.pushNamed(context, '/map'),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose what you need',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MonjedColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'MONJED connects community reports and assistance requests with the response workflow.',
                style: TextStyle(color: MonjedColors.muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 14), child: card))).toList())
              else
                Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 14), child: card)).toList()),
              const SizedBox(height: 8),
              MonjedCard(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: MonjedColors.blue),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('For immediate danger, contact your local emergency service first.', style: TextStyle(color: MonjedColors.muted, fontSize: 12, height: 1.5))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String button;
  final VoidCallback onTap;
  final bool highlighted;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.button,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return MonjedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: highlighted ? MonjedColors.blueSoft : const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: MonjedColors.blue)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: MonjedColors.ink)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: MonjedColors.muted, fontSize: 12, height: 1.55)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(foregroundColor: MonjedColors.blue, side: const BorderSide(color: MonjedColors.line), padding: const EdgeInsets.symmetric(vertical: 12)), child: Text(button))),
        ],
      ),
    );
  }
}
