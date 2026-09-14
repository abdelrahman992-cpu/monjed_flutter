import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/monjed_ui.dart';
import '../../routes/app_routes.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final ApiService _api = ApiService();

  int _section = 0;
  bool _loading = true;
  bool _refreshing = false;
  bool _available = true;
  String? _error;
  String _name = 'Volunteer';
  String _zone = '—';
  String _country = 'Egypt';
  String? _userId;
  String? _volunteerId;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _status(Map<String, dynamic> x) =>
      '${x['status'] ?? 'pending'}'.trim().toLowerCase();

  String _id(Map<String, dynamic> x) =>
      '${x['request_id'] ?? x['id'] ?? x['_id'] ?? ''}';

  String _text(Map<String, dynamic> x, List<String> keys, [String fallback = '—']) {
    for (final key in keys) {
      final value = x[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  List<Map<String, dynamic>> _list(dynamic value) {
    dynamic data = value;
    if (value is Map) {
      data = value['requests'] ?? value['items'] ?? value['data'] ?? [];
      if (data is Map) {
        data = data['requests'] ?? data['items'] ?? data['data'] ?? [];
      }
    }
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  int get _activeCount => _requests.where((x) {
        final s = _status(x);
        return ['matched', 'assigned', 'accepted', 'in_progress', 'started']
            .contains(s);
      }).length;

  int get _doneCount => _requests.where((x) {
        return ['resolved', 'completed', 'closed'].contains(_status(x));
      }).length;

  List<Map<String, dynamic>> get _activeRequests =>
      _requests.where((x) => !_isDone(_status(x))).toList();

  List<Map<String, dynamic>> get _doneRequests =>
      _requests.where((x) => _isDone(_status(x))).toList();

  bool _isDone(String status) =>
      ['resolved', 'completed', 'closed'].contains(status);

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      _name = await _api.getDisplayName() ?? 'Volunteer';
      _zone = await _api.getZoneId() ?? '—';
      _country = await _api.getCountry() ?? 'Egypt';
      _userId = await _api.getUserId();

      // The API is authoritative for assignments. Some backend versions return
      // "Volunteer or responder not found" when a volunteer profile has not
      // been linked yet; keep the dashboard usable and show that message.
      final response = await _api.get('/assistance/requests');
      final requests = _list(response);

      String? volunteerId;
      try {
        final volunteersResponse = await _api.get('/assistance/volunteers');
        final volunteers = _list(volunteersResponse);
        for (final v in volunteers) {
          final candidate =
              '${v['user_id'] ?? v['userId'] ?? v['account_id'] ?? ''}';
          if (_userId != null && candidate == _userId) {
            volunteerId = '${v['volunteer_id'] ?? v['id'] ?? v['_id'] ?? ''}';
            _available = v['available'] is bool ? v['available'] as bool : _available;
            break;
          }
        }
      } catch (_) {
        // Assignment data should not disappear just because the volunteer
        // directory endpoint is unavailable.
      }

      if (!mounted) return;
      setState(() {
        _requests = requests;
        _volunteerId = volunteerId;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _cleanError(e);
        _requests = [];
        _loading = false;
        _refreshing = false;
      });
    }
  }

  String _cleanError(Object e) {
    var text = e.toString().replaceFirst('Exception: ', '');
    if (text.contains('404') && text.toLowerCase().contains('volunteer')) {
      return 'Volunteer or responder not found.';
    }
    return text;
  }

  Future<void> _setAvailability(bool value) async {
    final old = _available;
    setState(() => _available = value);

    if (_volunteerId == null || _volunteerId!.isEmpty) {
      _showMessage(
        'Your volunteer profile is not linked to this account yet.',
        error: true,
      );
      setState(() => _available = old);
      return;
    }

    try {
      await _api.patch(
        '/assistance/volunteers/$_volunteerId',
        body: {'available': value},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _available = old);
      _showMessage(_cleanError(e), error: true);
    }
  }

  Future<void> _action(Map<String, dynamic> request, String action) async {
    final id = _id(request);
    if (id.isEmpty) {
      _showMessage('Request ID is missing.', error: true);
      return;
    }

    try {
      await _api.post('/assistance/requests/$id/$action');
      if (!mounted) return;
      _showMessage(
        action == 'resolve' ? 'Request resolved.' : 'Request started.',
      );
      await _load(refresh: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanError(e), error: true);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? MonjedColors.red : MonjedColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonjedColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 760) {
                    return _mobileLayout();
                  }
                  return Row(
                    children: [
                      _sidebar(),
                      Expanded(child: _content()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MonjedColors.line)),
      ),
      child: Row(
        children: [
          const _Brand(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FA),
              border: Border.all(color: const Color(0xFFF1B8C6)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.monitor_heart_outlined,
                    size: 12, color: MonjedColors.red),
                SizedBox(width: 5),
                Text(
                  'API OFFLINE',
                  style: TextStyle(
                    color: MonjedColors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, AppRoutes.updateProfile);
              } else if (value == 'home') {
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
              } else if (value == 'logout') {
                await _api.logout();
                await AuthService.logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Update profile')),
              PopupMenuItem(value: 'home', child: Text('Home')),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                border: Border.all(color: MonjedColors.line),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: MonjedColors.blueSoft,
                    child: Text(
                      _name.isEmpty ? 'V' : _name[0].toUpperCase(),
                      style: const TextStyle(
                        color: MonjedColors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      _name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MonjedColors.ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 15, color: MonjedColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFD),
        border: Border(right: BorderSide(color: MonjedColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 17, 15, 10),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.7,
                fontWeight: FontWeight.w800,
                color: Color(0xFF95A1B2),
              ),
            ),
          ),
          _sideItem(0, Icons.grid_view_outlined, 'Overview'),
          _sideItem(1, Icons.inbox_outlined, 'My inbox', badge: _activeCount),
          _sideItem(2, Icons.tune, 'Availability'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Flood and earthquake scores are\nnever blended.',
              style: TextStyle(
                color: Color(0xFFB2BDCA),
                fontSize: 9,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(int index, IconData icon, String label, {int? badge}) {
    final selected = _section == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _section = index),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFDDE6FA) : Colors.transparent,
            border: selected
                ? Border.all(color: const Color(0xFFB6C8F1))
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 17,
                  color: selected ? MonjedColors.blue : MonjedColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: MonjedColors.ink,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFB9C8EF)
                        : const Color(0xFFE9EEF6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: MonjedColors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: const Color(0xFFF8FAFD),
          child: Row(
            children: [
              _mobileTab(0, 'Overview'),
              _mobileTab(1, 'My inbox'),
              _mobileTab(2, 'Availability'),
            ],
          ),
        ),
        Expanded(child: _content()),
      ],
    );
  }

  Widget _mobileTab(int index, String label) {
    final selected = _section == index;
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _section = index),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MonjedColors.blue : MonjedColors.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 925),
          child: _section == 0
              ? _overview()
              : _section == 1
                  ? _inbox()
                  : _availability(),
        ),
      ),
    );
  }

  Widget _pageHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 15),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: MonjedColors.muted,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: MonjedColors.ink,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: MonjedColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _errorBanner() {
    if (_error == null || _error!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E1E8),
        border: Border.all(color: const Color(0xFFF2B9C7)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _error!,
        style: const TextStyle(color: MonjedColors.red, fontSize: 12),
      ),
    );
  }

  Widget _overview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeading(
          'Overview',
          '$_name · $_zone, $_country · Assignments from the assistance API',
        ),
        _errorBanner(),
        Row(
          children: [
            Expanded(child: _metric('ACTIVE', '$_activeCount', 'Assigned — contact & respond')),
            const SizedBox(width: 10),
            Expanded(child: _metric('COMPLETED', '$_doneCount', 'Resolved on the API', green: true)),
            const SizedBox(width: 10),
            Expanded(child: _metric('AVAILABILITY', _available ? 'ON' : 'OFF', 'Ops use this when assigning')),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 700) {
              return Column(
                children: [
                  _activityCard(),
                  const SizedBox(height: 18),
                  _needMixCard(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _activityCard()),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: _needMixCard()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _metric(String label, String value, String note, {bool green = false}) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MonjedColors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8A98AA), fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: MonjedColors.ink)),
              const Spacer(),
              Container(
                width: 31,
                height: 4,
                decoration: BoxDecoration(
                  color: green ? const Color(0xFFBFE8E2) : const Color(0xFFC4D2F3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(note,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFA1ADBB), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _activityCard() {
    final counts = List<int>.filled(7, 0);
    final today = DateTime.now();
    for (final r in _requests) {
      final raw = r['created_at'] ?? r['createdAt'];
      final date = DateTime.tryParse('$raw')?.toLocal();
      if (date == null) continue;
      final diff = DateTime(today.year, today.month, today.day)
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    final maxValue = math.max(1, counts.reduce(math.max));

    return _card(
      title: '7-DAY ASSIGNMENT ACTIVITY',
      subtitle: 'How many of your assignments were created each day.',
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final value = counts[i];
            final day = today.subtract(Duration(days: 6 - i));
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$value',
                        style: const TextStyle(
                            fontSize: 9, color: MonjedColors.muted)),
                    const SizedBox(height: 6),
                    Container(
                      height: 8 + (value / maxValue) * 72,
                      decoration: BoxDecoration(
                        color: MonjedColors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(_dayLabel(day.weekday),
                        style: const TextStyle(
                            fontSize: 8, color: MonjedColors.muted)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _dayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }

  Widget _needMixCard() {
    final Map<String, int> mix = {};
    for (final r in _requests) {
      final type = _text(r, ['request_type', 'type'], 'No assignment');
      mix[type] = (mix[type] ?? 0) + 1;
    }
    final total = _requests.length;

    return _card(
      title: 'NEED MIX',
      subtitle: 'Breakdown of request types across your history.',
      trailing: TextButton(
        onPressed: () => setState(() => _section = 1),
        child: const Text('Open inbox →', style: TextStyle(fontSize: 12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: CustomPaint(
              painter: _DonutPainter(
                total: total,
                parts: mix.values.toList(),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total',
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w800)),
                    const Text('TOTAL',
                        style: TextStyle(
                            fontSize: 8, color: MonjedColors.muted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: mix.isEmpty
                ? const Text('No assignments yet.',
                    style: TextStyle(color: MonjedColors.muted, fontSize: 11))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mix.entries
                        .take(4)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${e.key}   ${e.value}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: MonjedColors.muted, fontSize: 10),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MonjedColors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Color(0xFF6B88D4),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1)),
                    const SizedBox(height: 7),
                    Text(subtitle,
                        style: const TextStyle(
                            color: MonjedColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _inbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeading(
          'My inbox',
          '$_name · $_zone, $_country · Assignments from the assistance API',
        ),
        _errorBanner(),
        const Text(
          'You only see requests assigned to you on the MONJED assistance API.',
          style: TextStyle(color: MonjedColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _inboxTab('Active', _activeRequests.length, selected: true),
            const SizedBox(width: 5),
            _inboxTab('Done', _doneRequests.length),
            const Spacer(),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refreshing ? null : () => _load(refresh: true),
              icon: const Icon(Icons.refresh, size: 17),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _requestList(_activeRequests),
      ],
    );
  }

  Widget _inboxTab(String label, int count, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? MonjedColors.blue : Colors.white,
        border: Border.all(
            color: selected ? MonjedColors.blue : MonjedColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label   $count',
        style: TextStyle(
          color: selected ? Colors.white : MonjedColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _requestList(List<Map<String, dynamic>> requests) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (requests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MonjedColors.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, color: MonjedColors.muted, size: 30),
            SizedBox(height: 12),
            Text(
              'Nothing assigned to you right now.',
              style: TextStyle(color: MonjedColors.muted, fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              'Stay available — operations will match from the admin console.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MonjedColors.muted, fontSize: 11),
            ),
          ],
        ),
      );
    }
    return Column(
      children: requests.map(_requestCard).toList(),
    );
  }

  Widget _requestCard(Map<String, dynamic> r) {
    final status = _status(r);
    final type = _text(r, ['request_type', 'type'], 'Assistance request');
    final description = _text(r, ['description', 'message', 'details'], 'No description');
    final location = _text(r, ['location', 'address', 'zone'], 'Location unavailable');

    final canStart = ['matched', 'assigned', 'accepted'].contains(status);
    final canResolve = ['in_progress', 'started'].contains(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MonjedColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: MonjedColors.blueSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.support_agent_outlined,
                color: MonjedColors.blue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(type,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: MonjedColors.muted, fontSize: 11, height: 1.35)),
                const SizedBox(height: 7),
                Text(
                  '$location  ·  ${_text(r, ['priority'], 'normal')}',
                  style: const TextStyle(
                      color: Color(0xFF9AA6B5), fontSize: 10),
                ),
                if (canStart || canResolve) ...[
                  const SizedBox(height: 9),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () =>
                          _action(r, canResolve ? 'resolve' : 'start'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MonjedColors.blue,
                        side: const BorderSide(color: MonjedColors.blue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        textStyle: const TextStyle(fontSize: 10),
                      ),
                      child: Text(canResolve ? 'Resolve' : 'Start'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    String label = status.replaceAll('_', ' ');
    if (label.isEmpty) label = 'pending';
    label = label[0].toUpperCase() + label.substring(1);
    final done = _isDone(status);
    final progress = ['in_progress', 'started'].contains(status);
    final bg = done
        ? MonjedColors.greenSoft
        : progress
            ? const Color(0xFFFFF2DB)
            : MonjedColors.blueSoft;
    final fg = done
        ? MonjedColors.green
        : progress
            ? MonjedColors.amber
            : MonjedColors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(fontSize: 9, color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _availability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeading(
          'Availability',
          '$_name · $_zone, $_country · Assignments from the assistance API',
        ),
        _errorBanner(),
        Container(
          width: 410,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MonjedColors.line),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MATCHING',
                  style: TextStyle(
                      color: Color(0xFF6B88D4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              const SizedBox(height: 9),
              const Text(
                'When you are available, operations can assign help requests to your private inbox via the assistance API.',
                style: TextStyle(color: MonjedColors.muted, fontSize: 12, height: 1.45),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFD),
                  border: Border.all(color: MonjedColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _available,
                      onChanged: (v) {
                        if (v != null) _setAvailability(v);
                      },
                      activeColor: MonjedColors.blue,
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available for matching',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          SizedBox(height: 3),
                          Text('Currently ON',
                              style: TextStyle(
                                  color: MonjedColors.muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_volunteerId == null || _volunteerId!.isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Volunteer profile is not linked yet; availability changes will be enabled after the responder record is created.',
                  style: TextStyle(color: MonjedColors.red, fontSize: 10, height: 1.35),
                ),
              ],
            ],
          ),
        ),
      ],
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
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD8E2F4), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.radio_button_checked,
                size: 13, color: MonjedColors.blue),
          ),
        ),
        const SizedBox(width: 8),
        const Text('MONJED',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: MonjedColors.ink)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int total;
  final List<int> parts;

  _DonutPainter({required this.total, required this.parts});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 7;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFFD6E0EF);
    canvas.drawCircle(center, radius, base);

    if (total == 0) return;

    final colors = [
      MonjedColors.blue,
      MonjedColors.green,
      MonjedColors.amber,
      const Color(0xFF8C9BB3),
    ];
    var start = -math.pi / 2;
    for (var i = 0; i < parts.length; i++) {
      final sweep = (parts[i] / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.total != total || oldDelegate.parts != parts;
}
