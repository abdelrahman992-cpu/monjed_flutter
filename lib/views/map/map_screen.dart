import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/auth_service.dart';
import '../../models/country_risk.dart';
import '../../repositories/risk_repository.dart';
import '../../services/api_service.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final RiskRepository _riskRepository = RiskRepository(
    apiService: ApiService(),
  );

  Future<List<CountryRisk>>? _future;

  String _hazard = 'flood';
  String? _error;

  List<CountryRisk> _risks = [];

  static const LatLng _egyptCenter = LatLng(26.82, 30.80);

  static const List<LatLng> _egyptPolygon = [
    LatLng(31.65, 25.10),
    LatLng(31.65, 34.30),
    LatLng(29.55, 34.90),
    LatLng(27.95, 34.70),
    LatLng(22.00, 36.90),
    LatLng(22.00, 25.00),
    LatLng(31.65, 25.10),
  ];

  @override
  void initState() {
    super.initState();

    if (AuthService.isLoggedIn) {
      _loadRisks();
    }
  }

  void _loadRisks() {
    setState(() {
      _error = null;
      _future = _riskRepository.getDashboardRisks();
    });

    _future!.then((data) {
      if (!mounted) return;

      setState(() {
        _risks = data;
      });
    }).catchError((Object error) {
      if (!mounted) return;

      setState(() {
        _risks = [];
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    });
  }

  List<CountryRisk> get _selectedRisks {
    return _risks
        .where(
          (r) =>
              r.country.toUpperCase() == 'EG' ||
              r.country.toLowerCase() == 'egypt',
        )
        .where(
          (r) => r.hazard.toLowerCase() == _hazard,
        )
        .toList();
  }

  CountryRisk? get _selectedRisk {
    return _selectedRisks.isEmpty
        ? null
        : _selectedRisks.first;
  }

  CountryRisk? _riskFor(String hazard) {
    for (final risk in _risks) {
      final country = risk.country.toUpperCase();

      if ((country == 'EG' ||
              risk.country.toLowerCase() == 'egypt') &&
          risk.hazard.toLowerCase() == hazard) {
        return risk;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final flood = _riskFor('flood');
    final earthquake = _riskFor('earthquake');
    final active = _selectedRisk;

final activeScore = (active?.score ?? 0).toDouble();
    final activeLevel = active?.level ?? 'low';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadRisks();

                  try {
                    await _future;
                  } catch (_) {}
                },
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    18,
                    30,
                    28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 1180,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 16,
                            ),
                            label: const Text('Back'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFF718096),
                              padding: EdgeInsets.zero,
                            ),
                          ),

                          const SizedBox(height: 34),

                          const Text(
                            'YOUR AREA  ·  LIVE MAP  ·  POST /risk/flood  ·  /risk/earthquake',
                            style: TextStyle(
                              color: Color(0xFF5E7DCB),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.7,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Risk around Egypt',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Country colors come from the MONJED risk engine. Flood and earthquake stay separate.',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              _pill(
                                Icons.location_on_outlined,
                                'EGYPT SELECTED',
                              ),

                              const SizedBox(width: 8),

                              _pill(
                                Icons.circle,
                                _future == null
                                    ? 'LIVE RISK'
                                    : 'LIVE RISK  ·  ${_risks.length} records',
                              ),

                              const SizedBox(width: 8),

                              OutlinedButton.icon(
                                onPressed: _loadRisks,
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 14,
                                ),
                                label:
                                    const Text('Refresh risk'),
                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFF718096),
                                  side: const BorderSide(
                                    color: Color(0xFFDCE3EC),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                  textStyle:
                                      const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          LayoutBuilder(
                            builder:
                                (context, constraints) {
                              if (constraints.maxWidth < 850) {
                                return Column(
                                  children: [
                                    _mapCard(
                                      activeLevel,
                                      activeScore,
                                    ),
                                    const SizedBox(height: 20),
                                    _detailsCard(
                                      flood,
                                      earthquake,
                                    ),
                                    const SizedBox(height: 20),
                                    _floodEngineCard(),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _mapCard(
                                      activeLevel,
                                      activeScore,
                                    ),
                                  ),

                                  const SizedBox(width: 28),

                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        _detailsCard(
                                          flood,
                                          earthquake,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        _floodEngineCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          _exploreCard(),

                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Risk data unavailable right now: $_error',
                              style: const TextStyle(
                                color: Color(0xFFD94A6A),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const _MapFooter(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDCE3EC),
          ),
        ),
      ),
      child: Row(
        children: [
          const _Brand(),

          const SizedBox(width: 55),

          _topNav(
            context,
            'Map',
            AppRoutes.map,
            selected: true,
          ),

          _topNav(
            context,
            'Report',
            AppRoutes.report,
          ),

          _topNav(
            context,
            'Request help',
            AppRoutes.help,
          ),

          const Spacer(),

          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) async {
              if (value == 'home') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
              } else if (value == 'logout') {
                await ApiService().logout();
                await AuthService.logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'home',
                child: Text('Home'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Log out'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                border: Border.all(
                  color: const Color(0xFFDCE3EC),
                ),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        Color(0xFFEAF0FF),
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2455D6),
                      ),
                    ),
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF374151),
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: Color(0xFF718096),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topNav(
    BuildContext context,
    String label,
    String route, {
    bool selected = false,
  }) {
    return TextButton(
      onPressed: () {
        if (route == AppRoutes.map) return;

        Navigator.pushNamed(
          context,
          route,
        );
      },
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? const Color(0xFF111827)
              : const Color(0xFF718096),
          fontSize: 13,
          fontWeight: selected
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _mapCard(
    String level,
    double score,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE3EC),
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Color(0xFF718096),
              ),

              const SizedBox(width: 6),

              const Expanded(
                child: Text(
                  'FLOOD RISK  ·  MAP',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.8,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              _hazardButton(
                'Flood',
                'flood',
                Icons.waves,
              ),

              const SizedBox(width: 6),

              _hazardButton(
                'Quake',
                'earthquake',
                Icons.change_history_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 405,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(9),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _egyptCenter,
                      initialZoom: 5.2,
                      minZoom: 3,
                      maxZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: const [
                          'a',
                          'b',
                          'c',
                          'd',
                        ],
                        userAgentPackageName:
                            'com.monjed.monjed_flutter',
                      ),

                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _egyptPolygon,
                            color: _levelColor(
                              level,
                            ).withOpacity(0.68),
                            borderColor:
                                const Color(0xFF36505B),
                            borderStrokeWidth: 2.0,
                            isFilled: true,
                          ),
                        ],
                      ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _egyptCenter,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(0xFF2455D6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  score.toStringAsFixed(
                                    0,
                                  ),
                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Positioned(
                    left: 10,
                    top: 10,
                    child: Column(
                      children: [
                        _mapControl(
                          Icons.add,
                          () => _mapController.move(
                            _egyptCenter,
                            6,
                          ),
                        ),
                        _mapControl(
                          Icons.remove,
                          () => _mapController.move(
                            _egyptCenter,
                            4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_future == null)
                    const Positioned(
                      left: 10,
                      bottom: 10,
                      child: _MapBadge(
                        text: 'Loading live risk…',
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _legendDot(
                const Color(0xFFD94A6A),
                'High',
              ),

              const SizedBox(width: 14),

              _legendDot(
                const Color(0xFFF0A11A),
                'Medium',
              ),

              const SizedBox(width: 14),

              _legendDot(
                const Color(0xFF1E9B8A),
                'Low',
              ),

              const Spacer(),

              const Text(
                'Back to Egypt',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF5E7DCB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hazardButton(
    String text,
    String value,
    IconData icon,
  ) {
    final active = _hazard == value;

    return TextButton.icon(
      onPressed: () {
        setState(() {
          _hazard = value;
        });
      },
      icon: Icon(
        icon,
        size: 13,
      ),
      label: Text(text),
      style: TextButton.styleFrom(
        backgroundColor: active
            ? const Color(0xFF2455D6)
            : Colors.white,
        foregroundColor: active
            ? Colors.white
            : const Color(0xFF718096),
        side: BorderSide(
          color: active
              ? const Color(0xFF2455D6)
              : const Color(0xFFDCE3EC),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(7),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        textStyle: const TextStyle(
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _mapControl(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _detailsCard(
    CountryRisk? flood,
    CountryRisk? earthquake,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE3EC),
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'EG  ·  LIVE RISK',
            style: TextStyle(
              color: Color(0xFF5E7DCB),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Egypt',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 20),

          _riskRow(
            'FLOOD',
            flood,
          ),

          const Divider(height: 26),

          _riskRow(
            'EARTHQUAKE',
            earthquake,
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.help,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2455D6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Request help in Egypt',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskRow(
    String title,
    CountryRisk? risk,
  ) {
    final score = risk?.score ?? 0;
    final level = risk?.level ?? 'low';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$title  ·  $score/100',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                ),
              ),
            ),

            _levelBadge(level),
          ],
        ),

        const SizedBox(height: 7),

        if (risk == null)
          const Text(
            '— No current assessment returned by the risk engine.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
          )
        else if (risk.reasons.isEmpty)
          const Text(
            '— Assessment returned without additional reasons.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
          )
        else
          ...risk.reasons
              .take(2)
              .map(
                (r) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 3,
                  ),
                  child: Text(
                    '— $r',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _floodEngineCard() {
    return const _FloodEngineCard();
  }

  Widget _exploreCard() {
    final count = _risks
        .where(
          (r) =>
              r.country.toUpperCase() == 'EG' ||
              r.country.toLowerCase() == 'egypt',
        )
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE3EC),
        ),
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORE OTHER AREAS',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: Color(0xFF5E7DCB),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Egypt selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '$count risk records',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF718096),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F4),
        border: Border.all(
          color: const Color(0xFFB9E2DB),
        ),
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF1E9B8A),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF1E8175),
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _levelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _levelColor(level)
            .withOpacity(.13),
        borderRadius:
            BorderRadius.circular(5),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: _levelColor(level),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'critical':
        return const Color(0xFFD94A6A);

      case 'medium':
        return const Color(0xFFF0A11A);

      default:
        return const Color(0xFF1E9B8A);
    }
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
            border: Border.all(
              color: const Color(0xFFD8E2F4),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.radio_button_checked,
              size: 13,
              color: Color(0xFF2455D6),
            ),
          ),
        ),

        const SizedBox(width: 9),

        const Text(
          'MONJED',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _MapBadge extends StatelessWidget {
  final String text;

  const _MapBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius:
            BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF718096),
        ),
      ),
    );
  }
}

class _FloodEngineCard extends StatefulWidget {
  const _FloodEngineCard();

  @override
  State<_FloodEngineCard> createState() =>
      _FloodEngineCardState();
}

class _FloodEngineCardState
    extends State<_FloodEngineCard> {
  final _zone =
      TextEditingController(text: 'EG');

  final _r1 =
      TextEditingController(text: '12');

  final _r24 =
      TextEditingController(text: '62');

  final _prev =
      TextEditingController(text: '40');

  final _age =
      TextEditingController(text: '15');

  bool _busy = false;
  String? _result;

  @override
  void dispose() {
    _zone.dispose();
    _r1.dispose();
    _r24.dispose();
    _prev.dispose();
    _age.dispose();

    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
    });

    try {
      final repo = RiskRepository(
        apiService: ApiService(),
      );

      final result =
          await repo.calculateFloodRisk(
        zoneId: _zone.text.trim(),
        rainfall1hMm:
            double.parse(_r1.text.trim()),
        rainfall24hMm:
            double.parse(_r24.text.trim()),
        previousRainfall24hMm:
            double.tryParse(
          _prev.text.trim(),
        ),
        dataAgeMinutes:
            int.tryParse(
                  _age.text.trim(),
                ) ??
                0,
      );

     if (mounted) {
  setState(() {
    _result =
        '${result.riskLevel.toUpperCase()}  ·  ${result.riskScore}/100';
  });
}
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = e
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );
        });
      }
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE3EC),
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.waves,
                size: 18,
                color: Color(0xFF2455D6),
              ),

              SizedBox(width: 7),

              Text(
                'Assess flood risk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          const Text(
            'Rule-based flood engine only — never blended with earthquake. '
            'Send rainfall for a zone to assess risk level, '
            'score, confidence, and reasons.',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 17),

          _field(
            'Zone ID',
            _zone,
          ),

          _field(
            'Rainfall last 1 hour (mm)',
            _r1,
          ),

          _field(
            'Rainfall last 24 hours (mm)',
            _r24,
          ),

          _field(
            'Previous 24h rainfall (mm, optional)',
            _prev,
          ),

          _field(
            'Data age (minutes)',
            _age,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _busy ? null : _run,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2455D6),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Run flood engine',
                    ),
            ),
          ),

          if (_result != null) ...[
            const SizedBox(height: 10),

            Text(
              _result!,
              style: const TextStyle(
                color: Color(0xFF2455D6),
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF718096),
              fontWeight:
                  FontWeight.w700,
              letterSpacing: .8,
            ),
          ),

          const SizedBox(height: 5),

          TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 12,
            ),
            decoration:
                const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 11,
              ),
              border:
                  OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFDCE3EC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFooter extends StatelessWidget {
  const _MapFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 70,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFDCE3EC),
          ),
        ),
        color: Color(0xFFF8FAFD),
      ),
      child: const Row(
        children: [
          Text(
            'FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF8A98A8),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),

          Spacer(),

          Text(
            'MONJED  ·  EARLY WARNING',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF8A98A8),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
