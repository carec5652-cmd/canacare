// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد نموذج بيانات الممرض - لتعريف بنية بيانات الممرض
import 'package:admin_can_care/data/models/nurse_model.dart';
// استيراد مستودع الممرضين - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
// استيراد واجهة التحميل - لعرض شاشة التحميل أثناء العمليات
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Nurse Screen - شاشة إضافة ممرض
// Path: /nurses/add
// شاشة نموذج لإضافة ممرض جديد إلى النظام
class AddNurseScreen extends StatefulWidget {
  const AddNurseScreen({super.key}); // المُنشئ الثابت للشاشة

  @override
  State<AddNurseScreen> createState() => _AddNurseScreenState(); // إنشاء حالة الشاشة
}

// حالة شاشة إضافة الممرض - تدير النموذج والتفاعلات
class _AddNurseScreenState extends State<AddNurseScreen> {
  final _formKey = GlobalKey<FormState>(); // مفتاح فريد للتحقق من صحة النموذج
  final _nameController = TextEditingController(); // متحكم حقل إدخال الاسم
  final _departmentController = TextEditingController(); // متحكم حقل إدخال القسم
  final _emailController = TextEditingController(); // متحكم حقل إدخال البريد الإلكتروني
  final _phoneController = TextEditingController(); // متحكم حقل إدخال رقم الهاتف
  final _photoUrlController = TextEditingController(); // متحكم حقل إدخال رابط الصورة
  final _notesController = TextEditingController(); // متحكم حقل إدخال الملاحظات
  final _nurseRepo = NurseRepository(); // مثيل مستودع الممرضين للتفاعل مع Firestore

  bool _isLoading = false; // متغير حالة التحميل - يُستخدم لإظهار/إخفاء شاشة التحميل

  @override
  void dispose() {
    // تنظيف الموارد عند إتلاف الشاشة
    _nameController.dispose(); // تحرير ذاكرة متحكم الاسم
    _departmentController.dispose(); // تحرير ذاكرة متحكم القسم
    _emailController.dispose(); // تحرير ذاكرة متحكم البريد الإلكتروني
    _phoneController.dispose(); // تحرير ذاكرة متحكم الهاتف
    _photoUrlController.dispose(); // تحرير ذاكرة متحكم رابط الصورة
    _notesController.dispose(); // تحرير ذاكرة متحكم الملاحظات
    super.dispose(); // استدعاء dispose الخاص بالكلاس الأب
  }

