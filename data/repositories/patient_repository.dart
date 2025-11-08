import 'package:admin_can_care/data/models/patient_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Patient Repository
// مستودع المرضى
class PatientRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'patients';

  // Get All Patients
  // الحصول على جميع المرضى
  Future<List<PatientModel>> getAllPatients() async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        _collection,
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      );
      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get patients: $e';
    }
  }

  // Stream Patients
  // تدفق المرضى
  Stream<List<PatientModel>> streamPatients({String? doctorId, String? nurseId, String? status}) {
    return _firestoreService
        .streamCollection(
          _collection,
          queryBuilder: (query) {
            Query q = query.orderBy('createdAt', descending: true);
            if (doctorId != null && doctorId.isNotEmpty) {
              q = q.where('doctorId', isEqualTo: doctorId);
            }
            if (nurseId != null && nurseId.isNotEmpty) {
              q = q.where('nurseId', isEqualTo: nurseId);
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
                  .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .toList(),
        );
  }

  // Get Patient by ID
  // الحصول على مريض بالمعرف
  Future<PatientModel?> getPatient(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (!doc.exists) return null;
      return PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get patient: $e';
    }
  }

  // Create Patient
  // إضافة مريض
  Future<String> createPatient(PatientModel patient) async {
    try {
      return await _firestoreService.createDocument(_collection, patient.toMap());
    } catch (e) {
      throw 'Failed to create patient: $e';
    }
  }

  // Update Patient
  // تحديث مريض
  Future<void> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data);
    } catch (e) {
      throw 'Failed to update patient: $e';
    }
  }

  // Delete Patient
  // حذف مريض
  Future<void> deletePatient(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw 'Failed to delete patient: $e';
    }
  }

  // Get Patients Count
  // احصل على عدد المرضى
  Future<int> getPatientsCount({String? status}) async {
    try {
      return await _firestoreService.getCollectionCount(
        _collection,
        queryBuilder: status != null ? (query) => query.where('status', isEqualTo: status) : null,
      );
    } catch (e) {
      return 0;
    }
  }

  // Get Patients by Doctor
  // الحصول على مرضى طبيب معين
  Future<List<PatientModel>> getPatientsByDoctor(String doctorId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        _collection,
        queryBuilder: (query) => query.where('doctorId', isEqualTo: doctorId),
      );
      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get patients by doctor: $e';
    }
  }

  // Get Patients by Nurse
  // الحصول على مرضى ممرض معين
  Future<List<PatientModel>> getPatientsByNurse(String nurseId) async {
    try {
      final snapshot = await _firestoreService.queryCollection(
        _collection,
        queryBuilder: (query) => query.where('nurseId', isEqualTo: nurseId),
      );
      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get patients by nurse: $e';
    }
  }

  // Search Patients
  // البحث عن المرضى
  Future<List<PatientModel>> searchPatients(String searchTerm) async {
    try {
      final snapshot = await _firestoreService.queryCollection(_collection);
      final patients =
          snapshot.docs
              .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

      // Simple client-side search
      return patients.where((patient) {
        final term = searchTerm.toLowerCase();
        return patient.name.toLowerCase().contains(term) ||
            patient.diagnosis.toLowerCase().contains(term) ||
            (patient.phone?.toLowerCase().contains(term) ?? false);
      }).toList();
    } catch (e) {
      throw 'Failed to search patients: $e';
    }
  }
}
