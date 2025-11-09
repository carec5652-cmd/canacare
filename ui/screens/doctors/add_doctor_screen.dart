// تجاهل تحذير المتغير المحلي غير المستخدم - للتطوير
// ignore_for_file: unused_local_variable

// استيراد مكتبة Material Design - لعناصر الواجهة
import 'package:flutter/material.dart';
// استيراد نموذج بيانات الطبيب - لإنشاء كائن طبيب جديد
import 'package:admin_can_care/data/models/doctor_model.dart';
// استيراد مستودع الأطباء - لحفظ الطبيب في Firestore
import 'package:admin_can_care/data/repositories/doctor_repository.dart';
// استيراد عنصر طبقة التحميل - لإظهار حالة الحفظ
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Doctor Screen - شاشة إضافة طبيب جديد
// نموذج إدخال بيانات طبيب وحفظه في قاعدة البيانات
// Path: /doctors/add - يتم الوصول لها من زر "+ إضافة طبيب"
class AddDoctorScreen extends StatefulWidget {
  // المُنشئ - const للأداء
  const AddDoctorScreen({super.key});

  @override
  // إنشاء الحالة المتغيرة - للتحكم في النموذج وحالة الحفظ
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

// الحالة الخاصة بشاشة إضافة طبيب
class _AddDoctorScreenState extends State<AddDoctorScreen> {
  // مفتاح النموذج - للتحقق من صحة جميع الحقول دفعة واحدة
  final _formKey = GlobalKey<FormState>();
  // متحكم حقل الاسم - للوصول إلى النص المدخل
  final _nameController = TextEditingController();
  // متحكم حقل التخصص - مثل "القلب", "الأطفال"
  final _specialtyController = TextEditingController();
  // متحكم حقل البريد الإلكتروني - للتواصل
  final _emailController = TextEditingController();
  // متحكم حقل الهاتف - اختياري
  final _phoneController = TextEditingController();
  // متحكم حقل رابط الصورة - URL الصورة الشخصية
  final _photoUrlController = TextEditingController();
  // متحكم حقل الملاحظات - معلومات إضافية اختيارية
  final _notesController = TextEditingController();
  // كائن مستودع الأطباء - للتعامل مع Firestore
  final _doctorRepo = DoctorRepository();

  // حالة التحميل - true أثناء الحفظ
  bool _isLoading = false;

  @override
  // دالة التنظيف - تُنفذ عند إغلاق الصفحة لتحرير الذاكرة
  void dispose() {
    // تحرير موارد جميع المتحكمات - ضروري لمنع تسرب الذاكرة
    _nameController.dispose();
    _specialtyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _notesController.dispose();
    // استدعاء dispose الأساسية
    super.dispose();
  }

