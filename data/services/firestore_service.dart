// استيراد Cloud Firestore - للتعامل مع قاعدة البيانات السحابية من Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// Generic Firestore Service
// خدمة Firestore عامة - توفر عمليات CRUD أساسية لجميع المجموعات
// CRUD = Create (إنشاء), Read (قراءة), Update (تحديث), Delete (حذف)
// يمكن استخدامها لأي مجموعة: doctors, nurses, patients, admins, إلخ...
class FirestoreService {
  // كائن Firestore - للوصول لقاعدة البيانات
  // final = لا يمكن تغييره بعد التهيئة
  // _ = private variable (خاص بهذا الكلاس فقط)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Collection Reference
  // الحصول على مرجع مجموعة - للوصول لمجموعة معينة في Firestore
  // path = اسم المجموعة مثل 'doctors', 'nurses', 'patients'
  // تُرجع CollectionReference يمكن استخدامه للاستعلامات
  CollectionReference collection(String path) {
    // إرجاع مرجع المجموعة
    return _firestore.collection(path);
  }

  // Create Document
  // إنشاء وثيقة جديدة - يُولد Firestore معرف تلقائي للوثيقة
  // collectionPath = مسار المجموعة مثل 'doctors'
  // data = البيانات المراد حفظها كـ Map (مثل JSON)
  // تُرجع String = معرف الوثيقة المُنشأة
  Future<String> createDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      // إضافة تاريخ الإنشاء تلقائياً - serverTimestamp() يستخدم وقت الخادم للدقة
      data['createdAt'] = FieldValue.serverTimestamp();
      // إضافة الوثيقة للمجموعة - add() يُنشئ معرف تلقائي
      // await = انتظار اكتمال العملية
      final docRef = await _firestore.collection(collectionPath).add(data);
      // إرجاع معرف الوثيقة الجديدة
      return docRef.id;
    } catch (e) {
      // معالجة الأخطاء - مثل مشاكل الشبكة أو صلاحيات Firestore
      // throw = رمي خطأ يمكن معالجته في الكود المُستدعي
      throw 'Failed to create document: $e';
    }
  }

  // Create Document with ID
  // إنشاء وثيقة بمعرف محدد - أنت تختار المعرف بدلاً من Firestore
  // collectionPath = مسار المجموعة
  // docId = المعرف الذي تريده للوثيقة
  // data = البيانات المراد حفظها
  // merge = إذا كانت true، تدمج البيانات مع الموجود، وإلا تستبدلها
  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    // معامل اختياري - merge بقيمة افتراضية false
    bool merge = false,
  }) async {
    try {
      // إضافة تاريخ الإنشاء تلقائياً
      data['createdAt'] = FieldValue.serverTimestamp();
      // تعيين الوثيقة بالمعرف المحدد
      await _firestore
          // الوصول للمجموعة
          .collection(collectionPath)
          // تحديد الوثيقة بالمعرف
          .doc(docId)
          // حفظ البيانات - set() للكتابة
          // SetOptions(merge: merge) لتحديد طريقة الكتابة
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to set document: $e';
    }
  }

  // Read Document
  // قراءة وثيقة - جلب بيانات وثيقة واحدة
  // collectionPath = مسار المجموعة
  // docId = معرف الوثيقة المراد قراءتها
  // تُرجع DocumentSnapshot يحتوي على البيانات
  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) async {
    try {
      // جلب الوثيقة من Firestore - get() للقراءة
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to get document: $e';
    }
  }

  // Update Document
  // تحديث وثيقة - تعديل حقول موجودة دون التأثير على الباقي
  // collectionPath = مسار المجموعة
  // docId = معرف الوثيقة المراد تحديثها
  // data = الحقول المراد تحديثها فقط
  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      // إضافة تاريخ التحديث تلقائياً - لتتبع آخر تعديل
      data['updatedAt'] = FieldValue.serverTimestamp();
      // تحديث الوثيقة - update() يُحدث الحقول المحددة فقط
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to update document: $e';
    }
  }

  // Delete Document
  // حذف وثيقة - حذف نهائي من قاعدة البيانات
  // collectionPath = مسار المجموعة
  // docId = معرف الوثيقة المراد حذفها
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      // حذف الوثيقة من Firestore - delete() للحذف النهائي
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to delete document: $e';
    }
  }

  // Stream Document
  // تدفق وثيقة - الاستماع للتغييرات في وثيقة واحدة في الوقت الفعلي
  // Stream = تدفق يُصدر قيمة جديدة عند كل تغيير
  // collectionPath = مسار المجموعة
  // docId = معرف الوثيقة المراد مراقبتها
  // تُرجع Stream<DocumentSnapshot> يُحدث الواجهة تلقائياً
  Stream<DocumentSnapshot> streamDocument(String collectionPath, String docId) {
    // إرجاع stream للوثيقة - snapshots() للاستماع للتغييرات
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  // Stream Collection
  // تدفق مجموعة - الاستماع للتغييرات في مجموعة كاملة في الوقت الفعلي
  // collectionPath = مسار المجموعة
  // queryBuilder = دالة اختيارية لإضافة شروط الاستعلام (where, orderBy, limit...)
  // تُرجع Stream<QuerySnapshot> يحتوي على قائمة الوثائق
  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    // معامل اختياري - دالة لبناء الاستعلام
    Query Function(Query)? queryBuilder,
  }) {
    // إنشاء استعلام أساسي للمجموعة
    Query query = _firestore.collection(collectionPath);
    // إذا كان هناك queryBuilder - تطبيق الشروط
    if (queryBuilder != null) {
      // تطبيق الدالة على الاستعلام - مثل query.where('status', isEqualTo: 'active')
      query = queryBuilder(query);
    }
    // إرجاع stream للمجموعة - يُحدث تلقائياً عند أي تغيير
    return query.snapshots();
  }

  // Query Collection
  // استعلام مجموعة - جلب بيانات مجموعة مرة واحدة (بدون استماع مستمر)
  // collectionPath = مسار المجموعة
  // queryBuilder = دالة اختيارية لإضافة شروط الاستعلام
  // تُرجع QuerySnapshot يحتوي على نتائج الاستعلام
  Future<QuerySnapshot> queryCollection(
    String collectionPath, {
    // معامل اختياري - دالة لبناء الاستعلام
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      // إنشاء استعلام أساسي
      Query query = _firestore.collection(collectionPath);
      // إذا كان هناك queryBuilder - تطبيق الشروط
      if (queryBuilder != null) {
        // تطبيق الدالة على الاستعلام
        query = queryBuilder(query);
      }
      // تنفيذ الاستعلام وإرجاع النتائج - get() للقراءة مرة واحدة
      return await query.get();
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to query collection: $e';
    }
  }

  // Get Collection Count (requires Firebase Extensions or custom aggregation)
  // احصل على عدد المجموعة - عدد الوثائق في مجموعة
  // ملاحظة: هذه الطريقة تجلب كل الوثائق للعد - غير فعالة للمجموعات الكبيرة
  // في الإنتاج، استخدم Firebase Extensions أو Cloud Functions للتجميع
  // collectionPath = مسار المجموعة
  // queryBuilder = دالة اختيارية لإضافة شروط العد
  // تُرجع int = عدد الوثائق
  Future<int> getCollectionCount(
    String collectionPath, {
    // معامل اختياري - دالة لبناء الاستعلام
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      // إنشاء استعلام أساسي
      Query query = _firestore.collection(collectionPath);
      // إذا كان هناك queryBuilder - تطبيق الشروط
      if (queryBuilder != null) {
        // تطبيق الدالة - مثل عد الأطباء النشطين فقط
        query = queryBuilder(query);
      }
      // جلب النتائج - get() للقراءة
      final snapshot = await query.get();
      // إرجاع عدد الوثائق - docs.length يعطي العدد
      return snapshot.docs.length;
    } catch (e) {
      // معالجة الأخطاء
      throw 'Failed to count documents: $e';
    }
  }

  // Batch Write
  // كتابة دفعة - تنفيذ عمليات متعددة كوحدة واحدة (كلها تنجح أو كلها تفشل)
  // مفيد لضمان تناسق البيانات عند تحديث أكثر من وثيقة
  // operations = قائمة العمليات المراد تنفيذها
  // كل عملية Map تحتوي على: type (set/update/delete), path, data
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      // إنشاء كائن batch - يجمع العمليات قبل التنفيذ
      final batch = _firestore.batch();
      // المرور على كل عملية في القائمة
      for (final op in operations) {
        // جلب نوع العملية - set أو update أو delete
        final type = op['type'] as String;
        // جلب مسار الوثيقة - مثل 'doctors/abc123'
        final path = op['path'] as String;
        // جلب البيانات - قد تكون null للعملية delete
        final data = op['data'] as Map<String, dynamic>?;

        // تحديد نوع العملية وإضافتها للـ batch
        switch (type) {
          // عملية set - إنشاء أو استبدال وثيقة
          case 'set':
            // إضافة عملية set للـ batch - لن تُنفذ الآن
            batch.set(_firestore.doc(path), data!);
            break;
          // عملية update - تحديث حقول موجودة
          case 'update':
            // إضافة عملية update للـ batch
            batch.update(_firestore.doc(path), data!);
            break;
          // عملية delete - حذف وثيقة
          case 'delete':
            // إضافة عملية delete للـ batch
            batch.delete(_firestore.doc(path));
            break;
        }
      }
      // تنفيذ جميع العمليات دفعة واحدة - commit() ينفذ كل شيء
      // إذا فشلت أي عملية، تفشل الكل (atomic operation)
      await batch.commit();
    } catch (e) {
      // معالجة الأخطاء - إذا فشل الـ batch
      throw 'Batch write failed: $e';
    }
  }
}
