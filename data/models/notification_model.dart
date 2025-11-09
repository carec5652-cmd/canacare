// Notification Model
// نموذج بيانات الإشعارات - يمثل هيكل الإشعار Push Notification
// يُستخدم لإرسال رسائل فورية لجميع المستخدمين أو مجموعات محددة
class NotificationModel {
  // معرف الإشعار الفريد - ID من Firestore
  final String id;
  
  // عنوان الإشعار - يظهر كعنوان رئيسي في الرسالة المنبثقة
  final String title;
  
  // نص الإشعار - المحتوى التفصيلي للرسالة
  final String body;
  
  // الجمهور المستهدف - من سيستقبل الإشعار
  // 'all' = الجميع (كل المستخدمين)
  // 'doctors' = الأطباء فقط
  // 'nurses' = الممرضين فقط
  // 'patients' = المرضى فقط
  // 'custom' = مستخدمين محددين بالمعرفات
  final String targetAudience; // 'all', 'doctors', 'nurses', 'patients', 'custom'
  
  // قائمة معرفات المستخدمين المستهدفين - للإرسال المخصص
  // For custom targeting - فقط عند targetAudience = 'custom'
  // اختياري - يمكن أن يكون null
  final List<String>? targetUserIds;
  
  // رابط صورة اختيارية - لإضافة صورة للإشعار
  // اختياري - معظم الإشعارات بدون صورة
  final String? imageUrl;
  
  // وقت الجدولة - لإرسال الإشعار في وقت محدد مستقبلاً
  // اختياري - null يعني إرسال فوري
  final DateTime? scheduledAt;
  
  // تاريخ إنشاء الإشعار - متى تم إنشاؤه في النظام
  final DateTime createdAt;
  
  // معرف المشرف المُنشئ - من أنشأ هذا الإشعار (Admin ID)
  final String createdBy;
  
  // حالة الإشعار - تتبع حالة الإرسال
  // 'pending' = قيد الانتظار (لم يُرسل بعد)
  // 'sent' = تم الإرسال بنجاح
  // 'failed' = فشل الإرسال
  final String status; // 'pending', 'sent', 'failed'

  // المُنشئ - Constructor لإنشاء كائن NotificationModel
  NotificationModel({
    // معرف الإشعار - مطلوب
    required this.id,
    // العنوان - مطلوب
    required this.title,
    // النص - مطلوب
    required this.body,
    // الجمهور المستهدف - مطلوب
    required this.targetAudience,
    // قائمة المستخدمين المخصصة - اختياري
    this.targetUserIds,
    // رابط الصورة - اختياري
    this.imageUrl,
    // وقت الجدولة - اختياري
    this.scheduledAt,
    // تاريخ الإنشاء - مطلوب
    required this.createdAt,
    // معرف المُنشئ - مطلوب
    required this.createdBy,
    // الحالة - افتراضياً 'pending' إذا لم يُحدد
    this.status = 'pending',
  });

  // From Firestore
  // إنشاء كائن NotificationModel من بيانات Firestore
  // تحويل Map (JSON-like) إلى Object
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      // معرف الوثيقة من Firestore
      id: id,
      // العنوان - قيمة افتراضية فارغة إذا كان null
      title: map['title'] ?? '',
      // النص - قيمة افتراضية فارغة
      body: map['body'] ?? '',
      // الجمهور المستهدف - افتراضياً 'all' (الجميع)
      targetAudience: map['targetAudience'] ?? 'all',
      // قائمة المستخدمين - تحويل من dynamic إلى List<String>
      // List.from() لإنشاء قائمة من البيانات الديناميكية
      targetUserIds: map['targetUserIds'] != null ? List<String>.from(map['targetUserIds']) : null,
      // رابط الصورة - يمكن أن يكون null
      imageUrl: map['imageUrl'],
      // وقت الجدولة - تحويل Timestamp من Firestore إلى DateTime
      // ?.toDate() تنفذ فقط إذا لم يكن null (safe navigation)
      scheduledAt: map['scheduledAt']?.toDate(),
      // تاريخ الإنشاء - تحويل Timestamp أو استخدام الوقت الحالي
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      // معرف المُنشئ - قيمة افتراضية فارغة
      createdBy: map['createdBy'] ?? '',
      // الحالة - افتراضياً 'pending'
      status: map['status'] ?? 'pending',
    );
  }

  // To Firestore
  // تحويل كائن NotificationModel إلى Map لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      // اسم الحقل في Firestore: القيمة من الكائن
      'title': title,
      'body': body,
      'targetAudience': targetAudience,
      'targetUserIds': targetUserIds,
      'imageUrl': imageUrl,
      'scheduledAt': scheduledAt,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'status': status,
    };
  }
}