  // دالة معالجة الحفظ - تُنفذ عند الضغط على زر "حفظ"
  Future<void> _handleSave() async {
    // التحقق من صحة جميع الحقول - إذا فشلت، لا تكمل
    if (!_formKey.currentState!.validate()) return;

    // بدء حالة التحميل - لإظهار شاشة "جاري الحفظ..."
    setState(() => _isLoading = true);

    try {
      // إنشاء كائن DoctorModel من البيانات المدخلة
      final doctor = DoctorModel(
        // المعرف فارغ - Firestore سيُنشئ معرف تلقائي
        id: '',
        // الاسم - إزالة المسافات الزائدة بـ trim()
        name: _nameController.text.trim(),
        // التخصص - إزالة المسافات
        specialty: _specialtyController.text.trim(),
        // البريد الإلكتروني - إزالة المسافات
        email: _emailController.text.trim(),
        // رقم الهاتف - إذا كان فارغ، احفظه كـ null
        // isEmpty = تحقق من النص الفارغ بعد trim
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        // رابط الصورة - إذا كان فارغ، null
        photoUrl: _photoUrlController.text.trim().isEmpty ? null : _photoUrlController.text.trim(),
        // الملاحظات - إذا كانت فارغة، null
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        // الحالة - افتراضياً 'active' (نشط)
        status: 'active',
        // تاريخ الإنشاء - الوقت الحالي
        createdAt: DateTime.now(),
      );

      // حفظ الطبيب في Firestore - await للانتظار
      await _doctorRepo.createDoctor(doctor);

      // التحقق من أن الصفحة لا تزال موجودة
      if (mounted) {
        // إظهار رسالة نجاح أسفل الشاشة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // نص الرسالة - يتغير حسب اللغة
            content: Text(
              Directionality.of(context) == TextDirection.rtl
                  ? 'تم إضافة الطبيب بنجاح'
                  : 'Doctor added successfully',
            ),
            // خلفية خضراء - للنجاح
            backgroundColor: Colors.green,
          ),
        );
        // العودة للصفحة السابقة - قائمة الأطباء
        Navigator.pop(context);
      }
    } catch (e) {
      // معالجة الأخطاء - مثل مشاكل الشبكة أو Firestore
      if (mounted) {
        // إيقاف التحميل - للسماح بالمحاولة مرة أخرى
        setState(() => _isLoading = false);
        // إظهار رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  // دالة بناء الواجهة - ترسم نموذج الإدخال
  Widget build(BuildContext context) {
    // الحصول على موضوع التطبيق
    final theme = Theme.of(context);
    // التحقق من اتجاه النص
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Scaffold - هيكل الصفحة الأساسي
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(title: Text(isRTL ? 'إضافة طبيب' : 'Add Doctor')),
      // محتوى الصفحة مع طبقة التحميل
      body: LoadingOverlay(
        // حالة التحميل - لإظهار/إخفاء شاشة الحفظ
        isLoading: _isLoading,
        // رسالة التحميل بالإنجليزية
        message: 'Saving...',
        // رسالة التحميل بالعربية
        messageAr: 'جاري الحفظ...',
        // محتوى الصفحة - نموذج الإدخال
        child: SingleChildScrollView(
          // حشوة 16 بكسل من جميع الجوانب
          padding: const EdgeInsets.all(16),
          // نموذج الإدخال مع التحقق
          child: Form(
            // ربط مفتاح النموذج - للتحقق من الصحة
            key: _formKey,
            // عمود رأسي - لترتيب الحقول
            child: Column(
              // محاذاة للعرض الكامل
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // قائمة حقول الإدخال
              children: [
                // Name Field * - حقل الاسم (إلزامي)
                TextFormField(
                  // ربط المتحكم
                  controller: _nameController,
                  // إجراء لوحة المفاتيح - الانتقال للحقل التالي
                  textInputAction: TextInputAction.next,
                  // تزيين الحقل
                  decoration: InputDecoration(
                    // التسمية مع * للإلزامي
                    labelText: '${isRTL ? 'الاسم' : 'Name'} *',
                    // نص المساعدة - placeholder
                    hintText: isRTL ? 'أدخل اسم الطبيب' : 'Enter doctor name',
                    // أيقونة شخص على يسار الحقل
                    prefixIcon: const Icon(Icons.person),
                  ),
                  // دالة التحقق - تُنفذ عند الضغط على حفظ
                  validator: (value) {
                    // التحقق من أن الحقل ليس فارغاً
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'الاسم مطلوب' : 'Name is required';
                    }
                    // إذا نجح التحقق - إرجاع null (لا خطأ)
                    return null;
                  },
                ),
                // مسافة بارتفاع 16 بكسل - بين الحقول
                const SizedBox(height: 16),

                // Specialty Field * - حقل التخصص (إلزامي)
                TextFormField(
                  controller: _specialtyController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'التخصص' : 'Specialty'} *',
                    hintText: isRTL ? 'أدخل التخصص' : 'Enter specialty',
                    // أيقونة خدمات طبية
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'التخصص مطلوب' : 'Specialty is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field * - حقل البريد الإلكتروني (إلزامي)
                TextFormField(
                  controller: _emailController,
                  // نوع لوحة المفاتيح - بريد إلكتروني (@، .com)
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'البريد الإلكتروني' : 'Email'} *',
                    hintText: isRTL ? 'أدخل البريد الإلكتروني' : 'Enter email',
                    // أيقونة بريد
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                    }
                    // التحقق من وجود @ في البريد
                    if (!value.contains('@')) {
                      return isRTL ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field (Optional) - حقل الهاتف (اختياري)
                TextFormField(
                  controller: _phoneController,
                  // نوع لوحة المفاتيح - أرقام
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    // التسمية توضح أنه اختياري
                    labelText: isRTL ? 'الهاتف (اختياري)' : 'Phone (Optional)',
                    hintText: isRTL ? 'أدخل رقم الهاتف' : 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  // بدون validator = الحقل اختياري
                ),
                const SizedBox(height: 16),

                // Photo URL Field (Optional) - حقل رابط الصورة (اختياري)
                TextFormField(
                  controller: _photoUrlController,
                  // نوع لوحة المفاتيح - URL
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'رابط الصورة (اختياري)' : 'Photo URL (Optional)',
                    hintText: isRTL ? 'أدخل رابط الصورة' : 'Enter photo URL',
                    // أيقونة صورة
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Field (Optional) - حقل الملاحظات (اختياري)
                TextFormField(
                  controller: _notesController,
                  // عدد الأسطر - 3 أسطر قابلة للتوسع
                  maxLines: 3,
                  // Done = إنهاء الإدخال (آخر حقل)
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'ملاحظات (اختياري)' : 'Notes (Optional)',
                    hintText: isRTL ? 'أدخل ملاحظات' : 'Enter notes',
                    prefixIcon: const Icon(Icons.note),
                    // محاذاة التسمية مع الحقل - للحقول متعددة الأسطر
                    alignLabelWithHint: true,
                  ),
                ),
                // مسافة أكبر قبل الأزرار
                const SizedBox(height: 24),

                // Action Buttons - أزرار الإجراءات (إلغاء / حفظ)
                Row(
                  children: [
                    // زر الإلغاء - Expanded ليأخذ نصف العرض
                    Expanded(
                      // زر بإطار فقط - OutlinedButton
                      child: OutlinedButton(
                        // تعطيل الزر أثناء التحميل - لمنع الضغط المتكرر
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        // تنسيق الزر
                        style: OutlinedButton.styleFrom(
                          // حشوة عمودية 16 بكسل - لزر أطول
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        // نص الزر
                        child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                      ),
                    ),
                    // مسافة بين الزرين
                    const SizedBox(width: 16),
                    // زر الحفظ - Expanded ليأخذ النصف الآخر
                    Expanded(
                      // زر ممتلئ - ElevatedButton
                      child: ElevatedButton(
                        // تعطيل أثناء التحميل، تنفيذ _handleSave عند الضغط
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        // نص زر الحفظ
                        child: Text(isRTL ? 'حفظ' : 'Save'),
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
