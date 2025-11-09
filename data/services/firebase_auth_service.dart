// تجاهل تحذير استخدام print - نستخدمها للتشخيص والتطوير
// ignore directive to allow print statements for debugging
// ignore_for_file: avoid_print

// استيراد خدمة Firebase Auth - للتعامل مع تسجيل الدخول والخروج
import 'package:firebase_auth/firebase_auth.dart';
// استيراد Cloud Firestore - لقاعدة البيانات السحابية
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Authentication Service
// خدمة مصادقة Firebase - تحتوي على جميع عمليات المصادقة
// تتعامل مع: تسجيل الدخول، الخروج، التحقق من الصلاحيات، إعادة تعيين كلمة المرور
class FirebaseAuthService {
  // كائن Firebase Auth - للوصول لخدمة المصادقة
  // final = لا يمكن تغييره بعد التهيئة
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // كائن Firestore - للوصول لقاعدة البيانات
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current User
  // المستخدم الحالي - getter يُرجع المستخدم المسجل حالياً أو null
  // يمكن الوصول له من أي مكان عبر: FirebaseAuthService().currentUser
  User? get currentUser => _auth.currentUser;

  // Auth State Changes Stream
  // تدفق تغييرات حالة المصادقة - stream يُصدر قيمة جديدة عند كل تسجيل دخول/خروج
  // يمكن الاستماع له لتحديث الواجهة تلقائياً
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In with Email & Password
  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور - الطريقة الأساسية للمشرفين
  // تُرجع UserCredential يحتوي على بيانات المستخدم بعد تسجيل الدخول
  Future<UserCredential> signInWithEmailAndPassword({
    // البريد الإلكتروني - مطلوب (required)
    required String email,
    // كلمة المرور - مطلوبة (required)
    required String password,
  }) async {
    try {
      // محاولة تسجيل الدخول باستخدام Firebase Auth
      // await = انتظار النتيجة قبل المتابعة
      final userCredential = await _auth.signInWithEmailAndPassword(
        // البريد الإلكتروني المدخل
        email: email,
        // كلمة المرور المدخلة
        password: password,
      );

      // Update last login
      // تحديث وقت آخر تسجيل دخول - في قاعدة بيانات Firestore
      // إذا كان هناك مستخدم (تسجيل الدخول نجح)
      if (userCredential.user != null) {
        // تحديث وثيقة المشرف في مجموعة admins
        await _firestore.collection('admins').doc(userCredential.user!.uid).set({
          // حفظ وقت الخادم الحالي - serverTimestamp() للدقة وتجنب فروق التوقيت
          'lastLogin': FieldValue.serverTimestamp(),
          // SetOptions(merge: true) = دمج البيانات مع الموجود بدلاً من الاستبدال
        }, SetOptions(merge: true));
      }

      // إرجاع بيانات المستخدم - للاستخدام في الكود المُستدعي
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // معالجة أخطاء Firebase Auth - مثل بريد خاطئ أو كلمة مرور خاطئة
      // رمي خطأ مُعالج برسالة واضحة بالعربية والإنجليزية
      throw _handleAuthException(e);
    }
  }

  // Check if user is admin
  // التحقق من أن المستخدم مشرف - يتحقق من وجود وثيقة في مجموعة admins
  // uid = معرف المستخدم الفريد من Firebase Auth
  // تُرجع true إذا كان مشرفاً، false إذا لم يكن
  Future<bool> isAdmin(String uid) async {
    try {
      // جلب وثيقة المشرف من Firestore - await للانتظار
      final doc = await _firestore.collection('admins').doc(uid).get();
      // التحقق من وجود الوثيقة - إذا لم توجد، المستخدم ليس مشرفاً
      if (!doc.exists) {
        // طباعة رسالة للمطورين - الوثيقة غير موجودة
        print('Admin document not found for UID: $uid');
        // إرجاع false - ليس مشرفاً
        return false;
      }
      // جلب حقل role من الوثيقة - يحدد نوع المشرف
      final role = doc.data()?['role'];
      // طباعة الدور للتشخيص
      print('User role: $role');
      // إرجاع true إذا كان الدور admin أو superadmin
      // || = أو المنطقية (OR)
      return role == 'admin' || role == 'superadmin';
    } catch (e) {
      // معالجة الأخطاء - مثل مشاكل الشبكة أو صلاحيات Firestore
      print('Error checking admin role: $e');
      // إرجاع false عند حدوث خطأ - للأمان (deny by default)
      return false;
    }
  }

