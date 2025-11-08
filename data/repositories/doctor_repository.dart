import 'package:admin_can_care/data/models/doctor_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Doctor Repository
// مستودع الأطباء
class DoctorRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'doctors';

  // Get All Doctors
  // الحصول على جميع الأطباء
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        _collection,
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      );
      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get doctors: $e';
    }
  }

  // Stream Doctors
  // تدفق الأطباء
  Stream<List<DoctorModel>> streamDoctors({String? specialty, String? status}) {
    return _firestoreService
        .streamCollection(
          _collection,
          queryBuilder: (query) {
            Query q = query.orderBy('createdAt', descending: true);
            if (specialty != null && specialty.isNotEmpty) {
              q = q.where('specialty', isEqualTo: specialty);
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
                  .map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .toList(),
        );
  }

  // Get Doctor by ID
  // الحصول على طبيب بالمعرف
  Future<DoctorModel?> getDoctor(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (!doc.exists) return null;
      return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get doctor: $e';
    }
  }

  // Create Doctor
  // إضافة طبيب
  Future<String> createDoctor(DoctorModel doctor) async {
    try {
      return await _firestoreService.createDocument(_collection, doctor.toMap());
    } catch (e) {
      throw 'Failed to create doctor: $e';
    }
  }

  // Update Doctor
  // تحديث طبيب
  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data);
    } catch (e) {
      throw 'Failed to update doctor: $e';
    }
  }

  // Delete Doctor
  // حذف طبيب
  Future<void> deleteDoctor(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw 'Failed to delete doctor: $e';
    }
  }

  // Get Doctors Count
  // احصل على عدد الأطباء
  Future<int> getDoctorsCount({String? status}) async {
    try {
      return await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: status != null ? (query) => query.where('status', isEqualTo: status) : null,
      );
    } catch (e) {
      return 0;
    }
  }

  // Search Doctors
  // البحث عن الأطباء
  Future<List<DoctorModel>> searchDoctors(String searchTerm) async {
    try {
      final snapshot = await _firestoreService.queryCollection(_collection);
      final doctors =
          snapshot.docs
              .map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

      // Simple client-side search
      return doctors.where((doctor) {
        final term = searchTerm.toLowerCase();
        return doctor.name.toLowerCase().contains(term) ||
            doctor.specialty.toLowerCase().contains(term) ||
            (doctor.email.toLowerCase().contains(term));
      }).toList();
    } catch (e) {
      throw 'Failed to search doctors: $e';
    }
  }
}
