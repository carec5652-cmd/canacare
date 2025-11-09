// استيراد مكتبة Cloud Functions - للاتصال بوظائف السحابة في Firebase
import 'package:cloud_functions/cloud_functions.dart';
// استيراد flutter/foundation - للوصول لـ debugPrint للطباعة في Console
import 'package:flutter/foundation.dart';

// Cloud Functions Service for Web-compatible Notifications
// خدمة Cloud Functions لإشعارات متوافقة مع الويب
// تُستخدم لإرسال الإشعارات من تطبيق الويب لأن FCM API لا يعمل على الويب بسبب CORS
// CORS = Cross-Origin Resource Sharing - قيود أمنية في المتصفحات
class CloudFunctionsService {
  // Singleton Pattern - نمط الكائن الوحيد
  // يضمن وجود كائن واحد فقط من هذا الكلاس في التطبيق
  // _instance = الكائن الوحيد - private static
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();
  // factory constructor - يُرجع نفس الكائن دائماً بدلاً من إنشاء جديد
  factory CloudFunctionsService() => _instance;
  // private constructor - لا يمكن إنشاء كائنات من خارج هذا الكلاس
  CloudFunctionsService._internal();

  // كائن Firebase Functions - للوصول لوظائف السحابة
  // final = لا يمكن تغييره بعد التهيئة
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Send notification to all users via Cloud Function
  // إرسال إشعار لجميع المستخدمين عبر Cloud Function
  // هذه الدالة تستدعي Cloud Function في الخادم، الذي بدوره يُرسل الإشعار
  // title = عنوان الإشعار
  // body = نص الإشعار
  // تُرجع bool = true إذا نجح الإرسال، false إذا فشل
  Future<bool> sendNotificationToAll({
    // معامل إلزامي - عنوان الإشعار
    required String title,
    // معامل إلزامي - نص الإشعار
    required String body,
  }) async {
    try {
      // طباعة رسالة تشخيصية - لتتبع عملية الإرسال
      debugPrint('📤 Sending to Cloud Function:');
      // طباعة العنوان مع علامات التنصيص لرؤية المسافات
      debugPrint('   Title: "$title"');
      // طباعة النص
      debugPrint('   Body: "$body"');
      // طباعة طول العنوان - للتحقق من عدم إرسال نص فارغ
      debugPrint('   Title length: ${title.length}');
      // طباعة طول النص
      debugPrint('   Body length: ${body.length}');

      // إنشاء مرجع للـ Cloud Function - 'sendNotificationToAll' هو اسم الوظيفة
      // httpsCallable = وظيفة قابلة للاستدعاء عبر HTTPS
      final callable = _functions.httpsCallable('sendNotificationToAll');

      // تجهيز البيانات المُرسلة - Map مثل JSON
      final data = {
        // مفتاح 'title' بقيمة العنوان
        'title': title,
        // مفتاح 'body' بقيمة النص
        'body': body,
      };
      // طباعة البيانات للتأكد من صحتها
      debugPrint('   Data map: $data');

      // استدعاء Cloud Function - call() تُرسل البيانات وتنتظر الرد
      // await = انتظار اكتمال العملية قبل المتابعة
      final result = await callable.call(data);

      // طباعة رد Cloud Function - للتحقق من النجاح
      debugPrint('✅ Cloud Function response: ${result.data}');
      // إرجاع حالة النجاح من رد Cloud Function
      // result.data['success'] قد يكون null، استخدم ?? false كقيمة افتراضية
      return result.data['success'] ?? false;
    } catch (e) {
      // معالجة الأخطاء - مثل مشاكل الشبكة أو Cloud Function معطلة
      debugPrint('❌ Error calling cloud function: $e');
      // طباعة نوع الخطأ - مفيد للتشخيص
      debugPrint('   Error type: ${e.runtimeType}');
      // إرجاع false عند حدوث خطأ - فشل الإرسال
      return false;
    }
  }

  // Send notification by role via Cloud Function
  // إرسال إشعار حسب الدور عبر Cloud Function
  // يُرسل للمستخدمين من دور معين فقط - doctors أو nurses أو patients
  // role = الدور المستهدف ('doctors', 'nurses', 'patients')
  // title = عنوان الإشعار
  // body = نص الإشعار
  // تُرجع bool = true إذا نجح، false إذا فشل
  Future<bool> sendNotificationByRole({
    // معامل إلزامي - الدور المستهدف
    required String role,
    // معامل إلزامي - عنوان الإشعار
    required String title,
    // معامل إلزامي - نص الإشعار
    required String body,
  }) async {
    try {
      // طباعة رسائل تشخيصية - لتتبع عملية الإرسال
      debugPrint('📤 Sending to Cloud Function (by role):');
      // طباعة الدور المستهدف
      debugPrint('   Role: "$role"');
      // طباعة العنوان
      debugPrint('   Title: "$title"');
      // طباعة النص
      debugPrint('   Body: "$body"');
      // طباعة أطوال النصوص - للتحقق
      debugPrint('   Title length: ${title.length}');
      debugPrint('   Body length: ${body.length}');

      // إنشاء مرجع للـ Cloud Function - 'sendNotificationByRole' اسم الوظيفة
      final callable = _functions.httpsCallable('sendNotificationByRole');

      // تجهيز البيانات المُرسلة - تحتوي على الدور والعنوان والنص
      final data = {
        // الدور المستهدف - يجب أن يكون أحد: 'doctors', 'nurses', 'patients'
        'role': role,
        // عنوان الإشعار
        'title': title,
        // نص الإشعار
        'body': body,
      };
      // طباعة البيانات للتأكد
      debugPrint('   Data map: $data');

      // استدعاء Cloud Function - إرسال البيانات وانتظار الرد
      final result = await callable.call(data);

      // طباعة رد Cloud Function - للتحقق من النجاح
      debugPrint('✅ Cloud Function response: ${result.data}');
      // إرجاع حالة النجاح - ?? false كقيمة افتراضية إذا كانت null
      return result.data['success'] ?? false;
    } catch (e) {
      // معالجة الأخطاء - طباعة تفاصيل الخطأ
      debugPrint('❌ Error calling cloud function: $e');
      // طباعة نوع الخطأ
      debugPrint('   Error type: ${e.runtimeType}');
      // إرجاع false عند الفشل
      return false;
    }
  }
}