  // Sign In Anonymously (Guest)
  // تسجيل الدخول كضيف - بدون حساب أو كلمة مرور
  // يُنشئ حساب مؤقت يُحذف عند تسجيل الخروج
  Future<UserCredential> signInAnonymously() async {
    try {
      // تسجيل الدخول كضيف باستخدام Firebase Anonymous Auth
      // إرجاع النتيجة مباشرة
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      // معالجة أخطاء Firebase Auth
      throw _handleAuthException(e);
    }
  }

  // Send Password Reset Email
  // إرسال بريد إعادة تعيين كلمة المرور - للمستخدمين الذين نسوا كلمة المرور
  // يُرسل Firebase رابط إلى البريد الإلكتروني لإعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // إرسال بريد إعادة التعيين - Firebase يتولى كل شيء
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // معالجة الأخطاء - مثل بريد غير موجود
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  // تسجيل الخروج - إنهاء الجلسة الحالية
  // يمسح بيانات المستخدم المحلية ويُعيد للصفحة الرئيسية
  Future<void> signOut() async {
    // تسجيل الخروج - Firebase يتولى مسح الجلسة
    await _auth.signOut();
  }

  // Update Password
  // تحديث كلمة المرور - للمستخدم الحالي المسجل دخوله
  // يتطلب أن يكون المستخدم قد سجل دخوله مؤخراً (re-authentication قد يكون مطلوب)
  Future<void> updatePassword(String newPassword) async {
    try {
      // تحديث كلمة المرور للمستخدم الحالي
      // ?. = safe navigation - ينفذ فقط إذا كان currentUser ليس null
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      // معالجة الأخطاء - مثل كلمة مرور ضعيفة أو يتطلب إعادة مصادقة
      throw _handleAuthException(e);
    }
  }

  // Handle Auth Exceptions
  // معالجة أخطاء المصادقة - تحويل أكواد الأخطاء إلى رسائل واضحة
  // دالة خاصة (private) - تُستخدم داخل هذا الكلاس فقط
  // _ = underscore يعني private في Dart
  String _handleAuthException(FirebaseAuthException e) {
    // switch على كود الخطأ - لإرجاع رسالة مناسبة
    switch (e.code) {
      // المستخدم غير موجود - البريد الإلكتروني غير مسجل
      case 'user-not-found':
        return 'No user found with this email. / لم يتم العثور على مستخدم بهذا البريد.';
      // كلمة المرور خاطئة
      case 'wrong-password':
        return 'Wrong password. / كلمة المرور غير صحيحة.';
      // تنسيق البريد الإلكتروني غير صالح - مثل عدم وجود @
      case 'invalid-email':
        return 'Invalid email format. / تنسيق البريد الإلكتروني غير صالح.';
      // الحساب معطل - تم تعطيله من قبل المشرفين
      case 'user-disabled':
        return 'This account has been disabled. / تم تعطيل هذا الحساب.';
      // محاولات كثيرة جداً - Firebase يحظر مؤقتاً لمنع الهجمات
      case 'too-many-requests':
        return 'Too many attempts. Try again later. / محاولات كثيرة جداً. حاول مرة أخرى لاحقاً.';
      // كلمة المرور ضعيفة - أقل من 6 أحرف
      case 'weak-password':
        return 'Password should be at least 6 characters. / يجب أن تكون كلمة المرور 6 أحرف على الأقل.';
      // البريد الإلكتروني مستخدم بالفعل - عند إنشاء حساب جديد
      case 'email-already-in-use':
        return 'Email already in use. / البريد الإلكتروني مستخدم بالفعل.';
      // خطأ غير معروف - عرض رسالة Firebase الافتراضية
      default:
        // ?? = null coalescing operator - يستخدم القيمة اليمنى إذا كانت اليسرى null
        return e.message ?? 'Authentication error. / خطأ في المصادقة.';
    }
  }
}
