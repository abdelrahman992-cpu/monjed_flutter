import 'package:flutter/material.dart';

import '../../controllers/assistance_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/reports_controller.dart';
import '../../controllers/users_controller.dart';
import '../../controllers/volunteers_controller.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _dashboard = DashboardController();
  final _reports = ReportsController();
  final _assistance = AssistanceController();
  final _users = UsersController();
  final _volunteers = VolunteersController();

  bool _loading = true;
  bool _apiLive = false;
  String? _error;

  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _reportsList = [];
  List<Map<String, dynamic>> _usersList = [];
  List<Map<String, dynamic>> _volunteersList = [];
  List<Map<String, dynamic>> _risks = [];
  List<Map<String, dynamic>> _alerts = [];

  dynamic _unwrap(dynamic value) {
    if (value is Map) {
      final data = value['data'];

      if (data is Map || data is List) {
        return data;
      }
    }

    return value;
  }

  List<Map<String, dynamic>> _list(dynamic value, [String? key]) {
    dynamic data = _unwrap(value);

    if (key != null && data is Map) {
      data = data[key] ??
          data['items'] ??
          data['results'] ??
          data['data'] ??
          [];
    }

    if (data is Map) {
      data = data['items'] ??
          data['results'] ??
          data.values.firstWhere(
            (v) => v is List,
            orElse: () => [],
          );
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  int _count(
    Map<String, dynamic> source,
    List<String> keys,
    int fallback,
  ) {
    for (final key in keys) {
      if (source[key] != null) {
        return _asInt(source[key]);
      }
    }

    return fallback;
  }

  Future<dynamic> _safe(Future<dynamic> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _safe(_dashboard.getOverview()),
        _safe(_dashboard.getRisks()),
        _safe(_dashboard.getAlerts()),
        _safe(_reports.getReports()),
        _safe(_assistance.getRequests()),
        _safe(_users.getUsers()),
        _safe(_volunteers.getVolunteers()),
      ]);

      final overviewRaw = _unwrap(results[0]);

      final overview = overviewRaw is Map
          ? Map<String, dynamic>.from(overviewRaw)
          : <String, dynamic>{};

      final requests = _list(results[4], 'requests');
      final reports = _list(results[3], 'reports');
      final users = _list(results[5], 'users');
      final volunteers = _list(results[6], 'volunteers');
      final risks = _list(results[1], 'risks');
      final alerts = _list(results[2], 'alerts');

      final anySuccess = results.any((r) => r != null);

      if (!mounted) return;

      setState(() {
        _overview = overview;
        _requests = requests;
        _reportsList = reports;
        _usersList = users;
        _volunteersList = volunteers;
        _risks = risks;
        _alerts = alerts;
        _apiLive = anySuccess;

        if (!anySuccess) {
          _error =
              'Could not reach the FastAPI server at 127.0.0.1:8000.';
        } else {
          _error = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _apiLive = false;
        _error = 'Dashboard error: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  String _requestTitle(Map<String, dynamic> x) {
    return '${x['location'] ??
        x['request_type'] ??
        x['type'] ??
        x['description'] ??
        'Assistance request'}';
  }

  String _requestMeta(Map<String, dynamic> x) {
    final zone = x['zone_id'] ?? x['zone'] ?? '—';
    final status = x['status'] ?? 'pending';

    return 'Zone: $zone  •  ${'$status'.toUpperCase()}';
  }

  String _reportTitle(Map<String, dynamic> x) {
    return '${x['report_text'] ??
        x['description'] ??
        x['type'] ??
        x['report_id'] ??
        'Community report'}';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07101F),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sidebar(context),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _content(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1527),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1B2A42),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2365FF),
              ),
              color: const Color(0xFF102653),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF32C7FF),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MONJED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _statusPill(),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(
              Icons.refresh,
              size: 16,
            ),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9DB1CC),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'home') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                );
              }

              if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin-login',
                  (_) => false,
                );
              }
            },
            color: const Color(0xFF101C31),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'home',
                child: Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF253652),
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFF16346B),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        color: Color(0xFF54CFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MONJED Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF7E91AC),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill() {
    final live = _apiLive;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: live
              ? const Color(0xFF008F83)
              : const Color(0xFF8B4A52),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 14,
            color: live
                ? const Color(0xFF19D8C1)
                : const Color(0xFFFF6F7F),
          ),
          const SizedBox(width: 6),
          Text(
            live ? 'API LIVE' : 'API OFFLINE',
            style: TextStyle(
              color: live
                  ? const Color(0xFF19D8C1)
                  : const Color(0xFFFF6F7F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'label': 'Overview',
        'icon': Icons.grid_view_rounded,
        'active': true,
      },
      {
        'label': 'Users',
        'icon': Icons.people_outline,
        'route': '/admin',
      },
      {
        'label': 'Volunteers',
        'icon': Icons.volunteer_activism_outlined,
        'route': '/volunteer-dashboard',
      },
      {
        'label': 'Reports',
        'icon': Icons.description_outlined,
        'route': '/report',
      },
      {
        'label': 'Risk Monitoring',
        'icon': Icons.monitor_heart_outlined,
        'route': '/map',
      },
      {
        'label': 'Assistance Requests',
        'icon': Icons.support_agent_outlined,
        'route': '/help',
      },
      {
        'label': 'System Settings',
        'icon': Icons.settings_outlined,
      },
      {
        'label': 'Logs',
        'icon': Icons.access_time,
        'route': '/admin',
      },
    ];

    return Container(
      width: 248,
      color: const Color(0xFF091323),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          12,
          20,
          12,
          20,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              0,
              12,
              12,
            ),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: Color(0xFF63748E),
                fontSize: 10,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...items.map(
            (item) => _sideItem(context, item),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final active = item['active'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: item['route'] == null
            ? null
            : () => Navigator.pushNamed(
                  context,
                  item['route'] as String,
                ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF112B57)
                : Colors.transparent,
            border: active
                ? Border.all(
                    color: const Color(0xFF235CC1),
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                color: active
                    ? const Color(0xFF2DC9FF)
                    : const Color(0xFF9BAAC0),
                size: 20,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : const Color(0xFFA7B5C9),
                    fontWeight: active
                        ? FontWeight.w800
                        : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (item['label'] == 'Users' &&
                  _usersList.isNotEmpty)
                _countBubble(_usersList.length)
              else if (item['label'] == 'Volunteers' &&
                  _volunteersList.isNotEmpty)
                _countBubble(_volunteersList.length)
              else if (item['label'] == 'Reports' &&
                  _reportsList.isNotEmpty)
                _countBubble(_reportsList.length)
              else if (item['label'] == 'Assistance Requests' &&
                  _requests.isNotEmpty)
                _countBubble(_requests.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countBubble(int n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF153A73),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$n',
        style: const TextStyle(
          color: Color(0xFF72BFFF),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1050;

        final usersCount = _count(
          _overview,
          [
            'users_count',
            'total_users',
            'users',
          ],
          _usersList.length,
        );

        final volunteersCount = _count(
          _overview,
          [
            'volunteers_count',
            'total_volunteers',
            'volunteers',
          ],
          _volunteersList.length,
        );

        final requestsCount = _count(
          _overview,
          [
            'assistance_requests',
            'help_requests',
            'requests_count',
            'requests',
          ],
          _requests.length,
        );

        final reportsCount = _count(
          _overview,
          [
            'reports_count',
            'total_reports',
            'reports',
            'community_reports',
          ],
          _reportsList.length,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            34,
            25,
            34,
            38,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.arrow_back,
                    size: 17,
                    color: Color(0xFF71839E),
                  ),
                  const SizedBox(width: 7),
                  TextButton(
                    onPressed: () =>
                        Navigator.maybePop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Monitor the platform, manage users, and oversee disaster response operations.',
                style: TextStyle(
                  color: Color(0xFF8EA0B9),
                  fontSize: 14,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 15),
                _errorBanner(_error!),
              ],
              const SizedBox(height: 22),
              _statsGrid(
                c.maxWidth,
                usersCount,
                volunteersCount,
                requestsCount,
                reportsCount,
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _riskPanel(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: _activityPanel(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _healthPanel(),
                          const SizedBox(height: 14),
                          _quickActions(context),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _riskPanel(),
                const SizedBox(height: 14),
                _activityPanel(),
                const SizedBox(height: 14),
                _healthPanel(),
                const SizedBox(height: 14),
                _quickActions(context),
              ],
              const SizedBox(height: 20),
              _requestsPanel(),
            ],
          ),
        );
      },
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF351A25),
        border: Border.all(
          color: const Color(0xFF6A293C),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFFF9AAA),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statsGrid(
    double width,
    int users,
    int volunteers,
    int requests,
    int reports,
  ) {
    final count = width >= 1050
        ? 4
        : width >= 650
            ? 2
            : 1;

    return GridView.count(
      crossAxisCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: width >= 650 ? 2.35 : 3.1,
      children: [
        _stat(
          'TOTAL USERS',
          users,
          Icons.people_outline,
          const Color(0xFF20C7FF),
          'Citizens, volunteers and staff',
        ),
        _stat(
          'ACTIVE VOLUNTEERS',
          _activeVolunteers(volunteers),
          Icons.shield_outlined,
          const Color(0xFF18D6B4),
          'Available for assignments',
        ),
        _stat(
          'ACTIVE REQUESTS',
          _activeRequests(requests),
          Icons.warning_amber_rounded,
          const Color(0xFFFFB52B),
          'Pending response',
        ),
        _stat(
          'TOTAL REPORTS',
          reports,
          Icons.description_outlined,
          const Color(0xFFC17AFF),
          'Community ground reports',
        ),
      ],
    );
  }

  int _activeVolunteers(int fallback) {
    if (_volunteersList.isEmpty) {
      return fallback;
    }

    return _volunteersList
        .where(
          (v) =>
              v['available'] == true ||
              v['is_available'] == true ||
              v['status'] == 'available',
        )
        .length;
  }

  int _activeRequests(int fallback) {
    if (_requests.isEmpty) {
      return fallback;
    }

    return _requests.where((r) {
      final s = '${r['status'] ?? 'pending'}'
          .toLowerCase();

      return s != 'resolved' &&
          s != 'completed' &&
          s != 'cancelled';
    }).length;
  }

  Widget _stat(
    String label,
    int value,
    IconData icon,
    Color accent,
    String caption,
  ) {
    return _darkCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accent,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8295B0),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskPanel() {
    return _darkCard(
      title: 'Risk Overview',
      icon: Icons.show_chart,
      trailing: TextButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/map'),
        child: const Text('View all →'),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (_risks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Text(
                'No risk records returned by /dashboard/risks.',
                style: TextStyle(
                  color: Color(0xFF8193AC),
                  fontSize: 12,
                ),
              ),
            )
          else
            ..._risks.take(6).map((r) {
              final name =
                  '${r['country'] ?? r['zone'] ?? r['name'] ?? r['country_name'] ?? 'Risk area'}';

              final score =
                  '${r['score'] ?? r['risk_score'] ?? r['riskLevel'] ?? r['risk_level'] ?? '—'}';

              final level =
                  '${r['level'] ?? r['risk_level'] ?? r['riskLevel'] ?? 'UNKNOWN'}';

              return _rowItem(
                Icons.location_on_outlined,
                name,
                'Risk score: $score',
                level,
              );
            }),
        ],
      ),
    );
  }

  Widget _activityPanel() {
    final items = <Map<String, dynamic>>[];

    for (final a in _alerts.take(4)) {
      items.add({
        ...a,
        '_kind': 'alert',
      });
    }

    for (final r in _reportsList.take(3)) {
      items.add({
        ...r,
        '_kind': 'report',
      });
    }

    for (final r in _requests.take(3)) {
      items.add({
        ...r,
        '_kind': 'request',
      });
    }

    return _darkCard(
      title: 'Recent Activity',
      icon: Icons.monitor_heart_outlined,
      trailing: TextButton(
        onPressed: _load,
        child: const Text('Refresh →'),
      ),
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Text(
                'No recent activity returned by the API.',
                style: TextStyle(
                  color: Color(0xFF8193AC),
                  fontSize: 12,
                ),
              ),
            )
          : Column(
              children: items.take(7).map((x) {
                final kind = x['_kind'];

                final title = kind == 'request'
                    ? _requestTitle(x)
                    : kind == 'report'
                        ? _reportTitle(x)
                        : '${x['title'] ?? x['message'] ?? x['type'] ?? 'System alert'}';

                final sub =
                    '${x['status'] ?? x['zone_id'] ?? x['zone'] ?? ''}';

                return _rowItem(
                  kind == 'alert'
                      ? Icons.warning_amber_rounded
                      : kind == 'report'
                          ? Icons.description_outlined
                          : Icons.support_agent_outlined,
                  title,
                  sub,
                  '${x['status'] ?? ''}',
                );
              }).toList(),
            ),
    );
  }

  Widget _healthPanel() {
    return _darkCard(
      title: 'System Health',
      icon: Icons.settings_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF008F83),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          '●  Operational',
          style: TextStyle(
            color: Color(0xFF19D8C1),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      child: Column(
        children: [
          _healthRow('API Service', _apiLive),
          _healthRow(
            'Assistance API',
            _requests.isNotEmpty || _apiLive,
          ),
          _healthRow(
            'Reports API',
            _reportsList.isNotEmpty || _apiLive,
          ),
          _healthRow(
            'Users API',
            _usersList.isNotEmpty || _apiLive,
          ),
          _healthRow(
            'Volunteers API',
            _volunteersList.isNotEmpty || _apiLive,
          ),
        ],
      ),
    );
  }

  Widget _healthRow(
    String label,
    bool online,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: online
                ? const Color(0xFF16D9B5)
                : const Color(0xFFFF6475),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB4C1D2),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            online ? 'Online' : 'Unavailable',
            style: TextStyle(
              color: online
                  ? const Color(0xFF16D9B5)
                  : const Color(0xFFFF6475),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return _darkCard(
      title: 'Quick Actions',
      icon: Icons.bolt,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _action(
            context,
            'Manage Users',
            Icons.people_outline,
            '/admin',
          ),
          _action(
            context,
            'View Reports',
            Icons.description_outlined,
            '/report',
          ),
          _action(
            context,
            'Assistance',
            Icons.support_agent_outlined,
            '/help',
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return OutlinedButton.icon(
      onPressed: () =>
          Navigator.pushNamed(context, route),
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF67BFFF),
        side: const BorderSide(
          color: Color(0xFF1B4C84),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _requestsPanel() {
    return _darkCard(
      title: 'Assistance Requests',
      icon: Icons.support_agent_outlined,
      trailing: Text(
        '${_requests.length} records',
        style: const TextStyle(
          color: Color(0xFF7287A3),
          fontSize: 11,
        ),
      ),
      child: _requests.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 22,
              ),
              child: Text(
                'No assistance requests returned by /assistance/requests.',
                style: TextStyle(
                  color: Color(0xFF8193AC),
                  fontSize: 12,
                ),
              ),
            )
          : Column(
              children: _requests.take(8).map((r) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1425),
                    border: Border.all(
                      color: const Color(0xFF172841),
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF132B4D),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.support_agent_outlined,
                          color: Color(0xFF36C7FF),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _requestTitle(r),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _requestMeta(r),
                              style: const TextStyle(
                                color: Color(0xFF7186A1),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _status(
                        '${r['status'] ?? 'pending'}',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _rowItem(
    IconData icon,
    String title,
    String subtitle,
    String badge,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              color: Color(0xFF112A4A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Color(0xFF38C8FF),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE7EEF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF70849F),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          if (badge.trim().isNotEmpty)
            _status(badge),
        ],
      ),
    );
  }

  Widget _status(String text) {
    final lower = text.toLowerCase();

    final good = lower.contains('resolved') ||
        lower.contains('completed') ||
        lower.contains('assigned') ||
        lower.contains('available');

    final bad = lower.contains('critical') ||
        lower.contains('high') ||
        lower.contains('failed');

    final color = bad
        ? const Color(0xFFFF5D70)
        : good
            ? const Color(0xFF19D8C1)
            : const Color(0xFFFFB52B);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        border: Border.all(
          color: color.withOpacity(.35),
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _darkCard({
    String? title,
    IconData? icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172A),
        border: Border.all(
          color: const Color(0xFF1B2B43),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: const Color(0xFF31C7FF),
                    size: 18,
                  ),
                if (icon != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFE7EEF8),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 1,
              color: Color(0xFF182A42),
            ),
            const SizedBox(height: 5),
          ],
          child,
        ],
      ),
    );
  }
}