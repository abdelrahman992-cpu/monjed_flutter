import 'package:flutter/material.dart';

import '../../controllers/assistance_controller.dart';
import '../../models/assistance_request.dart';

class RequestDetailsScreen
    extends StatefulWidget {
  final String requestId;

  const RequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestDetailsScreen> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState
    extends State<RequestDetailsScreen> {
  final AssistanceController controller =
      AssistanceController();

  AssistanceRequest? request;

  bool loading = true;
  bool actionLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadRequest();
  }

  Future<void> loadRequest() async {
    try {
      final result =
          await controller.getRequest(
        widget.requestId,
      );

      setState(() {
        request = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> runAction(
    Future<dynamic> Function() action,
  ) async {
    setState(() {
      actionLoading = true;
    });

    try {
      await action();

      await loadRequest();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Request updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Details',
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
        child: Text(error!),
      );
    }

    if (request == null) {
      return const Center(
        child: Text(
          'Request not found',
        ),
      );
    }

    final r = request!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _info(
            'Request ID',
            r.id,
          ),
          _info(
            'Type',
            r.requestType,
          ),
          _info(
            'Country',
            r.country,
          ),
          _info(
            'Zone',
            r.zone,
          ),
          _info(
            'Priority',
            r.priority,
          ),
          _info(
            'Status',
            r.status,
          ),
          _info(
            'Volunteer',
            r.assignedVolunteerId,
          ),
          const SizedBox(height: 16),
          const Text(
            'Accessibility Needs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          if (r.accessibilityNeeds.isEmpty)
            const Text('None')
          else
            Wrap(
              spacing: 8,
              children: r.accessibilityNeeds
                  .map(
                    (need) => Chip(
                      label: Text(need),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 30),
          _buildActions(r),
        ],
      ),
    );
  }

  Widget _info(
    String title,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    AssistanceRequest r,
  ) {
    if (actionLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final status = r.status?.toLowerCase();

    if (status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            runAction(
              () => controller.matchRequest(
                r.id,
              ),
            );
          },
          child: const Text(
            'Match Request',
          ),
        ),
      );
    }

    if (status == 'matched') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            runAction(
              () => controller.startRequest(
                r.id,
              ),
            );
          },
          child: const Text(
            'Start Assistance',
          ),
        ),
      );
    }

    if (status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            runAction(
              () => controller.resolveRequest(
                r.id,
              ),
            );
          },
          child: const Text(
            'Resolve Request',
          ),
        ),
      );
    }

    return Text(
      'Current status: ${r.status ?? 'unknown'}',
    );
  }
}
