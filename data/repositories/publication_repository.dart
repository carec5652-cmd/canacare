import 'package:admin_can_care/data/models/publication_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Publication Repository
// مستودع المنشورات
class PublicationRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'publications';

  // Stream Publications
  // تدفق المنشورات
  Stream<List<PublicationModel>> streamPublications({String? visibility}) {
    return _firestoreService
        .streamCollection(
          _collection,
          queryBuilder: (query) {
            Query q = query.orderBy('createdAt', descending: true);
            if (visibility != null && visibility.isNotEmpty) {
              q = q.where('visibility', isEqualTo: visibility);
            }
            return q;
          },
        )
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => PublicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
                  )
                  .toList(),
        );
  }

  // Get Publication by ID
  // الحصول على منشور بالمعرف
  Future<PublicationModel?> getPublication(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (!doc.exists) return null;
      return PublicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get publication: $e';
    }
  }

  // Create Publication
  // إنشاء منشور
  Future<String> createPublication(PublicationModel publication) async {
    try {
      return await _firestoreService.createDocument(_collection, publication.toMap());
    } catch (e) {
      throw 'Failed to create publication: $e';
    }
  }

  // Update Publication
  // تحديث منشور
  Future<void> updatePublication(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data);
    } catch (e) {
      throw 'Failed to update publication: $e';
    }
  }

  // Delete Publication
  // حذف منشور
  Future<void> deletePublication(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw 'Failed to delete publication: $e';
    }
  }
}
