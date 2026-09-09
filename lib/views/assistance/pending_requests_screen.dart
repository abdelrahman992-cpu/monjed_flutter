import 'package:flutter/material.dart';

import '../../controllers/assistance_controller.dart';
import '../../models/assistance_request.dart';
import 'request_details_screen.dart';

class PendingRequestsScreen
    extends StatefulWidget {
  const PendingRequestsScreen({
    super.key,
  });

  @override
  State<PendingRequestsScreen> createState() =>
      _PendingRequestsScreenState();
}

class _PendingRequestsScreenState
    extends State<PendingRequestsScreen> {
  final AssistanceController controller =
      AssistanceController();

  bool loading = true;
  String? error;

  List<AssistanceRequest> requests = [];

  @override
  void initState() {
    super.initState();
    loadPendingRequests();
  }

  Future<void> loadPendingRequests() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await controller.getPendingRequests();

      setState(() {
        requests = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Requests',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: ElevatedButton(
          onPressed: loadPendingRequests,
          child: const Text('Retry'),
        ),
      );
    }

    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No pending requests.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPendingRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return Card(
            child: ListTile(
              title: Text(
                request.requestType ??
                    'Assistance Request',
              ),
              subtitle: Text(
                'Priority: '
                '${request.priority ?? 'normal'}\n'
                'Zone: '
                '${request.zone ?? 'unknown'}',
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RequestDetailsScreen(
                      requestId: request.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
