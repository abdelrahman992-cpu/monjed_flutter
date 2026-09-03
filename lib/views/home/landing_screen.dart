import '../../routes/app_routes.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mapController;

  int selectedReport = 0;
  int selectedLanguage = 0;
  int selectedCountry = 0;
  int openFaq = 0;

  final ScrollController _scrollController = ScrollController();

 List<_CountryRisk> countries = [];

  final List<_ReportType> reportTypes = const [
    _ReportType(
      title: 'WATER RISING',
      icon: Icons.waves,
      description:
          'Cross-checks the flood engine. Repeated reports can raise confidence, but a single tap does not override the risk score.',
    ),
    _ReportType(
      title: 'ROAD BLOCKED',
      icon: Icons.alt_route,
      description:
          'Adds a feasibility signal. Active flood conditions plus clustered reports can trigger route verification.',
    ),
    _ReportType(
      title: 'NEED HELP',
      icon: Icons.sos,
      description:
          'Creates a public help request. Nearby volunteers can see the request after signing in.',
    ),
    _ReportType(
      title: 'NO TRANSPORT',
      icon: Icons.directions_car,
      description:
          'Matches transport-capable volunteers. Mobility assistance can be handled separately.',
    ),
    _ReportType(
      title: 'I AM SAFE',
      icon: Icons.check_circle_outline,
      description:
          'Logs a safe check-in. It does not silently cancel or remove an active alert.',
    ),
  ];

  final List<_AlertLanguage> languages = const [
    _AlertLanguage(
      code: 'EN',
      label: 'English',
      text:
          'HIGH FLOOD RISK IN WESTERN KENYA. Rainfall has been increasing for three days. If the road is flooded, do not wait for another message — move to higher ground. If you cannot move, reply NEED HELP. This is not an earthquake alert.',
    ),
    _AlertLanguage(
      code: 'SW',
      label: 'Swahili',
      text:
          'HATARI KUBWA YA MAFURIKO MAGHARIBI MWA KENYA. Mvua imeongezeka kwa siku tatu. Ikiwa barabara imejaa maji, nenda sehemu ya juu. Ikiwa huwezi kusonga, jibu NEED HELP.',
    ),
    _AlertLanguage(
      code: 'FR',
      label: 'French',
      text:
          'RISQUE ÉLEVÉ D’INONDATION DANS L’OUEST DU KENYA. Les pluies augmentent depuis trois jours. Si la route est inondée, rejoignez un terrain plus élevé. Si vous ne pouvez pas vous déplacer, répondez NEED HELP.',
    ),
    _AlertLanguage(
      code: 'AR',
      label: 'Arabic',
      text:
          'خطر فيضان مرتفع غرب كينيا. الأمطار في تصاعد منذ ثلاثة أيام. إذا كان الطريق مغموراً فلا تنتظر رسالة ثانية — انتقل إلى أرض أعلى. إن لم تستطع الحركة، رد NEED HELP. هذه ليست تنبيه زلزال.',
    ),
    _AlertLanguage(
      code: 'PT',
      label: 'Portuguese',
      text:
          'ALTO RISCO DE INUNDAÇÃO NO OESTE DO QUÊNIA. As chuvas estão aumentando há três dias. Se a estrada estiver inundada, vá para um terreno mais alto. Se não puder se mover, responda NEED HELP.',
    ),
  ];

  final List<String> faqs = const [
    'Is this a trained forecast model?',
    'Why not use one combined risk score?',
    'How precise is the location?',
    'Does MONJED know my personal situation?',
  ];

@override
void initState() {
  super.initState();
  _loadCountries();
}

