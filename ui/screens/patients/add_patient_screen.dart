// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد نموذج بيانات المريض - لتعريف بنية بيانات المريض
import 'package:admin_can_care/data/models/patient_model.dart';
// استيراد مستودع المرضى - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/repositories/patient_repository.dart';
// استيراد واجهة التحميل - لعرض شاشة التحميل أثناء العمليات
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Patient Screen - شاشة إضافة مريض
// شاشة نموذج لإضافة مريض جديد إلى النظام
class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key}); // المُنشئ الثابت للشاشة

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState(); // إنشاء حالة الشاشة
}

// حالة شاشة إضافة المريض - تدير النموذج والتفاعلات
class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>(); // مفتاح فريد للتحقق من صحة النموذج
  final _nameController = TextEditingController(); // متحكم حقل إدخال الاسم
  final _diagnosisController = TextEditingController(); // متحكم حقل إدخال التشخيص
  final _emailController = TextEditingController(); // متحكم حقل إدخال البريد الإلكتروني
  final _phoneController = TextEditingController(); // متحكم حقل إدخال رقم الهاتف
  final _patientRepo = PatientRepository(); // مثيل مستودع المرضى للتفاعل مع Firestore

  String? _selectedGender; // الجنس المُختار (ذكر/أنثى) - قد يكون فارغاً
  DateTime? _dateOfBirth; // تاريخ الميلاد المُختار - قد يكون فارغاً
  bool _isLoading = false; // متغير حالة التحميل - يُستخدم لإظهار/إخفاء شاشة التحميل

  // دالة لفتح منتقي التاريخ واختيار تاريخ الميلاد
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      // إظهار منتقي التاريخ
      context: context, // سياق الشاشة
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 30),
      ), // التاريخ الافتراضي: منذ 30 سنة
      firstDate: DateTime(1920), // أقدم تاريخ يمكن اختياره: 1920
      lastDate: DateTime.now(), // أحدث تاريخ يمكن اختياره: اليوم
    );
    if (picked != null)
      setState(() => _dateOfBirth = picked); // إذا تم اختيار تاريخ، تحديث حالة الشاشة
  }

  // دالة معالجة حفظ المريض الجديد - تتحقق من صحة البيانات ثم تحفظها في Firestore
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate())
      return; // التحقق من صحة النموذج - إذا فشل، إيقاف التنفيذ

    setState(() => _isLoading = true); // تفعيل حالة التحميل لإظهار شاشة التحميل

    try {
      // إنشاء كائن PatientModel جديد من البيانات المُدخلة
      final patient = PatientModel(
        id: '', // المعرف سيتم توليده تلقائياً من Firestore
        name: _nameController.text.trim(), // الاسم (إزالة المسافات الزائدة)
        diagnosis: _diagnosisController.text.trim(), // التشخيص (إزالة المسافات الزائدة)
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(), // البريد الإلكتروني (null إذا كان فارغاً)
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(), // الهاتف (null إذا كان فارغاً)
        dateOfBirth: _dateOfBirth, // تاريخ الميلاد المُختار (قد يكون null)
        gender: _selectedGender, // الجنس المُختار (قد يكون null)
        status: 'active', // الحالة الافتراضية للمريض الجديد: نشط
        createdAt: DateTime.now(), // تاريخ ووقت الإنشاء الحالي
      );

      await _patientRepo.createPatient(patient); // حفظ المريض الجديد في Firestore

      if (mounted) {
        // التحقق من أن الشاشة لا تزال موجودة في الذاكرة
        ScaffoldMessenger.of(context).showSnackBar(
          // عرض رسالة نجاح
          SnackBar(
            content: Text(
              Directionality.of(context) ==
                      TextDirection
                          .rtl // تحديد اللغة حسب اتجاه النص
                  ? 'تم إضافة المريض بنجاح' // رسالة بالعربية
                  : 'Patient added successfully',
            ), // رسالة بالإنجليزية
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
        title: Text(isRTL ? 'إضافة مريض' : 'Add Patient'),
      ), // شريط التطبيق العلوي مع العنوان حسب اللغة
      body: LoadingOverlay(
        // واجهة التحميل التي تغطي الشاشة أثناء الحفظ
        isLoading: _isLoading, // حالة التحميل
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
                  // حقل إدخال التشخيص
                  controller: _diagnosisController, // المتحكم في النص المُدخل
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: '${isRTL ? 'التشخيص' : 'Diagnosis'} *', // تسمية الحقل (إلزامي)
                    prefixIcon: const Icon(Icons.medical_information), // أيقونة معلومات طبية
                  ),
                  validator:
                      (v) =>
                          v == null ||
                                  v
                                      .isEmpty // دالة التحقق من صحة الإدخال
                              ? (isRTL
                                  ? 'التشخيص مطلوب'
                                  : 'Diagnosis is required') // رسالة خطأ إذا كان الحقل فارغاً
                              : null, // إذا كان الحقل صحيحاً، إرجاع null
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                ListTile(
                  // عنصر قائمة قابل للنقر لاختيار تاريخ الميلاد
                  contentPadding: EdgeInsets.zero, // بدون مسافة داخلية
                  leading: const Icon(Icons.cake), // أيقونة كعكة (ترمز لعيد الميلاد)
                  title: Text(
                    _dateOfBirth ==
                            null // النص المعروض: إما التاريخ المختار أو نص التلميح
                        ? (isRTL
                            ? 'تاريخ الميلاد'
                            : 'Date of Birth') // نص التلميح إذا لم يتم اختيار تاريخ
                        : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                  ), // التاريخ المختار بصيغة يوم/شهر/سنة
                  trailing: const Icon(Icons.calendar_today), // أيقونة تقويم في النهاية
                  onTap: _selectDate, // عند النقر: فتح منتقي التاريخ
                  shape: RoundedRectangleBorder(
                    // شكل العنصر: مستطيل مع حواف دائرية
                    borderRadius: BorderRadius.circular(12), // نصف قطر الحواف: 12 بكسل
                    side: BorderSide(color: Colors.grey.shade400), // حدود رمادية فاتحة
                  ),
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                DropdownButtonFormField<String>(
                  // قائمة منسدلة لاختيار الجنس
                  value: _selectedGender, // القيمة المختارة حالياً
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: isRTL ? 'الجنس' : 'Gender', // تسمية الحقل
                    prefixIcon: const Icon(Icons.wc), // أيقونة دورة مياه (ترمز للجنس)
                  ),
                  items: [
                    // قائمة الخيارات
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(isRTL ? 'ذكر' : 'Male'),
                    ), // خيار ذكر
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(isRTL ? 'أنثى' : 'Female'),
                    ), // خيار أنثى
                  ],
                  onChanged:
                      (v) =>
                          setState(() => _selectedGender = v), // عند التغيير: تحديث القيمة المختارة
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال رقم الهاتف (اختياري)
                  controller: _phoneController, // المتحكم في النص المُدخل
                  keyboardType: TextInputType.phone, // نوع لوحة المفاتيح: هاتف
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: isRTL ? 'الهاتف' : 'Phone', // تسمية الحقل
                    prefixIcon: const Icon(Icons.phone), // أيقونة هاتف
                  ),
                ),
                const SizedBox(height: 16), // مسافة عمودية 16 بكسل
                TextFormField(
                  // حقل إدخال البريد الإلكتروني (اختياري)
                  controller: _emailController, // المتحكم في النص المُدخل
                  keyboardType: TextInputType.emailAddress, // نوع لوحة المفاتيح: بريد إلكتروني
                  decoration: InputDecoration(
                    // تزيين الحقل
                    labelText: isRTL ? 'البريد الإلكتروني' : 'Email', // تسمية الحقل
                    prefixIcon: const Icon(Icons.email), // أيقونة بريد إلكتروني
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
