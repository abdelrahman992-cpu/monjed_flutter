import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081214),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF101D20),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'About MONJED',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ======================================================
              // HEADER
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xFF101D20),
                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                child: Column(
                  children: [

                    // Logo / Icon
                    Container(
                      width: 72,
                      height: 72,

                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.redAccent,
                        size: 38,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'MONJED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'AI-Powered Assistance & Risk Engine',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // ABOUT
              // ======================================================

              const Text(
                'About MONJED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'MONJED is an advanced assistance and risk-engine platform designed to monitor hazards, coordinate responses, and connect volunteers seamlessly.',
                style: TextStyle(
                  color: Color(0xFFB6C0C3),
                  fontSize: 15,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // FEATURES
              // ======================================================

              const Text(
                'What MONJED Does',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              _FeatureCard(
                icon: Icons.radar,
                title: 'Risk Monitoring',
                description:
                    'Monitor active hazards and identify areas with elevated risk levels.',
              ),

              const SizedBox(height: 12),

              _FeatureCard(
                icon: Icons.map_outlined,
                title: 'Live Risk Map',
                description:
                    'Visualize risk zones and reports through an interactive map.',
              ),

              const SizedBox(height: 12),

              _FeatureCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Volunteer Coordination',
                description:
                    'Connect people in need with available volunteers and assistance resources.',
              ),

              const SizedBox(height: 12),

              _FeatureCard(
                icon: Icons.psychology_outlined,
                title: 'AI Decision Support',
                description:
                    'Use intelligent analysis to support risk assessment and response decisions.',
              ),

              const SizedBox(height: 28),

              // ======================================================
              // MISSION
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF101D20),
                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: const [

                    Row(
                      children: [

                        Icon(
                          Icons.flag_outlined,
                          color: Colors.redAccent,
                          size: 25,
                        ),

                        SizedBox(width: 10),

                        Text(
                          'Our Mission',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Text(
                      'To make emergency assistance faster, smarter, and more coordinated by bringing risk intelligence, community reports, and volunteers together in one platform.',
                      style: TextStyle(
                        color: Color(0xFFB6C0C3),
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ======================================================
              // FOOTER
              // ======================================================

              Center(
                child: Text(
                  'MONJED',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Risk Intelligence • Assistance • Community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


// ====================================================================
// FEATURE CARD
// ====================================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: const Color(0xFF101D20),
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.redAccent,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
