// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد خدمة المصادقة من Firebase - للحصول على المستخدم الحالي
import 'package:firebase_auth/firebase_auth.dart';
// استيراد نموذج الإشعار - لإنشاء كائن الإشعار
import 'package:admin_can_care/data/models/notification_model.dart';
// استيراد مستودع الإشعارات - لحفظ وإرسال الإشعارات
import 'package:admin_can_care/data/repositories/notification_repository.dart';
// استيراد عنصر شاشة التحميل - لإظهار حالة الإرسال
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Create Notification Screen - شاشة إنشاء إشعار جديد
// تسمح للمشرف بإرسال إشعارات للمستخدمين
class CreateNotificationScreen extends StatefulWidget {
  // المُنشئ - يستقبل مفتاح اختياري
  const CreateNotificationScreen({super.key});

  @override
  // إنشاء الحالة المتغيرة للصفحة - للتحكم في البيانات
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

// الحالة الخاصة بشاشة إنشاء الإشعار - تحتوي على المنطق والبيانات
class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  // مفتاح النموذج - للتحقق من صحة البيانات المدخلة
  final _formKey = GlobalKey<FormState>();
  // متحكم حقل العنوان - للوصول إلى النص المدخل
  final _titleController = TextEditingController();
  // متحكم حقل النص - للوصول إلى محتوى الإشعار
  final _bodyController = TextEditingController();
  // كائن مستودع الإشعارات - للتعامل مع Firebase
  final _repo = NotificationRepository();

  // الجمهور المستهدف - القيمة الافتراضية "all" (الجميع)
  String _targetAudience = 'all';
  // حالة التحميل - false = جاهز، true = جاري الإرسال
  bool _isLoading = false;

