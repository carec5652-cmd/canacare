import 'package:admin_can_care/data/models/nurse_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Nurse Repository
// مستودع الممرضين
class NurseRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'nurses';

  // Get All Nurses
  // الحصول على جميع الممرضين
  Future<List<NurseModel>> getAllNurses() async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        _collection,
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      );
      return snapshot.docs
          .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get nurses: $e';
    }
  }

  // Stream Nurses
  // تدفق الممرضين
  Stream<List<NurseModel>> streamNurses({String? department, String? status}) {
    return _firestoreService
        .streamCollection(
          _collection,
          queryBuilder: (query) {
            Query q = query.orderBy('createdAt', descending: true);
            if (department != null && department.isNotEmpty) {
              q = q.where('department', isEqualTo: department);
            }
            if (status != null && status.isNotEmpty) {
              q = q.where('status', isEqualTo: status);
            }
            return q;
          },
        )
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .toList(),
        );
  }

  // Get Nurse by ID
  // الحصول على ممرض بالمعرف
  Future<NurseModel?> getNurse(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (!doc.exists) return null;
      return NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get nurse: $e';
    }
  }

  // Create Nurse
  // إضافة ممرض
  Future<String> createNurse(NurseModel nurse) async {
    try {
      return await _firestoreService.createDocument(_collection, nurse.toMap());
    } catch (e) {
      throw 'Failed to create nurse: $e';
    }
  }

  // Update Nurse
  // تحديث ممرض
  Future<void> updateNurse(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data);
    } catch (e) {
      throw 'Failed to update nurse: $e';
    }
  }

  // Delete Nurse
  // حذف ممرض
  Future<void> deleteNurse(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw 'Failed to delete nurse: $e';
    }
  }

  // Get Nurses Count
  // احصل على عدد الممرضين
  Future<int> getNursesCount({String? status}) async {
    try {
      return await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: status != null ? (query) => query.where('status', isEqualTo: status) : null,
      );
    } catch (e) {
      return 0;
    }
  }

  // Search Nurses
  // البحث عن الممرضين
  Future<List<NurseModel>> searchNurses(String searchTerm) async {
    try {
      final snapshot = await _firestoreService.queryCollection(_collection);
      final nurses =
          snapshot.docs
              .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

      // Simple client-side search
      return nurses.where((nurse) {
        final term = searchTerm.toLowerCase();
        return nurse.name.toLowerCase().contains(term) ||
            nurse.department.toLowerCase().contains(term) ||
            (nurse.email.toLowerCase().contains(term));
      }).toList();
    } catch (e) {
      throw 'Failed to search nurses: $e';
    }
  }
}