Future<void> _loadCountries() async {
  try {
    final data = await ApiService().get('/dashboard/risks');

    setState(() {
      countries = (data as List)
          .map((item) => _CountryRisk.fromJson(item))
          .toList();
    });
  } catch (e) {
    debugPrint('Failed to load countries: $e');
  }
}

  @override
  void dispose() {
    _mapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openSection(String id) {
    // Simple placeholder navigation behavior.
    // Real routes can be connected later to your existing Router.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('MONJED: $id'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: _Colors.night,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildHero(context, isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildStats(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildWhyMonjed(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildGap(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildHowItWorks(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildWhyTwoScores(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildFeatures(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildGroundTruth(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildAlertMessage(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildFeasibility(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildRiskSnapshot(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildCoverage(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildResponders(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildFaq(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildFooter(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: _Colors.night.withOpacity( .96),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x223A4547),
          ),
        ),
      ),
      child: Row(
        children: [
          const _MonjedLogo(),

          const Spacer(),

         if (!isMobile) ...[
  _navButton(
    'About us',
    () => _openSection('About us'),
  ),

  _navButton(
    'Contact us',
    () {
      Navigator.pushNamed(
        context,
        AppRoutes.contact,
      );
    },
  ),

  _navButton(
    'Volunteer',
    () {
      Navigator.pushNamed(
        context,
        AppRoutes.volunteer,
      );
    },
  ),

  const SizedBox(width: 18),

  IconButton(
    onPressed: () {},
    icon: const Icon(
      Icons.dark_mode_outlined,
      color: _Colors.bone,
    ),
  ),

  const SizedBox(width: 10),

  ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(
        context,
        AppRoutes.map,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: _Colors.teal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
    ),
    child: const Text('OPEN LIVE MAP'),
  ),
          ] else
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: _Colors.panel,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _mobileNav('About us'),
                        _mobileNav('Contact us'),
                        _mobileNav('Volunteer'),
                        _mobileNav('Open live map'),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.menu,
                color: _Colors.bone,
              ),
            ),
        ],
      ),
    );
  }

  Widget _mobileNav(String text) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(color: _Colors.bone),
      ),
      onTap: () {
        Navigator.pop(context);
        _openSection(text);
      },
    );
  }

  Widget _navButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: _Colors.muted,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(minHeight: 650),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://commons.wikimedia.org/wiki/Special:FilePath/Flooding%20aftermath%20of%20Cyclone%20Idai%2C%20Mozambique%20%289410%29.jpg?width=1400',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity( .88),
              Colors.black.withOpacity( .68),
              Colors.black.withOpacity( .84),
            ],
          ),
        ),
        child: isMobile
            ? Column(
                children: [
                  _heroText(context),
                  const SizedBox(height: 40),
                  _monitoringCard(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: _heroText(context),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 4,
                    child: _monitoringCard(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MonjedLogo(large: true),
        const SizedBox(height: 30),
        const Text(
          'MULTI-HAZARD · LIVE DATA · 20+ COUNTRIES',
          style: TextStyle(
            color: _Colors.tealLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'The signal reaches\nbefore the disaster does.',
          style: TextStyle(
            color: _Colors.bone,
            fontSize: 52,
            height: 1.04,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'MONJED combines live hazard signals, explainable risk scores, '
          'ground reports and human response into one disaster-support platform.',
          style: TextStyle(
            color: _Colors.lightMuted,
            fontSize: 17,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
                onPressed: () {
    Navigator.pushNamed(context, AppRoutes.map);
  },
              icon: const Icon(Icons.map_outlined),
              label: const Text('VIEW LIVE RISK MAP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
  Navigator.pushNamed(
    context,
    AppRoutes.help,
  );
},
              icon: const Icon(Icons.sos),
              label: const Text('REQUEST HELP'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _Colors.bone,
                side: const BorderSide(
                  color: Color(0x88FFFFFF),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Photo: Cyclone Idai aftermath · Mozambique · 2019',
          style: TextStyle(
            color: Color(0x99FFFFFF),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _monitoringCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity( .60),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x447B8A8C),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE MONITORING NETWORK',
                style: TextStyle(
                  color: _Colors.bone,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: _Colors.tealLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 390,
            child: AnimatedBuilder(
              animation: _mapController,
              builder: (_, __) {
                return _AfricaMap(
                  progress: _mapController.value,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _legendDot(_Colors.teal, 'LOW'),
              _legendDot(_Colors.amber, 'MEDIUM'),
              _legendDot(_Colors.rose, 'HIGH'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _Colors.lightMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isMobile) {
    final stats = [
      ('20+', 'COUNTRIES TRACKED'),
      ('2', 'HAZARDS SCORED APART'),
      ('5', 'TYPED REPORT KINDS'),
      ('0', 'COST TO COMMUNITIES'),
    ];

    return _section(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 4,
          mainAxisExtent: 120,
        ),
        itemBuilder: (_, index) {
          return Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _Colors.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x223A4547),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stats[index].$1,
                  style: const TextStyle(
                    color: _Colors.tealLight,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  stats[index].$2,
                  style: const TextStyle(
                    color: _Colors.muted,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhyMonjed(bool isMobile) {
    return _darkSection(
      title: 'WHY MONJED EXISTS',
      child: isMobile
          ? Column(
              children: [
                _whyText(),
                const SizedBox(height: 25),
                _nepalImage(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _whyText()),
                const SizedBox(width: 50),
                Expanded(child: _nepalImage()),
              ],
            ),
    );
  }

  Widget _whyText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disaster information often arrives as disconnected pieces.',
          style: TextStyle(
            color: _Colors.bone,
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'MONJED is designed to connect the signal, the explanation, '
          'the ground truth and the human response.',
          style: TextStyle(
            color: _Colors.lightMuted,
            fontSize: 16,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _nepalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/nepal-before-after.jpg',
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 320,
            color: _Colors.panel,
            alignment: Alignment.center,
            child: const Text(
              'Nepal before / after image',
              style: TextStyle(color: _Colors.muted),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGap(bool isMobile) {
    return _section(
      background: _Colors.night,
      child: isMobile
          ? Column(
              children: [
                _sectionHeading(
                  'THE GAP',
                  'A risk score is useful only when people can understand what it means and act on it.',
                ),
                const SizedBox(height: 30),
                const _BotCard(),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _sectionHeading(
                    'THE GAP',
                    'A risk score is useful only when people can understand what it means and act on it.',
                  ),
                ),
                const SizedBox(width: 50),
                const Expanded(child: _BotCard()),
              ],
            ),
    );
  }

  Widget _buildHowItWorks(bool isMobile) {
    final steps = [
      (
        '01',
        'LIVE SIGNALS',
        'Rainfall and soil inputs feed the flood engine. Earthquake signals are evaluated separately.',
        Icons.sensors,
      ),
      (
        '02',
        'EXPLAINABLE SCORE',
        'A rule-based 0–100 score produces a risk level and plain-language reasons.',
        Icons.analytics_outlined,
      ),
      (
        '03',
        'GROUND TRUTH',
        'Typed community reports can confirm or contradict an alert and add useful context.',
        Icons.fact_check_outlined,
      ),
      (
        '04',
        'HUMAN WHEN STUCK',
        'When an action is unrealistic, volunteers can privately take a request and help.',
        Icons.volunteer_activism_outlined,
      ),
    ];

    return _darkSection(
      title: 'HOW IT WORKS',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          mainAxisExtent: 230,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (_, index) {
          final step = steps[index];

          return _InfoCard(
            number: step.$1,
            title: step.$2,
            text: step.$3,
            icon: step.$4,
          );
        },
      ),
    );
  }

  Widget _buildWhyTwoScores(bool isMobile) {
    return _section(
      background: _Colors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'WHY TWO SCORES',
            'Different hazards behave differently. Keeping their scores independent makes the signal easier to interpret.',
          ),
          const SizedBox(height: 35),
          isMobile
              ? Column(
                  children: [
                    _engineCard(
                      'FLOOD ENGINE',
                      Icons.water_drop_outlined,
                      '0–100',
                      'Rainfall, soil and trend signals',
                    ),
                    const SizedBox(height: 15),
                    _engineCard(
                      'EARTHQUAKE TRACK',
                      Icons.terrain_outlined,
                      '0–100',
                      'Events, magnitude and recent activity',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _engineCard(
                        'FLOOD ENGINE',
                        Icons.water_drop_outlined,
                        '0–100',
                        'Rainfall, soil and trend signals',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _engineCard(
                        'EARTHQUAKE TRACK',
                        Icons.terrain_outlined,
                        '0–100',
                        'Events, magnitude and recent activity',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _engineCard(
    String title,
    IconData icon,
    String score,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _Colors.night,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x223A4547),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _Colors.teal.withOpacity( .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _Colors.tealLight,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _Colors.bone,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    color: _Colors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: _Colors.tealLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isMobile) {
    final features = [
      ('INDEPENDENT ENGINES', 'Flood and earthquake signals stay separate.', Icons.hub_outlined),
      ('PLAIN-LANGUAGE ALERTS', 'People get reasons, not just numbers.', Icons.sms_outlined),
      ('TYPED GROUND REPORTS', 'Reports have clear meanings and actions.', Icons.edit_note_outlined),
      ('HELP WITHOUT AN ACCOUNT', 'Public reporting can start without signing in.', Icons.person_off_outlined),
      ('VOLUNTEER NETWORK', 'Private matching connects requests with responders.', Icons.groups_outlined),
      ('RESPONDER CONSOLE', 'Staff can monitor risk, decisions and alerts.', Icons.dashboard_outlined),
    ];

    return _darkSection(
      title: 'THE PLATFORM',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 3,
          mainAxisExtent: 190,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemBuilder: (_, index) {
          return _FeatureCard(
            title: features[index].$1,
            text: features[index].$2,
            icon: features[index].$3,
          );
        },
      ),
    );
  }

  Widget _buildGroundTruth(bool isMobile) {
    final report = reportTypes[selectedReport];

    return _section(
      background: _Colors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'GROUND TRUTH',
            'Community reports help MONJED understand what is actually happening on the ground.',
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              reportTypes.length,
              (index) {
                final selected = selectedReport == index;

                return ChoiceChip(
                  selected: selected,
                  label: Text(reportTypes[index].title),
                  avatar: Icon(
                    reportTypes[index].icon,
                    size: 17,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedReport = index;
                    });
                  },
                  selectedColor: _Colors.teal,
                  backgroundColor: _Colors.night,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _Colors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: _Colors.night,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        report.icon,
                        color: _Colors.tealLight,
                        size: 40,
                      ),
                      const SizedBox(height: 15),
                      _reportDescription(report),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        report.icon,
                        color: _Colors.tealLight,
                        size: 45,
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: _reportDescription(report)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reportDescription(_ReportType report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.title,
          style: const TextStyle(
            color: _Colors.bone,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          report.description,
          style: const TextStyle(
            color: _Colors.lightMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'CONFIDENCE RULE',
          style: TextStyle(
            color: _Colors.tealLight,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Reports support the signal; they do not silently replace the underlying risk score.',
          style: TextStyle(
            color: _Colors.muted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertMessage(bool isMobile) {
    final language = languages[selectedLanguage];
    final isArabic = language.code == 'AR';

    return _darkSection(
      title: 'THE MESSAGE THAT ARRIVES',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: List.generate(
              languages.length,
              (index) {
                final selected = selectedLanguage == index;

                return ChoiceChip(
                  selected: selected,
                  label: Text(languages[index].code),
                  onSelected: (_) {
                    setState(() {
                      selectedLanguage = index;
                    });
                  },
                  selectedColor: _Colors.teal,
                  backgroundColor: _Colors.panel,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _Colors.muted,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: _Colors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x223A4547),
              ),
            ),
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                language.text,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: _Colors.bone,
                  fontSize: 17,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeasibility(bool isMobile) {
    final items = [
      ('01', 'ALERT ISSUED', Icons.warning_amber_outlined),
      ('02', 'REPORTS IN SAME ZONE', Icons.location_on_outlined),
      ('03', 'FLAG + HUMAN', Icons.person_search_outlined),
    ];

    return _section(
      background: _Colors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'FEASIBILITY LAYER',
            'A technically correct alert is not enough if the recommended action cannot actually be followed.',
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisExtent: 180,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (_, index) {
              return _InfoCard(
                number: items[index].$1,
                title: items[index].$2,
                text: index == 0
                    ? 'Risk engine produces an alert.'
                    : index == 1
                        ? 'Nearby reports add ground context.'
                        : 'If the action looks unrealistic, a human can intervene.',
                icon: items[index].$3,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSnapshot(bool isMobile) {
    final country = countries[selectedCountry];

    return _darkSection(
      title: 'LIVE RISK SNAPSHOT',
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: _Colors.tealLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                dataTextStyle: const TextStyle(
                  color: _Colors.bone,
                  fontSize: 12,
                ),
                columns: const [
                  DataColumn(label: Text('COUNTRY')),
                  DataColumn(label: Text('FLOOD')),
                  DataColumn(label: Text('EARTHQUAKE')),
                ],
                rows: List.generate(
                  countries.length,
                  (index) {
                    final item = countries[index];

                    return DataRow(
                      selected: selectedCountry == index,
                      onSelectChanged: (_) {
                        setState(() {
                          selectedCountry = index;
                        });
                      },
                      cells: [
                        DataCell(Text('${item.code} · ${item.name}')),
                        DataCell(_riskBadge(item.flood)),
                        DataCell(_riskBadge(item.earthquake)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: _Colors.panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: const TextStyle(
                          color: _Colors.bone,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _scoreBox(
                        'FLOOD',
                        country.floodScore,
                        country.flood,
                      ),
                      const SizedBox(height: 12),
                      _scoreBox(
                        'EARTHQUAKE',
                        country.earthquakeScore,
                        country.earthquake,
                      ),
                      const SizedBox(height: 20),
                      _reasons(country),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country.name,
                              style: const TextStyle(
                                color: _Colors.bone,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _reasons(country),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      _scoreBox(
                        'FLOOD',
                        country.floodScore,
                        country.flood,
                      ),
                      const SizedBox(width: 15),
                      _scoreBox(
                        'EARTHQUAKE',
                        country.earthquakeScore,
                        country.earthquake,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reasons(_CountryRisk country) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHY',
          style: TextStyle(
            color: _Colors.tealLight,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ...country.reasons.map(
          (reason) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(color: _Colors.tealLight),
                ),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      color: _Colors.lightMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreBox(String title, int score, String level) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Colors.night,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _Colors.muted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$score',
            style: const TextStyle(
              color: _Colors.bone,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          _riskBadge(level),
        ],
      ),
    );
  }

  Widget _riskBadge(String level) {
    Color color;

    switch (level.toUpperCase()) {
      case 'HIGH':
        color = _Colors.rose;
        break;
      case 'MEDIUM':
        color = _Colors.amber;
        break;
      default:
        color = _Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity( .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity( .45),
        ),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: .7,
        ),
      ),
    );
  }

  Widget _buildCoverage(bool isMobile) {
    final images = [
      (
        'Flooding aftermath of Cyclone Idai',
        'Beira, Mozambique · Mar 2019',
        'https://commons.wikimedia.org/wiki/Special:FilePath/Flooding%20aftermath%20of%20Cyclone%20Idai%2C%20Mozambique%20%289410%29.jpg?width=1400',
      ),
      (
        'Flooding near the Zambezi Delta',
        'Mozambique · Mar 2019',
        'https://commons.wikimedia.org/wiki/Special:FilePath/Flood%20near%20Zambezi%20Delta%20after%20Cyclone%20Idai.jpg?width=1400',
      ),
      (
        'Emergency shelter after Morocco earthquake',
        'Amizmiz, Morocco · Sep 2023',
        'https://commons.wikimedia.org/wiki/Special:FilePath/Campmint%20Amezmiz.jpg?width=1400',
      ),
    ];

    const coverage = [
      'Morocco',
      'Algeria',
      'Egypt',
      'Sudan',
      'Ethiopia',
      'Somalia',
      'Senegal',
      'Mali',
      'Ghana',
      'Nigeria',
      'Cameroon',
      'DR Congo',
      'Uganda',
      'Kenya',
      'Rwanda',
      'Tanzania',
      'Zambia',
      'Mozambique',
      'Madagascar',
      'South Africa',
    ];

    return _section(
      background: _Colors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'COVERAGE',
            'MONJED is designed for a growing network across Africa, with country-level monitoring in the MVP.',
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: coverage
                .map(
                  (country) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _Colors.night,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0x223A4547),
                      ),
                    ),
                    child: Text(
                      country,
                      style: const TextStyle(
                        color: _Colors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisExtent: 300,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (_, index) {
              final image = images[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image.$3,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: _Colors.night,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: _Colors.muted,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xDD000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            image.$2,
                            style: const TextStyle(
                              color: Color(0xBBFFFFFF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponders(bool isMobile) {
    return _darkSection(
      title: 'RESPONDERS',
      child: isMobile
          ? Column(
              children: [
                _responderCard(
                  'NEED HELP',
                  'Request assistance from nearby volunteers.',
                  Icons.sos,
                  () {
  Navigator.pushNamed(
    context,
    AppRoutes.help,
  );
},
                ),
                const SizedBox(height: 15),
                _responderCard(
                  'WANT TO HELP',
                  'Join the volunteer response network.',
                  Icons.volunteer_activism,
                  () {
  Navigator.pushNamed(
    context,
    AppRoutes.volunteer,
  );
},
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _responderCard(
                    'NEED HELP',
                    'Request assistance from nearby volunteers.',
                    Icons.sos,
                    () {
  Navigator.pushNamed(
    context,
    AppRoutes.help,
  );
},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _responderCard(
                    'WANT TO HELP',
                    'Join the volunteer response network.',
                    Icons.volunteer_activism,
                    () {
  Navigator.pushNamed(
    context,
    AppRoutes.volunteer,
  );
},
                  ),
                ),
              ],
            ),
    );
  }

  Widget _responderCard(
    String title,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: _Colors.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0x223A4547),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _Colors.tealLight,
              size: 38,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _Colors.bone,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    text,
                    style: const TextStyle(
                      color: _Colors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: _Colors.tealLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaq(bool isMobile) {
    return _section(
      background: _Colors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'SAID UP FRONT',
            'A few important things about what MONJED does — and does not — claim.',
          ),
          const SizedBox(height: 25),
          ...List.generate(
            faqs.length,
            (index) {
              final opened = openFaq == index;

              final answers = [
                'No. The MVP flood engine is rule-based. Its thresholds should be calibrated against historical data before being treated as a forecasting model.',
                'Because different hazards can be high or low independently. A country may have high flood risk while earthquake risk remains low.',
                'The MVP works at country level with representative rainfall points. A future grid-based implementation can provide finer spatial resolution.',
                'Not in this version. MONJED uses ground reports and opt-in volunteers rather than silently assuming a person’s individual situation.',
              ];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _Colors.night,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  initiallyExpanded: opened,
                  onExpansionChanged: (value) {
                    setState(() {
                      openFaq = value ? index : -1;
                    });
                  },
                  title: Text(
                    faqs[index],
                    style: const TextStyle(
                      color: _Colors.bone,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  iconColor: _Colors.tealLight,
                  collapsedIconColor: _Colors.muted,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        20,
                      ),
                      child: Text(
                        answers[index],
                        style: const TextStyle(
                          color: _Colors.muted,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 24 : 60,
        50,
        isMobile ? 24 : 60,
        30,
      ),
      color: const Color(0xFF071012),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MonjedLogo(large: true),
          const SizedBox(height: 18),
          const SizedBox(
            width: 600,
            child: Text(
              'MONJED is an AI-assisted disaster risk interpretation and action support platform.',
              style: TextStyle(
                color: _Colors.muted,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(
            color: Color(0x223A4547),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'SYSTEM STATUS · API ONLINE',
                  style: TextStyle(
                    color: _Colors.tealLight,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                'MONJED · ${DateTime.now().year}',
                style: const TextStyle(
                  color: _Colors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Free for communities · Staff console is private',
            style: TextStyle(
              color: Color(0x667A8789),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _Colors.tealLight,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          description,
          style: const TextStyle(
            color: _Colors.bone,
            fontSize: 29,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required Widget child,
    Color background = _Colors.night,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 65,
      ),
      color: background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: child,
        ),
      ),
    );
  }

  Widget _darkSection({
    required String title,
    required Widget child,
  }) {
    return _section(
      background: _Colors.night,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _Colors.tealLight,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }
}


// ============================================================
// AFRICA ANIMATED MAP
// ============================================================

class _AfricaMap extends StatelessWidget {
  final double progress;

  const _AfricaMap({
    required this.progress,
  });

  static const nodes = [
    _MapNode('MA', .25, .15, 'LOW'),
    _MapNode('DZ', .36, .21, 'LOW'),
    _MapNode('EG', .60, .15, 'MEDIUM'),
    _MapNode('SD', .60, .30, 'LOW'),
    _MapNode('ET', .72, .35, 'MEDIUM'),
    _MapNode('SO', .80, .33, 'HIGH'),
    _MapNode('NG', .30, .45, 'MEDIUM'),
    _MapNode('GH', .22, .49, 'LOW'),
    _MapNode('CD', .45, .58, 'LOW'),
    _MapNode('KE', .65, .49, 'HIGH'),
    _MapNode('TZ', .62, .59, 'LOW'),
    _MapNode('ZM', .50, .71, 'LOW'),
    _MapNode('MZ', .60, .76, 'HIGH'),
    _MapNode('ZA', .45, .90, 'LOW'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return CustomPaint(
          painter: _AfricaPainter(
            progress: progress,
            nodes: nodes,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AfricaPainter extends CustomPainter {
  final double progress;
  final List<_MapNode> nodes;

  _AfricaPainter({
    required this.progress,
    required this.nodes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    path.moveTo(w * .28, h * .06);
    path.lineTo(w * .43, h * .04);
    path.lineTo(w * .58, h * .10);
    path.lineTo(w * .72, h * .17);
    path.lineTo(w * .79, h * .29);
    path.lineTo(w * .73, h * .38);
    path.lineTo(w * .69, h * .50);
    path.lineTo(w * .62, h * .62);
    path.lineTo(w * .56, h * .74);
    path.lineTo(w * .47, h * .90);
    path.lineTo(w * .37, h * .84);
    path.lineTo(w * .31, h * .72);
    path.lineTo(w * .25, h * .58);
    path.lineTo(w * .20, h * .45);
    path.lineTo(w * .16, h * .33);
    path.lineTo(w * .19, h * .21);
    path.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF173538),
          Color(0xFF0D2427),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, w, h),
      );

    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0x558CA6A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);

    final gridPaint = Paint()
      ..color = const Color(0x183A777A)
      ..strokeWidth = .6;

    for (double x = 0; x < w; x += 30) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, h),
        gridPaint,
      );
    }

    for (double y = 0; y < h; y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        gridPaint,
      );
    }

    for (final node in nodes) {
      final x = node.x * w;
      final y = node.y * h;

      final color = _levelColor(node.level);

      final pulse =
          (math.sin((progress * math.pi * 2) + node.x * 8) + 1) / 2;

      final radius = 4 + pulse * 7;

      final glow = Paint()
        ..color = color.withOpacity( .10 + pulse * .15)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        );

      canvas.drawCircle(
        Offset(x, y),
        radius * 1.7,
        glow,
      );

      final point = Paint()..color = color;

      canvas.drawCircle(
        Offset(x, y),
        4,
        point,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.code,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          x + 7,
          y - 5,
        ),
      );
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'HIGH':
        return _Colors.rose;
      case 'MEDIUM':
        return _Colors.amber;
      default:
        return _Colors.teal;
    }
  }

  @override
  bool shouldRepaint(covariant _AfricaPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


// ============================================================
// REUSABLE UI
// ============================================================

class _MonjedLogo extends StatelessWidget {
  final bool large;

  const _MonjedLogo({
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: large ? 42 : 34,
          height: large ? 42 : 34,
          decoration: BoxDecoration(
            color: _Colors.teal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: large ? 25 : 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MONJED',
          style: TextStyle(
            color: _Colors.bone,
            fontSize: large ? 22 : 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _BotCard extends StatefulWidget {
  const _BotCard();

  @override
  State<_BotCard> createState() => _BotCardState();
}

class _BotCardState extends State<_BotCard> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x223A4547),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Colors.teal.withOpacity( .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: _Colors.tealLight,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MONJED BOT',
                  style: TextStyle(
                    color: _Colors.tealLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loading
                      ? 'Analyzing the signal...'
                      : 'Flood risk is HIGH because rainfall has increased for three consecutive days.',
                  style: const TextStyle(
                    color: _Colors.bone,
                    height: 1.6,
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

class _InfoCard extends StatelessWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _InfoCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x223A4547),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: _Colors.tealLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                color: _Colors.tealLight,
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: _Colors.bone,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: _Colors.muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Colors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x223A4547),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _Colors.tealLight,
            size: 30,
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: _Colors.bone,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: _Colors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// DATA CLASSES
// ============================================================

class _CountryRisk {
  final String code;
  final String name;
  final String flood;
  final String earthquake;
  final int floodScore;
  final int earthquakeScore;
  final List<String> reasons;

  const _CountryRisk({
    required this.code,
    required this.name,
    required this.flood,
    required this.earthquake,
    required this.floodScore,
    required this.earthquakeScore,
    required this.reasons,
  });
}

class _ReportType {
  final String title;
  final IconData icon;
  final String description;

  const _ReportType({
    required this.title,
    required this.icon,
    required this.description,
  });
}

class _AlertLanguage {
  final String code;
  final String label;
  final String text;

  const _AlertLanguage({
    required this.code,
    required this.label,
    required this.text,
  });
}

class _MapNode {
  final String code;
  final double x;
  final double y;
  final String level;

  const _MapNode(
    this.code,
    this.x,
    this.y,
    this.level,
  );
}


// ============================================================
// COLORS
// ============================================================

class _Colors {
  static const Color night = Color(0xFF081214);
  static const Color panel = Color(0xFF101D20);

  static const Color bone = Color(0xFFF1F0E8);
  static const Color lightMuted = Color(0xFFC1CCCB);
  static const Color muted = Color(0xFF829092);

  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF5EEAD4);

  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFE11D48);
}
class _CountryRisk {
  final String code;
  final String name;
  final String flood;
  final String earthquake;
  final int floodScore;
  final int earthquakeScore;
  final List<String> reasons;

  const _CountryRisk({
    required this.code,
    required this.name,
    required this.flood,
    required this.earthquake,
    required this.floodScore,
    required this.earthquakeScore,
    required this.reasons,
  });

  factory _CountryRisk.fromJson(Map<String, dynamic> json) {
    return _CountryRisk(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flood: json['flood'] ?? 'LOW',
      earthquake: json['earthquake'] ?? 'LOW',
      floodScore: json['flood_score'] ?? 0,
      earthquakeScore: json['earthquake_score'] ?? 0,
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}