  // دالة معالجة الإرسال - تُنفذ عند الضغط على زر "إرسال"
  Future<void> _handleSend() async {
    // التحقق من صحة البيانات - إذا فشلت التحققات، لا تكمل
    if (!_formKey.currentState!.validate()) return;

    // تحديث حالة التحميل إلى true - لإظهار شاشة التحميل
    setState(() => _isLoading = true);

    try {
      // الحصول على بيانات المستخدم الحالي من Firebase Auth
      final user = FirebaseAuth.instance.currentUser!;
      // إنشاء كائن الإشعار الجديد مع البيانات المدخلة
      final notification = NotificationModel(
        // معرف فارغ - سيتم إنشاؤه تلقائياً بواسطة Firestore
        id: '',
        // العنوان - من حقل الإدخال، مع إزالة المسافات الزائدة
        title: _titleController.text.trim(),
        // النص - من حقل الإدخال، مع إزالة المسافات الزائدة
        body: _bodyController.text.trim(),
        // الجمهور المستهدف - المحدد من القائمة المنسدلة
        targetAudience: _targetAudience,
        // تاريخ الإنشاء - الوقت الحالي
        createdAt: DateTime.now(),
        // معرف المُنشئ - معرف المستخدم الحالي
        createdBy: user.uid,
        // الحالة - "sent" (تم الإرسال)
        status: 'sent',
      );

      // حفظ الإشعار في Firestore وإرساله عبر FCM
      await _repo.createNotification(notification);

      // التحقق من أن الصفحة لا تزال موجودة على الشاشة
      if (mounted) {
        // إظهار رسالة نجاح أسفل الشاشة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // محتوى الرسالة - يتغير حسب اللغة
            content: Text(
              Directionality.of(context) == TextDirection.rtl
                  ? 'تم إرسال الإشعار بنجاح'
                  : 'Notification sent successfully',
            ),
            // لون الخلفية - أخضر للنجاح
            backgroundColor: Colors.green,
          ),
        );
        // الرجوع إلى الصفحة السابقة - بعد الإرسال بنجاح
        Navigator.pop(context);
      }
    } catch (e) {
      // في حالة حدوث خطأ أثناء الإرسال
      // التحقق من أن الصفحة لا تزال موجودة
      if (mounted) {
        // إيقاف حالة التحميل - للسماح بالمحاولة مرة أخرى
        setState(() => _isLoading = false);
        // إظهار رسالة خطأ أسفل الشاشة
        ScaffoldMessenger.of(context).showSnackBar(
          // محتوى الرسالة - عرض نص الخطأ
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  // دالة بناء الواجهة - تُستدعى لرسم الصفحة على الشاشة
  Widget build(BuildContext context) {
    // التحقق من اتجاه النص - true = عربي، false = إنجليزي
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // إرجاع هيكل الصفحة الأساسي
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(
        // عنوان الصفحة - يتغير حسب اللغة
        title: Text(isRTL ? 'إنشاء إشعار' : 'Create Notification'),
      ),
      // محتوى الصفحة مع طبقة التحميل
      body: LoadingOverlay(
        // حالة التحميل - لإظهار/إخفاء شاشة التحميل
        isLoading: _isLoading,
        // محتوى الصفحة القابل للتمرير
        child: SingleChildScrollView(
          // حشوة داخلية 16 بكسل من كل الجوانب
          padding: const EdgeInsets.all(16),
          // نموذج إدخال البيانات مع التحقق
          child: Form(
            // مفتاح النموذج - للتحقق من صحة البيانات
            key: _formKey,
            // عمود رأسي - لترتيب الحقول فوق بعضها
            child: Column(
              // محاذاة العناصر للعرض الكامل
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // قائمة عناصر النموذج
              children: [
                // حقل إدخال العنوان - TextFormField مع التحقق
                TextFormField(
                  // ربط المتحكم للوصول إلى القيمة
                  controller: _titleController,
                  // تزيين الحقل
                  decoration: InputDecoration(
                    // تسمية الحقل - تتغير حسب اللغة، * = إلزامي
                    labelText: '${isRTL ? 'العنوان' : 'Title'} *',
                    // أيقونة على يسار الحقل
                    prefixIcon: const Icon(Icons.title),
                  ),
                  // دالة التحقق - تُنفذ عند الضغط على إرسال
                  // v = القيمة المدخلة، تُرجع null إذا صحيحة أو نص الخطأ
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? (isRTL ? 'العنوان مطلوب' : 'Title is required')
                              : null,
                ),
                // مسافة فارغة بارتفاع 16 بكسل - بين الحقول
                const SizedBox(height: 16),
                // حقل إدخال نص الإشعار - متعدد الأسطر
                TextFormField(
                  // ربط المتحكم للوصول إلى القيمة
                  controller: _bodyController,
                  // عدد الأسطر - 4 أسطر قابلة للتوسع
                  maxLines: 4,
                  // تزيين الحقل
                  decoration: InputDecoration(
                    // تسمية الحقل - تتغير حسب اللغة
                    labelText: '${isRTL ? 'الرسالة' : 'Message'} *',
                    // محاذاة التسمية مع الحقل - للحقول متعددة الأسطر
                    alignLabelWithHint: true,
                  ),
                  // دالة التحقق - للتأكد من إدخال النص
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? (isRTL ? 'الرسالة مطلوبة' : 'Message is required')
                              : null,
                ),
                // مسافة فارغة بارتفاع 16 بكسل
                const SizedBox(height: 16),
                // قائمة منسدلة لاختيار الجمهور المستهدف
                DropdownButtonFormField<String>(
                  // القيمة الحالية المختارة
                  value: _targetAudience,
                  // تزيين القائمة
                  decoration: InputDecoration(
                    // تسمية القائمة - تتغير حسب اللغة
                    labelText: isRTL ? 'الجمهور المستهدف' : 'Target Audience',
                  ),
                  // قائمة الخيارات المتاحة
                  items: [
                    // خيار "الجميع"
                    DropdownMenuItem(value: 'all', child: Text(isRTL ? 'الجميع' : 'All')),
                    // خيار "الأطباء"
                    DropdownMenuItem(value: 'doctors', child: Text(isRTL ? 'الأطباء' : 'Doctors')),
                    // خيار "الممرضين"
                    DropdownMenuItem(value: 'nurses', child: Text(isRTL ? 'الممرضين' : 'Nurses')),
                    // خيار "المرضى"
                    DropdownMenuItem(value: 'patients', child: Text(isRTL ? 'المرضى' : 'Patients')),
                  ],
                  // عند تغيير الاختيار - تحديث القيمة وإعادة رسم الواجهة
                  onChanged: (v) => setState(() => _targetAudience = v!),
                ),
                // مسافة فارغة بارتفاع 24 بكسل - قبل الزر
                const SizedBox(height: 24),
                // زر الإرسال
                ElevatedButton(
                  // تعطيل الزر أثناء التحميل - لمنع الإرسال المتكرر
                  onPressed: _isLoading ? null : _handleSend,
                  // تنسيق الزر
                  style: ElevatedButton.styleFrom(
                    // حشوة داخلية عمودية 16 بكسل - لزر أكبر
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  // نص الزر - يتغير حسب اللغة
                  child: Text(isRTL ? 'إرسال الآن' : 'Send Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
