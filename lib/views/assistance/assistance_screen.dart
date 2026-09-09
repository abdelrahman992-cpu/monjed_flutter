import 'package:flutter/material.dart';

import '../../controllers/assistance_controller.dart';
import '../../models/assistance_request.dart';
import 'request_details_screen.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({
    super.key,
  });

  @override
  State<AssistanceScreen> createState() =>
      _AssistanceScreenState();
}

class _AssistanceScreenState
    extends State<AssistanceScreen> {
  final AssistanceController controller =
      AssistanceController();

  bool loading = true;
  String? error;
  List<AssistanceRequest> requests = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await controller.getRequests();

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
        title: const Text('Assistance Requests'),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No assistance requests found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: ListTile(
              title: Text(
                request.requestType ??
                    'Assistance Request',
              ),
              subtitle: Text(
                '${request.country ?? ''} '
                '${request.zone ?? ''}\n'
                'Status: ${request.status ?? 'unknown'}',
              ),
              isThreeLine: true,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
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
