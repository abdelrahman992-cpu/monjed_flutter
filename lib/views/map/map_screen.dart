import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/auth_service.dart';
import '../../models/risk_snapshot.dart';
import '../../repositories/risk_repository.dart';
import '../../services/risk_service.dart';
import '../../services/api_service.dart';
import '../help/help_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final RiskRepository _riskRepository =
      RiskRepository(apiService: ApiService());

  final _zoneController = TextEditingController(text: 'EG');
  final _rain1Controller = TextEditingController(text: '12');
  final _rain24Controller = TextEditingController(text: '62');
  final _previousController = TextEditingController(text: '40');
  final _ageController = TextEditingController(text: '15');

  Future<List<RiskSnapshot>>? _riskFuture;
  String _hazard = 'Flood';
  bool _refreshing = false;
  bool _runningEngine = false;
  Map<String, dynamic>? _engineResult;
  String? _engineError;
  double _zoom = 5.2;
  LatLng _center = const LatLng(26.8, 30.8);

  @override
  void initState() {
    super.initState();
    _riskFuture = RiskService.getRiskSnapshots();
  }

  @override
  void dispose() {
    _zoneController.dispose();
    _rain1Controller.dispose();
    _rain24Controller.dispose();
    _previousController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _refreshRisk() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    setState(() => _riskFuture = RiskService.getRiskSnapshots());
    try {
      await _riskFuture;
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _runFloodEngine() async {
    if (_runningEngine) return;
    setState(() {
      _runningEngine = true;
      _engineError = null;
      _engineResult = null;
    });

    try {
      final result = await _riskRepository.calculateFloodRisk(
        zoneId: _zoneController.text.trim().isEmpty
            ? 'EG'
            : _zoneController.text.trim(),
        rainfall1hMm: double.parse(_rain1Controller.text.trim()),
        rainfall24hMm: double.parse(_rain24Controller.text.trim()),
        previousRainfall24hMm: double.tryParse(_previousController.text.trim()),
        dataAgeMinutes: int.tryParse(_ageController.text.trim()) ?? 0,
      );

      if (!mounted) return;
      setState(() {
        _engineResult = {
          'score': result.riskScore,
          'level': result.riskLevel,
          'reasons': result.reasons,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _engineError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _runningEngine = false);
    }
  }

  void _moveToEgypt() {
    _center = const LatLng(26.8, 30.8);
    _zoom = 5.2;
    _mapController.move(_center, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return const Scaffold(
        backgroundColor: _AppColors.page,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _AppColors.page,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            return Column(
              children: [
                _buildHeader(compact),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 16 : 30,
                      18,
                      compact ? 16 : 30,
                      30,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBreadcrumb(),
                          const SizedBox(height: 12),
                          const Text(
                            'Risk around Egypt',
                            style: TextStyle(
                              color: _AppColors.text,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Country colors come from the MONJED risk engine. Flood and earthquake stay separate.',
                            style: TextStyle(color: _AppColors.muted, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          _buildLocationChip(),
                          const SizedBox(height: 12),
                          _buildRiskToolbar(),
                          const SizedBox(height: 18),
                          if (compact)
                            Column(
                              children: [
                                _buildMapCard(),
                                const SizedBox(height: 16),
                                _buildSidePanel(),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 58, child: _buildMapCard()),
                                const SizedBox(width: 28),
                                Expanded(flex: 42, child: _buildSidePanel()),
                              ],
                            ),
                          const SizedBox(height: 16),
                          _buildExploreCard(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 30),
      child: Row(
        children: [
          const _Logo(),
          const Spacer(),
          if (!compact) ...[
            _navItem('Map', active: true),
            _navItem('Report'),
            _navItem('Request help'),
            const SizedBox(width: 34),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _AppColors.border),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFE9EFFA),
                  child: Text('A', style: TextStyle(fontSize: 11, color: _AppColors.blue, fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 8),
                Text('abdelrahman_d...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _AppColors.text)),
                SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down, size: 17, color: _AppColors.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String text, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {
          if (text == 'Request help') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
          }
        },
        child: Text(
          text,
          style: TextStyle(
            color: active ? _AppColors.text : _AppColors.muted,
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return const Row(
      children: [
        Icon(Icons.arrow_back, size: 15, color: _AppColors.muted),
        SizedBox(width: 7),
        Text('Back', style: TextStyle(color: _AppColors.muted, fontSize: 12)),
        SizedBox(width: 28),
        Text('YOUR AREA  ·  LIVE MAP  ·  POST /risk/flood  ·  /risk/earthquake',
            style: TextStyle(color: _AppColors.blue, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
      ],
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        border: Border.all(color: const Color(0xFFB7E0DA)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF359B8F)),
          SizedBox(width: 5),
          Text('SHOWING YOUR LOCATION FIRST', style: TextStyle(color: Color(0xFF359B8F), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildRiskToolbar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _pill('LIVE RISK  ·  4 high flood', filled: true),
        OutlinedButton.icon(
          onPressed: _refreshRisk,
          icon: _refreshing ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5)) : const Icon(Icons.refresh, size: 13),
          label: const Text('Refresh risk'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _AppColors.muted,
            side: const BorderSide(color: _AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            textStyle: const TextStyle(fontSize: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFF0F9F8) : Colors.white,
        border: Border.all(color: const Color(0xFFC9E4E0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF398F87), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7)),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: _AppColors.muted),
                const SizedBox(width: 6),
                const Text('FLOOD RISK  ·  MAP', style: TextStyle(color: _AppColors.muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                const Spacer(),
                _hazardButton('Flood', Icons.waves, _hazard == 'Flood'),
                const SizedBox(width: 6),
                _hazardButton('Quake', Icons.warning_amber_outlined, _hazard == 'Quake'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 405,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<List<RiskSnapshot>>(
                  future: _riskFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final risks = snapshot.data ?? [];
                    final markers = risks.where((r) => r.latitude != null && r.longitude != null && (_hazard == 'Flood' ? r.hazard.toLowerCase().contains('flood') : r.hazard.toLowerCase().contains('earth'))).map((risk) {
                      return Marker(
                        point: LatLng(risk.latitude!, risk.longitude!),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _riskColor(risk.level),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                        ),
                      );
                    }).toList();

                    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _center,
                            initialZoom: _zoom,
                            minZoom: 3,
                            maxZoom: 18,
                            onPositionChanged: (p, _) {
                              _center = p.center;
                              _zoom = p.zoom;
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.monjed.monjed_flutter',
                            ),
                            PolygonLayer(polygons: [
                              Polygon(
                                points: _egyptPolygon,
                                color: const Color(0xFF48B5A7).withOpacity(.52),
                                borderColor: const Color(0xFF34575B),
                                borderStrokeWidth: 2,
                              ),
                            ]),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Column(
                            children: [
                              _mapButton(Icons.add, () {
                                _zoom = (_zoom + 1).clamp(3, 18).toDouble();
                                _mapController.move(_center, _zoom);
                              }),
                              _mapButton(Icons.remove, () {
                                _zoom = (_zoom - 1).clamp(3, 18).toDouble();
                                _mapController.move(_center, _zoom);
                              }),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: _legend(),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: _mapButton(Icons.my_location, _moveToEgypt),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Back to Egypt', style: TextStyle(color: _AppColors.blue, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hazardButton(String text, IconData icon, bool selected) {
    return InkWell(
      onTap: () => setState(() => _hazard = text),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _AppColors.blue : Colors.white,
          border: Border.all(color: selected ? _AppColors.blue : _AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? Colors.white : _AppColors.muted),
            const SizedBox(width: 5),
            Text(text, style: TextStyle(color: selected ? Colors.white : _AppColors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.95), borderRadius: BorderRadius.circular(7), border: Border.all(color: _AppColors.border)),
      child: const Row(
        children: [
          _LegendDot(color: Color(0xFFD92D4F), label: 'High'),
          SizedBox(width: 14),
          _LegendDot(color: Color(0xFFE8A21A), label: 'Medium'),
          SizedBox(width: 14),
          _LegendDot(color: Color(0xFF279B8E), label: 'Low'),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 18, color: _AppColors.text)),
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        _buildCountryCard(),
        const SizedBox(height: 16),
        _buildEngineCard(),
      ],
    );
  }

  Widget _buildCountryCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EG  ·  SAT. 12 SEP 2026 20:22:50 GMT', style: TextStyle(color: _AppColors.blue, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          const SizedBox(height: 5),
          const Text('Egypt', style: TextStyle(color: _AppColors.text, fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          _scoreRow('FLOOD', '0/100', 'LOW', const Color(0xFF4EA99D), 'No significant rainfall-based flood-risk indicators detected'),
          const SizedBox(height: 16),
          _scoreRow('EARTHQUAKE', '30/100', 'MEDIUM', const Color(0xFFE8A21A), 'Light earthquake magnitude\nShallow earthquake depth'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: _AppColors.blue, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: const Text('Request help in Egypt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(String title, String score, String level, Color badgeColor, String reason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(color: _AppColors.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
            const Spacer(),
            Text(score, style: const TextStyle(color: _AppColors.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeColor.withOpacity(.12), borderRadius: BorderRadius.circular(4)), child: Text(level, style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.w800))),
          ],
        ),
        const SizedBox(height: 8),
        Text('— $reason', style: const TextStyle(color: _AppColors.muted, fontSize: 10, height: 1.45)),
      ],
    );
  }

  Widget _buildEngineCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.waves, size: 19, color: _AppColors.blue),
              SizedBox(width: 8),
              Text('Assess flood risk', style: TextStyle(color: _AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const Divider(height: 24, color: _AppColors.border),
          const Text('Rule-based flood engine only — never blended with earthquake. Send rainfall for a zone to assess risk level, score, confidence, and reasons.', style: TextStyle(color: _AppColors.muted, fontSize: 10, height: 1.5)),
          const SizedBox(height: 13),
          _field('Zone ID', _zoneController),
          _field('Rainfall last 1 hour (mm)', _rain1Controller),
          _field('Rainfall last 24 hours (mm)', _rain24Controller),
          _field('Previous 24h rainfall (mm, optional)', _previousController),
          _field('Data age (minutes)', _ageController),
          const SizedBox(height: 2),
          if (_engineResult != null) _resultBox(),
          if (_engineError != null) ...[
            const SizedBox(height: 8),
            Text(_engineError!, style: const TextStyle(color: Color(0xFFD92D4F), fontSize: 10)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: _runningEngine ? null : _runFloodEngine,
              style: ElevatedButton.styleFrom(backgroundColor: _AppColors.blue, disabledBackgroundColor: const Color(0xFF9EB3EA), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: _runningEngine ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Run flood engine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _AppColors.muted, fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 11, color: _AppColors.text),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _AppColors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultBox() {
    final result = _engineResult!;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF5F8FC), borderRadius: BorderRadius.circular(7), border: Border.all(color: _AppColors.border)),
      child: Text('Result: ${result['score']}/100 · ${result['level']}\n${(result['reasons'] as List? ?? const []).join('\n')}', style: const TextStyle(color: _AppColors.text, fontSize: 10, height: 1.45)),
    );
  }

  Widget _buildExploreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: const Row(
        children: [
          Text('EXPLORE OTHER AREAS', style: TextStyle(color: _AppColors.blue, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          SizedBox(width: 12),
          Text('Egypt selected · 12 zones', style: TextStyle(color: _AppColors.muted, fontSize: 12)),
          Spacer(),
          Icon(Icons.keyboard_arrow_down, size: 18, color: _AppColors.muted),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: _AppColors.border))),
      child: const Row(
        children: [
          Text('FLOOD AND EARTHQUAKE SCORES ARE NEVER BLENDED', style: TextStyle(color: _AppColors.muted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          Spacer(),
          Text('MONJED · EARLY WARNING', style: TextStyle(color: _AppColors.muted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return const Color(0xFFD92D4F);
      case 'MEDIUM':
      case 'MODERATE':
        return const Color(0xFFE8A21A);
      default:
        return const Color(0xFF279B8E);
    }
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: child,
      );
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => const Row(children: [
        SizedBox(width: 28, height: 28, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Color(0xFFDCE7F4), width: 2))), child: Center(child: Icon(Icons.radio_button_checked, size: 13, color: _AppColors.blue)))),
        SizedBox(width: 8),
        Text('MONJED', style: TextStyle(color: _AppColors.text, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -.4)),
      ]);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 5), Text(label, style: const TextStyle(color: _AppColors.muted, fontSize: 8))]);
}

class _AppColors {
  static const page = Color(0xFFF6F8FC);
  static const text = Color(0xFF202B3C);
  static const muted = Color(0xFF7A8799);
  static const border = Color(0xFFDCE3EC);
  static const blue = Color(0xFF2455D6);
}

const List<LatLng> _egyptPolygon = [
  LatLng(31.65, 25.0), LatLng(31.35, 27.2), LatLng(31.25, 29.0),
  LatLng(31.0, 30.0), LatLng(31.35, 31.8), LatLng(31.2, 32.9),
  LatLng(30.55, 33.5), LatLng(29.2, 33.9), LatLng(28.0, 34.1),
  LatLng(26.0, 34.9), LatLng(24.1, 35.0), LatLng(22.0, 36.0),
  LatLng(22.0, 25.0), LatLng(31.65, 25.0),
];
