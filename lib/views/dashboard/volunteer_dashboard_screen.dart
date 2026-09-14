import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/monjed_ui.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});
  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _available = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  dynamic _id(Map x) => x['request_id'] ?? x['id'] ?? x['_id'] ?? '';
  String _status(Map x) => '${x['status'] ?? 'pending'}'.toLowerCase();

  List<Map<String, dynamic>> _list(dynamic x) {
    dynamic d = x;
    if (x is Map) {
      d = x['requests'] ?? x['items'] ?? x['data'] ?? [];
      if (d is Map) d = d['requests'] ?? d['items'] ?? [];
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
      final r = await _api.get('/assistance/requests');
      if (!mounted) return;
      setState(() => _requests = _list(r));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(String id, String action) async {
    try {
      await _api.post('/assistance/requests/$id/$action');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request updated.'),
          backgroundColor: MonjedColors.green,
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MonjedShell(
      title: 'Volunteer dashboard',
      eyebrow: 'FIELD RESPONSE',
      actions: [
        Row(
          children: [
            const Text(
              'Available',
              style: TextStyle(fontSize: 12, color: MonjedColors.muted),
            ),
            Switch(
              value: _available,
              onChanged: (v) => setState(() => _available = v),
              activeColor: MonjedColors.blue,
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: MonjedColors.muted),
            ),
          ],
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        final active = _requests.where((x) {
                          final s = _status(x);
                          return [
                            'matched',
                            'assigned',
                            'accepted',
                            'in_progress',
                            'started',
                          ].contains(s);
                        }).length;
                        final done = _requests.where((x) {
                          final s = _status(x);
                          return ['resolved', 'completed', 'closed'].contains(s);
                        }).length;

                        return GridView.count(
                          crossAxisCount:
                              c.maxWidth > 900 ? 3 : c.maxWidth > 600 ? 2 : 1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: c.maxWidth > 600 ? 2.1 : 3,
                          children: [
                            StatCard(
                              label: 'Assigned',
                              value: '$active',
                              icon: Icons.assignment_outlined,
                            ),
                            StatCard(
                              label: 'Completed',
                              value: '$done',
                              icon: Icons.task_alt,
                              tint: MonjedColors.greenSoft,
                            ),
                            StatCard(
                              label: 'All requests',
                              value: '${_requests.length}',
                              icon: Icons.inbox_outlined,
                              tint: const Color(0xFFFFF2DB),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    MonjedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Requests near you',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Start or resolve an assigned response from this dashboard.',
                            style: TextStyle(
                              color: MonjedColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_requests.isEmpty)
                            const Text(
                              'No assistance requests available.',
                              style: TextStyle(color: MonjedColors.muted),
                            )
                          else
                            ..._requests.map(_requestCard),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _requestCard(Map<String, dynamic> x) {
    final id = '${_id(x)}';
    final s = _status(x);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MonjedColors.bg,
        borderRadius: BorderRadius.circular(9),
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
            child: const Icon(
              Icons.support_agent_outlined,
              color: MonjedColors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${x['request_type'] ?? 'Assistance request'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  '${x['description'] ?? x['message'] ?? 'No description'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MonjedColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Zone: ${x['zone'] ?? x['zone_id'] ?? '—'}  •  Status: $s',
                  style: const TextStyle(
                    fontSize: 11,
                    color: MonjedColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (s == 'matched' || s == 'assigned' || s == 'accepted')
            TextButton(
              onPressed: id.isEmpty ? null : () => _action(id, 'start'),
              child: const Text('Start'),
            ),
          if (s == 'in_progress' || s == 'started')
            TextButton(
              onPressed: id.isEmpty ? null : () => _action(id, 'resolve'),
              child: const Text('Resolve'),
            ),
        ],
      ),
    );
  }
}