  // دالة معالجة حفظ الممرض الجديد - تتحقق من صحة البيانات ثم تحفظها في Firestore
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate())
      return; // التحقق من صحة النموذج - إذا فشل، إيقاف التنفيذ

    setState(() => _isLoading = true); // تفعيل حالة التحميل لإظهار شاشة التحميل

    try {
      // إنشاء كائن NurseModel جديد من البيانات المُدخلة
      final nurse = NurseModel(
        id: '', // المعرف سيتم توليده تلقائياً من Firestore
        name: _nameController.text.trim(), // الاسم (إزالة المسافات الزائدة)
        department: _departmentController.text.trim(), // القسم (إزالة المسافات الزائدة)
        email: _emailController.text.trim(), // البريد الإلكتروني (إزالة المسافات الزائدة)
        phone:
            _phoneController.text
                    .trim()
                    .isEmpty // إذا كان الهاتف فارغاً
                ? null // تعيين null
                : _phoneController.text.trim(), // وإلا حفظ رقم الهاتف
        photoUrl:
            _photoUrlController.text
                    .trim()
                    .isEmpty // إذا كان رابط الصورة فارغاً
                ? null // تعيين null
                : _photoUrlController.text.trim(), // وإلا حفظ رابط الصورة
        notes:
            _notesController.text
                    .trim()
                    .isEmpty // إذا كانت الملاحظات فارغة
                ? null // تعيين null
                : _notesController.text.trim(), // وإلا حفظ الملاحظات
        status: 'active', // الحالة الافتراضية للممرض الجديد: نشط
        createdAt: DateTime.now(), // تاريخ ووقت الإنشاء الحالي
      );

      await _nurseRepo.createNurse(nurse); // حفظ الممرض الجديد في Firestore

      if (mounted) {
        // التحقق من أن الشاشة لا تزال موجودة في الذاكرة
        ScaffoldMessenger.of(context).showSnackBar(
          // عرض رسالة نجاح
          SnackBar(
            content: Text(
              // محتوى الرسالة
              Directionality.of(context) ==
                      TextDirection
                          .rtl // تحديد اللغة حسب اتجاه النص
                  ? 'تم إضافة الممرض بنجاح' // رسالة بالعربية
                  : 'Nurse added successfully', // رسالة بالإنجليزية
            ),
            backgroundColor: Colors.green, // خلفية خضراء للنجاح
          ),
        );
        Navigator.pop(context); // العودة للشاشة السابقة
      }
    } catch (e) {
      // في حالة حدوث خطأ
      if (mounted) {
        // التحقق من أن الشاشة لا تزال موجودة
        setState(() => _isLoading = false); // إيقاف حالة التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          // عرض رسالة خطأ
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ), // رسالة خطأ بخلفية حمراء
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL =
        Directionality.of(context) ==
        TextDirection.rtl; // تحديد ما إذا كانت اللغة من اليمين لليسار (RTL)

    return Scaffold(
      // الهيكل الأساسي للشاشة
      appBar: AppBar(
        // شريط التطبيق العلوي
        title: Text(isRTL ? 'إضافة ممرض' : 'Add Nurse'), // عنوان الشاشة حسب اللغة
      ),
      body: LoadingOverlay(
        // واجهة التحميل التي تغطي الشاشة أثناء الحفظ
        isLoading: _isLoading, // حالة التحميل
        message: 'Saving...', // رسالة التحميل بالإنجليزية
        messageAr: 'جاري الحفظ...', // رسالة التحميل بالعربية
        child: SingleChildScrollView(
          // لجعل المحتوى قابلاً للتمرير
          padding: const EdgeInsets.all(16), // مسافة داخلية 16 بكسل من جميع الجوانب
          child: Form(
            // نموذج يحتوي على حقول الإدخال مع التحقق من الصحة
            key: _formKey, // مفتاح النموذج للتحقق من الصحة
            child: Column(
              // عمود يحتوي على جميع حقول الإدخال
              crossAxisAlignment: CrossAxisAlignment.stretch, // جعل جميع العناصر تمتد بعرض الشاشة
              children: [
                TextFormField(
                  // حقل إدخال نصي مع التحقق من الصحة
                  controller: _nameController, // المتحكم في النص المُدخل
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText:
                        '${isRTL ? 'الاسم' : 'Name'} *', // تسمية الحقل مع علامة * للإشارة إلى أنه إلزامي
                    prefixIcon: const Icon(Icons.person), // أيقونة شخص في بداية الحقل
                  ),
                  validator:
                      (v) =>
                          v == null ||
                                  v
                                      .isEmpty // دالة التحقق من صحة الإدخال
                              ? (isRTL
                                  ? 'الاسم مطلوب'
                                  : 'Name is required') // رسالة خطأ إذا كان الحقل فارغاً
                              : null, // إذا كان الحقل صحيحاً، إرجاع null
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال القسم
                  controller: _departmentController, // المتحكم في النص المُدخل
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: '${isRTL ? 'القسم' : 'Department'} *', // تسمية الحقل (إلزامي)
                    prefixIcon: const Icon(Icons.local_hospital), // أيقونة مستشفى
                  ),
                  validator:
                      (v) =>
                          v == null ||
                                  v
                                      .isEmpty // دالة التحقق من صحة الإدخال
                              ? (isRTL
                                  ? 'القسم مطلوب'
                                  : 'Department is required') // رسالة خطأ إذا كان الحقل فارغاً
                              : null, // إذا كان الحقل صحيحاً، إرجاع null
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال البريد الإلكتروني
                  controller: _emailController, // المتحكم في النص المُدخل
                  keyboardType: TextInputType.emailAddress, // نوع لوحة المفاتيح: بريد إلكتروني
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: '${isRTL ? 'البريد الإلكتروني' : 'Email'} *', // تسمية الحقل (إلزامي)
                    prefixIcon: const Icon(Icons.email), // أيقونة بريد إلكتروني
                  ),
                  validator: (v) {
                    // دالة مخصصة للتحقق من صحة البريد الإلكتروني
                    if (v == null || v.isEmpty) {
                      // إذا كان الحقل فارغاً
                      return isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required'; // رسالة خطأ
                    }
                    if (!v.contains('@'))
                      return isRTL
                          ? 'بريد غير صالح'
                          : 'Invalid email'; // رسالة خطأ إذا لم يحتوي على @
                    return null; // إذا كان الحقل صحيحاً، إرجاع null
                  },
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال رقم الهاتف (اختياري)
                  controller: _phoneController, // المتحكم في النص المُدخل
                  keyboardType: TextInputType.phone, // نوع لوحة المفاتيح: هاتف
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText:
                        isRTL ? 'الهاتف (اختياري)' : 'Phone (Optional)', // تسمية الحقل (اختياري)
                    prefixIcon: const Icon(Icons.phone), // أيقونة هاتف
                  ),
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال رابط الصورة (اختياري)
                  controller: _photoUrlController, // المتحكم في النص المُدخل
                  keyboardType: TextInputType.url, // نوع لوحة المفاتيح: رابط URL
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText:
                        isRTL
                            ? 'رابط الصورة (اختياري)'
                            : 'Photo URL (Optional)', // تسمية الحقل (اختياري)
                    prefixIcon: const Icon(Icons.image), // أيقونة صورة
                  ),
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال الملاحظات (اختياري)
                  controller: _notesController, // المتحكم في النص المُدخل
                  maxLines: 3, // عدد الأسطر القصوى: 3 (حقل متعدد الأسطر)
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText:
                        isRTL ? 'ملاحظات (اختياري)' : 'Notes (Optional)', // تسمية الحقل (اختياري)
                    prefixIcon: const Icon(Icons.note), // أيقونة ملاحظة
                    alignLabelWithHint: true, // محاذاة التسمية مع التلميح (للحقول متعددة الأسطر)
                  ),
                ),
                const SizedBox(height: 24), // مسافة عمودية 24 بكسل
                Row(
                  // صف يحتوي على زرين (إلغاء وحفظ)
                  children: [
                    Expanded(
                      // جعل الزر يملأ نصف المساحة المتاحة
                      child: OutlinedButton(
                        // زر بإطار (إلغاء)
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.pop(
                                  context,
                                ), // عند الضغط: العودة للشاشة السابقة (يُعطل أثناء التحميل)
                        style: OutlinedButton.styleFrom(
                          // أسلوب الزر
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // مسافة داخلية عمودية 16 بكسل
                        ),
                        child: Text(isRTL ? 'إلغاء' : 'Cancel'), // نص الزر حسب اللغة
                      ),
                    ),
                    const SizedBox(width: 16), // مسافة أفقية 16 بكسل بين الزرين
                    Expanded(
                      // جعل الزر يملأ نصف المساحة المتاحة
                      child: ElevatedButton(
                        // زر مرتفع ملون (حفظ)
                        onPressed:
                            _isLoading
                                ? null
                                : _handleSave, // عند الضغط: حفظ البيانات (يُعطل أثناء التحميل)
                        style: ElevatedButton.styleFrom(
                          // أسلوب الزر
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // مسافة داخلية عمودية 16 بكسل
                        ),
                        child: Text(isRTL ? 'حفظ' : 'Save'), // نص الزر حسب اللغة
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
