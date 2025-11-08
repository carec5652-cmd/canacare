import 'package:admin_can_care/data/models/transport_request_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Transport Repository
// مستودع طلبات النقل
class TransportRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'transportRequests';

  // Stream Transport Requests
  // تدفق طلبات النقل
  Stream<List<TransportRequestModel>> streamTransportRequests({String? status}) {
    return _firestoreService.streamCollection(
      _collection,
      queryBuilder: (query) {
        Query q = query;
        
        // Apply filters WITHOUT orderBy to avoid index requirement
        if (status != null && status.isNotEmpty) {
          q = q.where('status', isEqualTo: status);
        }
        
        return q;
      },
    ).map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => TransportRequestModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Sort in memory instead of Firestore
      docs.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return docs;
    });
  }

  // Get Transport Request by ID
  // الحصول على طلب نقل بالمعرف
  Future<TransportRequestModel?> getTransportRequest(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (!doc.exists) return null;
      return TransportRequestModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get transport request: $e';
    }
  }

  // Create Transport Request
  // إنشاء طلب نقل
  Future<String> createTransportRequest(TransportRequestModel request) async {
    try {
      return await _firestoreService.createDocument(_collection, request.toMap());
    } catch (e) {
      throw 'Failed to create transport request: $e';
    }
  }

  // Update Transport Request
  // تحديث طلب نقل
  Future<void> updateTransportRequest(
      String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data);
    } catch (e) {
      throw 'Failed to update transport request: $e';
    }
  }

  // Assign Driver
  // تعيين سائق
  Future<void> assignDriver(
      String requestId, String driverId, String driverName) async {
    try {
      await updateTransportRequest(requestId, {
        'assignedDriverId': driverId,
        'assignedDriverName': driverName,
        'status': 'assigned',
      });
    } catch (e) {
      throw 'Failed to assign driver: $e';
    }
  }

  // Complete Transport Request
  // إكمال طلب النقل
  Future<void> completeRequest(String requestId) async {
    try {
      await updateTransportRequest(requestId, {
        'status': 'completed',
        'completedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to complete request: $e';
    }
  }

  // Get Transport Statistics
  // الحصول على إحصائيات النقل
  Future<Map<String, int>> getTransportStats() async {
    try {
      final total = await _firestoreService.getCollectionCount(_collection);
      final pending = await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'pending'),
      );
      final completed = await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'completed'),
      );
      final cancelled = await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'cancelled'),
      );

      return {
        'total': total,
        'pending': pending,
        'completed': completed,
        'cancelled': cancelled,
        'inProgress': total - pending - completed - cancelled,
      };
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
        'inProgress': 0,
      };
    }
  }
}

