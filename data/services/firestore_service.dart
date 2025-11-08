import 'package:cloud_firestore/cloud_firestore.dart';

// Generic Firestore Service
// خدمة Firestore عامة
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Collection Reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  // Create Document
  // إنشاء وثيقة
  Future<String> createDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      throw 'Failed to create document: $e';
    }
  }

  // Create Document with ID
  // إنشاء وثيقة بمعرف محدد
  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(collectionPath)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      throw 'Failed to set document: $e';
    }
  }

  // Read Document
  // قراءة وثيقة
  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) async {
    try {
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e) {
      throw 'Failed to get document: $e';
    }
  }

  // Update Document
  // تحديث وثيقة
  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      throw 'Failed to update document: $e';
    }
  }

  // Delete Document
  // حذف وثيقة
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  // Stream Document
  // تدفق وثيقة
  Stream<DocumentSnapshot> streamDocument(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  // Stream Collection
  // تدفق مجموعة
  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    Query Function(Query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Query Collection
  // استعلام مجموعة
  Future<QuerySnapshot> queryCollection(
    String collectionPath, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    } catch (e) {
      throw 'Failed to query collection: $e';
    }
  }

  // Get Collection Count (requires Firebase Extensions or custom aggregation)
  // احصل على عدد المجموعة
  Future<int> getCollectionCount(
    String collectionPath, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      throw 'Failed to count documents: $e';
    }
  }

  // Batch Write
  // كتابة دفعة
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      for (final op in operations) {
        final type = op['type'] as String;
        final path = op['path'] as String;
        final data = op['data'] as Map<String, dynamic>?;

        switch (type) {
          case 'set':
            batch.set(_firestore.doc(path), data!);
            break;
          case 'update':
            batch.update(_firestore.doc(path), data!);
            break;
          case 'delete':
            batch.delete(_firestore.doc(path));
            break;
        }
      }
      await batch.commit();
    } catch (e) {
      throw 'Batch write failed: $e';
    }
  }
}

