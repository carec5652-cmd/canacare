import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/transport_request_model.dart';
import 'package:admin_can_care/data/repositories/transport_repository.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';

// Transport Requests Screen - شاشة طلبات النقل
class TransportRequestsScreen extends StatefulWidget {
  const TransportRequestsScreen({super.key});

  @override
  State<TransportRequestsScreen> createState() => _TransportRequestsScreenState();
}

class _TransportRequestsScreenState extends State<TransportRequestsScreen> {
  final _repo = TransportRepository();
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'طلبات النقل' : 'Transport Requests'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedStatus,
            onSelected: (value) => setState(() => _selectedStatus = value == 'all' ? null : value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(isRTL ? 'الكل' : 'All')),
              PopupMenuItem(value: 'pending', child: Text(isRTL ? 'قيد الانتظار' : 'Pending')),
              PopupMenuItem(value: 'assigned', child: Text(isRTL ? 'تم التعيين' : 'Assigned')),
              PopupMenuItem(value: 'completed', child: Text(isRTL ? 'مكتمل' : 'Completed')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<TransportRequestModel>>(
        stream: _repo.streamTransportRequests(status: _selectedStatus),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return EmptyState(
              icon: Icons.local_shipping_outlined,
              message: 'No transport requests',
              messageAr: 'لا توجد طلبات نقل',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
                    child: Icon(Icons.local_shipping, color: _getStatusColor(request.status)),
                  ),
                  title: Text(request.patientName ?? 'Patient'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${isRTL ? 'من' : 'From'}: ${request.fromLocation}'),
                      Text('${isRTL ? 'إلى' : 'To'}: ${request.toLocation}'),
                      const SizedBox(height: 4),
                      _buildStatusChip(request.status),
                    ],
                  ),
                  trailing: request.status == 'pending'
                      ? IconButton(
                          icon: const Icon(Icons.assignment_ind),
                          onPressed: () => _assignDriver(request),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    String label;
    switch (status) {
      case 'pending':
        label = isRTL ? 'قيد الانتظار' : 'Pending';
        break;
      case 'assigned':
        label = isRTL ? 'تم التعيين' : 'Assigned';
        break;
      case 'in_progress':
        label = isRTL ? 'جاري التنفيذ' : 'In Progress';
        break;
      case 'completed':
        label = isRTL ? 'مكتمل' : 'Completed';
        break;
      default:
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        label,
        style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _assignDriver(TransportRequestModel request) async {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // Simplified: Just mark as assigned
    try {
      await _repo.updateTransportRequest(request.id, {'status': 'assigned'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRTL ? 'تم التعيين' : 'Driver assigned')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

