import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  List<Map<String, dynamic>> _requests = [];

  int get _activeCount {
    return _requests.where((request) {
      final status = _status(request);

      return status == 'matched' ||
          status == 'assigned' ||
          status == 'accepted' ||
          status == 'in_progress' ||
          status == 'started';
    }).length;
  }

  int get _completedCount {
    return _requests.where((request) {
      final status = _status(request);

      return status == 'resolved' ||
          status == 'completed' ||
          status == 'closed';
    }).length;
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ============================================================
  // LOAD REQUESTS
  // ============================================================

  Future<void> _loadRequests({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _apiService.get('/assistance/requests');

      final parsedRequests = _extractRequests(response);

      if (!mounted) return;

      setState(() {
        _requests = parsedRequests;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  List<Map<String, dynamic>> _extractRequests(dynamic response) {
    dynamic data = response;

    if (response is Map<String, dynamic>) {
      if (response['items'] is List) {
        data = response['items'];
      } else if (response['requests'] is List) {
        data = response['requests'];
      } else if (response['data'] is List) {
        data = response['data'];
      } else if (response['data'] is Map<String, dynamic>) {
        final nestedData = response['data'];

        if (nestedData['items'] is List) {
          data = nestedData['items'];
        } else if (nestedData['requests'] is List) {
          data = nestedData['requests'];
        } else {
          data = [];
        }
      } else {
        data = [];
      }
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // ============================================================
  // REQUEST HELPERS
  // ============================================================

  String _status(Map<String, dynamic> request) {
    return (request['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  String _requestId(Map<String, dynamic> request) {
    return (request['request_id'] ??
            request['id'] ??
            request['_id'] ??
            '')
        .toString();
  }

  String _description(Map<String, dynamic> request) {
    return (request['description'] ??
            request['message'] ??
            request['details'] ??
            'Assistance request')
        .toString();
  }

  String _createdAt(Map<String, dynamic> request) {
    return (request['created_at'] ??
            request['createdAt'] ??
            '')
        .toString();
  }

  String _location(Map<String, dynamic> request) {
    final location = request['location'];

    if (location == null) {
      return 'Location not available';
    }

    if (location is String) {
      return location;
    }

    if (location is Map) {
      final place = location['place'] ??
          location['address'] ??
          location['name'] ??
          location['city'] ??
          location['zone'];

      if (place != null && place.toString().isNotEmpty) {
        return place.toString();
      }

      final latitude =
          location['latitude'] ?? location['lat'];

      final longitude =
          location['longitude'] ?? location['lng'] ?? location['lon'];

      if (latitude != null && longitude != null) {
        return '$latitude, $longitude';
      }
    }

    return location.toString();
  }

  String _beneficiaryName(Map<String, dynamic> request) {
    final beneficiary = request['beneficiary'] ??
        request['recipient'] ??
        request['user'];

    if (beneficiary is Map) {
      return (beneficiary['name'] ??
              beneficiary['full_name'] ??
              beneficiary['display_name'] ??
              'Beneficiary')
          .toString();
    }

    return 'Beneficiary';
  }

  String _beneficiaryPhone(Map<String, dynamic> request) {
    final beneficiary = request['beneficiary'] ??
        request['recipient'] ??
        request['user'];

    if (beneficiary is Map) {
      return (beneficiary['phone'] ??
              beneficiary['phone_number'] ??
              '')
          .toString();
    }

    return (request['phone'] ?? request['phone_number'] ?? '')
        .toString();
  }

  // ============================================================
  // START REQUEST
  // ============================================================

  Future<void> _startRequest(Map<String, dynamic> request) async {
    final requestId = _requestId(request);

    if (requestId.isEmpty) {
      _showMessage('Request ID is missing.');
      return;
    }

    try {
      _showLoadingDialog();

      await _apiService.post(
        '/assistance/requests/$requestId/start',
       
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _showMessage(
        'Request started successfully.',
        success: true,
      );

      await _loadRequests(refresh: true);
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      _showMessage(_cleanError(e));
    }
  }

  // ============================================================
  // RESOLVE REQUEST
  // ============================================================

  Future<void> _resolveRequest(Map<String, dynamic> request) async {
    final requestId = _requestId(request);

    if (requestId.isEmpty) {
      _showMessage('Request ID is missing.');
      return;
    }

    final confirmed = await _showResolveDialog();

    if (!confirmed) {
      return;
    }

    try {
      _showLoadingDialog();

      await _apiService.post(
        '/assistance/requests/$requestId/resolve',
      
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _showMessage(
        'Request resolved successfully.',
        success: true,
      ); 


      await _loadRequests(refresh: true);
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      _showMessage(_cleanError(e));
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Volunteer Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: _isRefreshing
                ? null
                : () => _loadRequests(refresh: true),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadRequests(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildStats(),

          const SizedBox(height: 28),

          _buildRequestsHeader(),

          const SizedBox(height: 12),

          if (_requests.isEmpty)
            _buildEmptyState()
          else
            ..._requests.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildRequestCard(request),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volunteer assignments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage assistance requests assigned to you.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'ACTIVE',
            count: _activeCount.toString(),
            subtitle: 'Assigned & in progress',
            icon: Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'COMPLETED',
            count: _completedCount.toString(),
            subtitle: 'Resolved requests',
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REQUESTS HEADER
  // ============================================================

  Widget _buildRequestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ASSISTANCE REQUESTS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black87,
          ),
        ),
        Text(
          '${_requests.length} total',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestCard(
    Map<String, dynamic> request,
  ) {
    final status = _status(request);
    final requestId = _requestId(request);

    final description = _description(request);
    final location = _location(request);
    final beneficiary = _beneficiaryName(request);
    final phone = _beneficiaryPhone(request);
    final createdAt = _createdAt(request);

    final statusInfo = _statusInfo(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  requestId.isEmpty
                      ? 'Assistance Request'
                      : 'Request #$requestId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              _buildStatusBadge(
                statusInfo.label,
                statusInfo.icon,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // DESCRIPTION
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // BENEFICIARY
          _InfoRow(
            icon: Icons.person_outline,
            title: 'Beneficiary',
            value: beneficiary,
          ),

          const SizedBox(height: 10),

          // PHONE
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InfoRow(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: phone,
              ),
            ),

          // LOCATION
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: location,
          ),

          // CREATED AT
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time,
              title: 'Created',
              value: _formatDate(createdAt),
            ),
          ],

          const SizedBox(height: 16),

          _buildActions(
            request,
            status,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(
    Map<String, dynamic> request,
    String status,
  ) {
    final canStart = status == 'matched' ||
        status == 'assigned' ||
        status == 'accepted';

    final canResolve = status == 'in_progress' ||
        status == 'started';

    final isCompleted = status == 'resolved' ||
        status == 'completed' ||
        status == 'closed';

    if (isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: Colors.green,
            ),
            SizedBox(width: 8),
            Text(
              'This request has been resolved',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (canStart) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _startRequest(request),
          icon: const Icon(Icons.play_arrow),
          label: const Text('START REQUEST'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    if (canResolve) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _resolveRequest(request),
          icon: const Icon(Icons.check),
          label: const Text('RESOLVE REQUEST'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Status: ${_prettyStatus(status)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(
    String label,
    IconData icon,
  ) {
    Color background;
    Color foreground;

    switch (label.toLowerCase()) {
      case 'resolved':
      case 'completed':
        background = Colors.green.withAlpha(20);
        foreground = Colors.green.shade700;
        break;

      case 'in progress':
      case 'started':
        background = Colors.orange.withAlpha(25);
        foreground = Colors.orange.shade800;
        break;

      case 'assigned':
      case 'matched':
        background = Colors.blue.withAlpha(20);
        foreground = Colors.blue.shade700;
        break;

      default:
        background = Colors.grey.withAlpha(20);
        foreground = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 52,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No assistance requests',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'There are currently no requests assigned to you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: () => _loadRequests(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_outlined,
            size: 55,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 18),
          const Text(
            'Could not load requests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadRequests(),
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'matched':
        return const _StatusInfo(
          'Matched',
          Icons.person_pin_circle_outlined,
        );

      case 'assigned':
        return const _StatusInfo(
          'Assigned',
          Icons.assignment_ind_outlined,
        );

      case 'accepted':
        return const _StatusInfo(
          'Accepted',
          Icons.thumb_up_alt_outlined,
        );

      case 'in_progress':
        return const _StatusInfo(
          'In Progress',
          Icons.directions_run,
        );

      case 'started':
        return const _StatusInfo(
          'Started',
          Icons.play_circle_outline,
        );

      case 'resolved':
        return const _StatusInfo(
          'Resolved',
          Icons.check_circle_outline,
        );

      case 'completed':
        return const _StatusInfo(
          'Completed',
          Icons.check_circle_outline,
        );

      case 'closed':
        return const _StatusInfo(
          'Closed',
          Icons.lock_outline,
        );

      default:
        return const _StatusInfo(
          'Pending',
          Icons.pending_outlined,
        );
    }
  }

  String _prettyStatus(String status) {
    if (status.isEmpty) {
      return 'Unknown';
    }

    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year  $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<bool> _showResolveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Resolve request'),
          content: const Text(
            'Are you sure this assistance request has been completed?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('RESOLVE'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return text;
  }
}

// ============================================================
// STAT CARD
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STATUS INFO
// ============================================================

class _StatusInfo {
  final String label;
  final IconData icon;

  const _StatusInfo(
    this.label,
    this.icon,
  );
}
