import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/reports_controller.dart';
import '../../controllers/assistance_controller.dart';
import '../../widgets/monjed_ui.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _dashboard = DashboardController();
  final _reports = ReportsController();
  final _assistance = AssistanceController();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _reportsList = [];
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  dynamic _data(dynamic x) =>
      x is Map<String, dynamic> && x['data'] is Map ? x['data'] : x;

  List<Map<String, dynamic>> _list(dynamic x, String key) {
    dynamic d = x;
    if (d is Map) {
      d = d[key] ?? d['items'] ?? d['data'] ?? [];
      if (d is Map) d = d['items'] ?? d[key] ?? [];
    }
    return d is List
        ? d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : [];
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await Future.wait([
        _dashboard.getOverview(),
        _dashboard.getRisks(),
        _dashboard.getAlerts(),
        _reports.getReports(),
        _assistance.getRequests(),
      ]);
      final o = _data(r[0]);
      if (!mounted) return;
      setState(() {
        _overview = o is Map ? Map<String, dynamic>.from(o) : {};
        _reportsList = _list(r[3], 'reports');
        _requests = _list(r[4], 'requests');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _num(List<String> keys) {
    for (final k in keys) {
      if (_overview[k] != null) return '${_overview[k]}';
    }
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    return MonjedShell(
      title: 'Admin dashboard',
      eyebrow: 'OPERATIONS CONTROL',
      actions: [
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh, color: MonjedColors.muted),
        ),
      ],
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, c) {
                    final stats = GridView.count(
                      crossAxisCount:
                          c.maxWidth > 1000 ? 4 : c.maxWidth > 650 ? 2 : 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: c.maxWidth > 650 ? 2.1 : 3.0,
                      children: [
                        StatCard(
                          label: 'Users',
                          value: _num(['users_count', 'users', 'total_users']),
                          icon: Icons.people_outline,
                        ),
                        StatCard(
                          label: 'Volunteers',
                          value: _num([
                            'volunteers_count',
                            'volunteers',
                            'total_volunteers',
                          ]),
                          icon: Icons.volunteer_activism_outlined,
                          tint: MonjedColors.greenSoft,
                        ),
                        StatCard(
                          label: 'Help requests',
                          value: _num([
                            'assistance_requests',
                            'help_requests',
                            'requests_count',
                            'requests',
                          ]),
                          icon: Icons.support_agent_outlined,
                          tint: const Color(0xFFFFF2DB),
                        ),
                        StatCard(
                          label: 'Reports',
                          value: _num([
                            'reports_count',
                            'reports',
                            'community_reports',
                          ]),
                          icon: Icons.report_problem_outlined,
                          tint: const Color(0xFFFCE7ED),
                        ),
                      ],
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        stats,
                        const SizedBox(height: 22),
                        if (c.maxWidth > 850)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _panel(
                                  'Recent help requests',
                                  _requests,
                                  Icons.support_agent_outlined,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _panel(
                                  'Community reports',
                                  _reportsList,
                                  Icons.report_problem_outlined,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _panel(
                            'Recent help requests',
                            _requests,
                            Icons.support_agent_outlined,
                          ),
                          const SizedBox(height: 18),
                          _panel(
                            'Community reports',
                            _reportsList,
                            Icons.report_problem_outlined,
                          ),
                        ],
                        const SizedBox(height: 18),
                        _quickActions(context),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _panel(String title, List<Map<String, dynamic>> items, IconData icon) {
    return MonjedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: MonjedColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${items.length}',
                style: const TextStyle(
                  color: MonjedColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No records available.',
                style: TextStyle(color: MonjedColors.muted, fontSize: 13),
              ),
            )
          else
            ...items.take(5).map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MonjedColors.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${x['request_type'] ?? x['report_text'] ?? x['type'] ?? x['report_id'] ?? 'Record'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _badge(
                            '${x['status'] ?? (x['resolved'] == true ? 'resolved' : 'new')}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _badge(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: MonjedColors.blueSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          s,
          style: const TextStyle(
            color: MonjedColors.blue,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _quickActions(BuildContext context) => MonjedCard(
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/report'),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Review reports'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/help'),
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Assistance'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/volunteer-dashboard'),
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: const Text('Volunteer view'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/volunteer-login'),
              icon: const Icon(Icons.login_outlined),
              label: const Text('Volunteer login'),
            ),
          ],
        ),
      );
}
