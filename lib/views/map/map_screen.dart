
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/risk_snapshot.dart';
import '../../services/risk_service.dart';
import '../../core/services/auth_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  LatLng? currentCenter;
  double currentZoom = 10;

  late Future<List<RiskSnapshot>> riskFuture;

  @override
  void initState() {
    super.initState();

    riskFuture = RiskService.getRiskSnapshots();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  void _checkAuthentication() {
    if (!AuthService.isLoggedIn) {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
  }

  // ============================================================
  // MAP CONTROLS
  // ============================================================

  void _goToFirstRiskLocation(List<Marker> markers) {
    if (markers.isEmpty) {
      return;
    }

    currentCenter = markers.first.point;
    currentZoom = 10;

    mapController.move(
      currentCenter!,
      currentZoom,
    );
  }

  void _zoomIn() {
    if (currentCenter == null) {
      return;
    }

    currentZoom += 1;

    if (currentZoom > 18) {
      currentZoom = 18;
    }

    mapController.move(
      currentCenter!,
      currentZoom,
    );
  }

  void _zoomOut() {
    if (currentCenter == null) {
      return;
    }

    currentZoom -= 1;

    if (currentZoom < 3) {
      currentZoom = 3;
    }

    mapController.move(
      currentCenter!,
      currentZoom,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return const Scaffold(
        backgroundColor: Color(0xFF081214),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081214),

      appBar: AppBar(
        title: const Text(
          'Risk Map & Live Engine',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF101D20),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Stack(
        children: [
          // ======================================================
          // MAP + API DATA
          // ======================================================

          FutureBuilder<List<RiskSnapshot>>(
            future: riskFuture,

            builder: (context, snapshot) {
              // --------------------------------------------------
              // LOADING
              // --------------------------------------------------

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              if (snapshot.hasError) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: const Color(0xFF101D20),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 42,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Failed to load risk data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              riskFuture =
                                  RiskService.getRiskSnapshots();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // --------------------------------------------------
              // DATA
              // --------------------------------------------------

              final risks = snapshot.data ?? [];

              // ==================================================
              // CREATE MARKERS FROM BACKEND COORDINATES
              // ==================================================

              final List<Marker> markers = risks
                  .where(
                    (risk) =>
                        risk.latitude != null &&
                        risk.longitude != null,
                  )
                  .map<Marker>(
                    (risk) {
                      return Marker(
                        point: LatLng(
                          risk.latitude!,
                          risk.longitude!,
                        ),

                        width: 55,
                        height: 55,

                        child: _buildRiskMarker(
                          level: risk.level,
                          score: risk.score,
                        ),
                      );
                    },
                  )
                  .toList();

              // ==================================================
              // NO LOCATION DATA
              // ==================================================

              if (markers.isEmpty) {
                return _buildNoLocationState();
              }

              // ==================================================
              // SET MAP CENTER FROM BACKEND
              // ==================================================

              final LatLng backendCenter =
                  markers.first.point;

              currentCenter ??= backendCenter;

              // ==================================================
              // MAP
              // ==================================================

              return FlutterMap(
                mapController: mapController,

                options: MapOptions(
                  initialCenter: backendCenter,
                  initialZoom: currentZoom,

                  minZoom: 3,
                  maxZoom: 18,

                  onPositionChanged: (
                    position,
                    hasGesture,
                  ) {
                    currentCenter = position.center;
                    currentZoom = position.zoom;
                  },
                ),

                children: [
                  // ------------------------------------------------
                  // OPEN STREET MAP
                  // ------------------------------------------------

                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName:
                        'com.monjed.monjed_flutter',
                  ),

                  // ------------------------------------------------
                  // RISK MARKERS
                  // ------------------------------------------------

                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              );
            },
          ),

          // ========================================================
          // LIVE RISK ENGINE PANEL
          // ========================================================

          Positioned(
            top: 16,
            left: 16,
            right: 16,

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF101D20)
                    .withOpacity(0.94),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,

                    decoration:
                        const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'LIVE RISK ENGINE',

                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          'Real-time hazard monitoring',

                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.radar,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // LEGEND
          // ========================================================

          Positioned(
            left: 16,
            bottom: 24,

            child: Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: const Color(0xFF101D20)
                    .withOpacity(0.94),

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'RISK LEVEL',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 10),

                  _LegendItem(
                    color: Colors.redAccent,
                    text: 'HIGH',
                  ),

                  SizedBox(height: 7),

                  _LegendItem(
                    color: Colors.orange,
                    text: 'MEDIUM',
                  ),

                  SizedBox(height: 7),

                  _LegendItem(
                    color: Colors.green,
                    text: 'LOW',
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // MAP CONTROLS
          // ========================================================

          Positioned(
            right: 16,
            bottom: 24,

            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),

                const SizedBox(height: 8),

                _MapButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),

                const SizedBox(height: 8),

                _MapButton(
                  icon: Icons.my_location,
                  onPressed: () async {
                    final risks =
                        await riskFuture;

                    final markers = risks
                        .where(
                          (risk) =>
                              risk.latitude != null &&
                              risk.longitude != null,
                        )
                        .map<Marker>(
                          (risk) {
                            return Marker(
                              point: LatLng(
                                risk.latitude!,
                                risk.longitude!,
                              ),
                              width: 55,
                              height: 55,
                              child:
                                  _buildRiskMarker(
                                level: risk.level,
                                score: risk.score,
                              ),
                            );
                          },
                        )
                        .toList();

                    _goToFirstRiskLocation(
                      markers,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO LOCATION STATE
  // ============================================================

  Widget _buildNoLocationState() {
    return Container(
      color: const Color(0xFF081214),

      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                Icons.location_off_outlined,
                color: Colors.orange,
                size: 52,
              ),

              SizedBox(height: 16),

              Text(
                'No risk locations available',
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'The backend did not provide coordinates for the current risk data.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RISK MARKER
  // ============================================================

  Widget _buildRiskMarker({
    required String level,
    required double score,
  }) {
    final Color color = _riskColor(level);

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),

      child: Center(
        child: Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,

          size: level.toUpperCase() == 'HIGH'
              ? 27
              : 23,
        ),
      ),
    );
  }

  // ============================================================
  // RISK COLOR
  // ============================================================

  Color _riskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;

      case 'HIGH':
        return Colors.redAccent;

      case 'MODERATE':
      case 'MEDIUM':
        return Colors.orange;

      case 'LOW':
        return Colors.green;

      default:
        return Colors.blueGrey;
    }
  }
}

// ================================================================
// MAP BUTTON
// ================================================================

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF101D20)
          .withOpacity(0.94),

      borderRadius:
          BorderRadius.circular(12),

      child: InkWell(
        onTap: onPressed,

        borderRadius:
            BorderRadius.circular(12),

        child: SizedBox(
          width: 46,
          height: 46,

          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LEGEND ITEM
// ================================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          text,

          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


