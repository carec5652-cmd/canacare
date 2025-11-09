// استيراد مكتبة Material Design - لعناصر الواجهة
import 'package:flutter/material.dart';
// استيراد نموذج بيانات الطبيب - للعمل مع بيانات الطبيب
import 'package:admin_can_care/data/models/doctor_model.dart';
// استيراد نموذج بيانات المريض - لعرض قائمة المرضى التابعين للطبيب
import 'package:admin_can_care/data/models/patient_model.dart';
// استيراد مستودع المرضى - لجلب بيانات المرضى من Firestore
import 'package:admin_can_care/data/repositories/patient_repository.dart';
// استيراد عنصر بطاقة الشخص - لعرض بطاقات المرضى
import 'package:admin_can_care/ui/widgets/person_card.dart';
// استيراد عنصر الحالة الفارغة - لعرض رسالة عند عدم وجود مرضى
import 'package:admin_can_care/ui/widgets/empty_state.dart';

// Doctor Details Screen - شاشة تفاصيل الطبيب
// تعرض معلومات كاملة عن الطبيب وقائمة المرضى التابعين له
// Path: /doctors/:id - يتم الوصول لها عبر النقر على بطاقة طبيب
class DoctorDetailsScreen extends StatefulWidget {
  // بيانات الطبيب المراد عرض تفاصيله - يُمرر من الصفحة السابقة
  final DoctorModel doctor;

  // المُنشئ - يستقبل بيانات الطبيب كمعامل إلزامي
  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  // إنشاء الحالة المتغيرة - للتحكم في قائمة المرضى وحالة التحميل
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

// الحالة الخاصة بشاشة تفاصيل الطبيب
class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  // كائن مستودع المرضى - للوصول لبيانات المرضى من Firestore
  final _patientRepo = PatientRepository();
  // قائمة المرضى التابعين لهذا الطبيب - تُحدث بعد التحميل
  List<PatientModel> _patients = [];
  // حالة التحميل - true أثناء جلب البيانات
  bool _isLoading = true;

  @override
  // دالة التهيئة - تُنفذ مرة واحدة عند إنشاء الصفحة
  void initState() {
    // استدعاء دالة التهيئة الأساسية
    super.initState();
    // تحميل قائمة المرضى من Firestore
    _loadPatients();
  }

  // دالة تحميل المرضى - جلب المرضى المرتبطين بهذا الطبيب
  Future<void> _loadPatients() async {
    // بدء حالة التحميل
    setState(() => _isLoading = true);
    try {
      // جلب قائمة المرضى حسب معرف الطبيب
      // widget.doctor.id = الوصول لمعرف الطبيب من widget
      final patients = await _patientRepo.getPatientsByDoctor(widget.doctor.id);
      // التحقق من أن الصفحة لا تزال موجودة - لتجنب خطأ setState بعد dispose
      if (mounted) {
        // تحديث قائمة المرضى وإيقاف التحميل
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      // معالجة الأخطاء - مثل مشاكل الشبكة
      if (mounted) {
        // إيقاف التحميل فقط - القائمة تبقى فارغة
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  // دالة بناء الواجهة - ترسم الصفحة على الشاشة
  Widget build(BuildContext context) {
    // الحصول على موضوع التطبيق - للألوان والأنماط
    final theme = Theme.of(context);
    // التحقق من اتجاه النص - true = عربي
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Scaffold - الهيكل الأساسي للصفحة
    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(
        // عنوان الصفحة - يتغير حسب اللغة
        title: Text(isRTL ? 'تفاصيل الطبيب' : 'Doctor Details'),
        // أزرار الإجراءات - على يمين الشريط
        actions: [
          // زر التعديل
          IconButton(
            // أيقونة قلم التعديل
            icon: const Icon(Icons.edit),
            // عند الضغط - الانتقال لصفحة التعديل (TODO)
            onPressed: () {
              // Navigate to edit screen
              // سيتم إضافة الكود لاحقاً
            },
          ),
        ],
      ),
      // محتوى الصفحة - قابل للتمرير عمودياً
      body: SingleChildScrollView(
        // عمود رأسي - لترتيب الأقسام فوق بعضها
        child: Column(
          // محاذاة العناصر إلى البداية
          crossAxisAlignment: CrossAxisAlignment.start,
          // قائمة الأقسام
          children: [
            // Profile Header - قسم رأس الملف الشخصي
            Container(
              // عرض كامل الشاشة
              width: double.infinity,
              // تزيين بتدرج لوني
              decoration: BoxDecoration(
                // تدرج لوني من الأعلى للأسفل
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // اللون الأساسي شفاف 10%
                    theme.primaryColor.withOpacity(0.1),
                    // لون خلفية الصفحة
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              // حشوة داخلية 24 بكسل
              padding: const EdgeInsets.all(24),
              // محتوى القسم
              child: Column(
                // قائمة العناصر
                children: [
                  // صورة الطبيب - دائرية
                  CircleAvatar(
                    // نصف قطر 60 بكسل = قطر 120 بكسل
                    radius: 60,
                    // خلفية ملونة شفافة - تظهر إذا لم تكن هناك صورة
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    // صورة الخلفية - من رابط الإنترنت
                    // widget.doctor.photoUrl = رابط صورة الطبيب
                    backgroundImage:
                        widget.doctor.photoUrl != null
                            ? NetworkImage(widget.doctor.photoUrl!)
                            : null,
                    // إذا لم يكن هناك صورة - عرض أيقونة شخص
                    child:
                        widget.doctor.photoUrl == null
                            ? Icon(Icons.person, size: 60, color: theme.primaryColor)
                            : null,
                  ),
                  // مسافة فارغة بارتفاع 16 بكسل
                  const SizedBox(height: 16),
                  // اسم الطبيب - كبير وعريض
                  Text(
                    widget.doctor.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  // مسافة فارغة بارتفاع 8 بكسل
                  const SizedBox(height: 8),
                  // التخصص الطبي - ملون باللون الأساسي
                  Text(
                    widget.doctor.specialty,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor),
                  ),
                  // مسافة فارغة بارتفاع 8 بكسل
                  const SizedBox(height: 8),
                  // شارة الحالة - نشط/غير نشط
                  _buildStatusChip(widget.doctor.status),
                ],
              ),
            ),

            // Contact Information - قسم معلومات الاتصال
            Padding(
              // حشوة 16 بكسل من جميع الجوانب
              padding: const EdgeInsets.all(16),
              child: Column(
                // محاذاة إلى البداية
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان القسم
                  Text(
                    isRTL ? 'معلومات الاتصال' : 'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // بطاقة تحتوي على معلومات الاتصال
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // صف البريد الإلكتروني
                          _buildInfoRow(
                            Icons.email,
                            isRTL ? 'البريد الإلكتروني' : 'Email',
                            widget.doctor.email,
                          ),
                          // إذا كان هناك رقم هاتف - عرضه
                          if (widget.doctor.phone != null) ...[
                            // خط فاصل
                            const Divider(height: 24),
                            // صف رقم الهاتف
                            _buildInfoRow(
                              Icons.phone,
                              isRTL ? 'الهاتف' : 'Phone',
                              widget.doctor.phone!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Notes - قسم الملاحظات (إذا كانت موجودة)
                  if (widget.doctor.notes != null) ...[
                    const SizedBox(height: 16),
                    // عنوان قسم الملاحظات
                    Text(
                      isRTL ? 'ملاحظات' : 'Notes',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // بطاقة الملاحظات
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.doctor.notes!),
                      ),
                    ),
                  ],

                  // Patients Section - قسم المرضى التابعين للطبيب
                  const SizedBox(height: 16),
                  // صف العنوان مع عدد المرضى
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // عنوان القسم
                      Text(
                        isRTL ? 'المرضى' : 'Patients',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // عدد المرضى - ملون باللون الأساسي
                      Text(
                        '${_patients.length} ${isRTL ? 'مريض' : 'patients'}',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // حالات عرض قائمة المرضى - تحميل/فارغة/قائمة
                  // إذا كان جاري التحميل
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  // إذا كانت القائمة فارغة
                  else if (_patients.isEmpty)
                    EmptyState(
                      icon: Icons.people_outline,
                      message: 'No patients assigned',
                      messageAr: 'لا يوجد مرضى مسجلين',
                    )
                  // إذا كان هناك مرضى - عرض القائمة
                  else
                    // قائمة قابلة للتمرير - ListView.builder
                    ListView.builder(
                      // shrinkWrap = تقليص حجم القائمة حسب المحتوى
                      shrinkWrap: true,
                      // منع التمرير داخل القائمة - لأن الصفحة كاملة قابلة للتمرير
                      physics: const NeverScrollableScrollPhysics(),
                      // عدد العناصر في القائمة
                      itemCount: _patients.length,
                      // دالة بناء كل عنصر - تُنفذ لكل مريض
                      itemBuilder: (context, index) {
                        // الحصول على بيانات المريض الحالي
                        final patient = _patients[index];
                        // إرجاع بطاقة المريض
                        return PersonCard(
                          // اسم المريض
                          name: patient.name,
                          // التشخيص - كعنوان فرعي
                          subtitle: patient.diagnosis,
                          // صورة المريض
                          photoUrl: patient.photoUrl,
                          // حالة المريض - نشط/غير نشط
                          status: patient.status,
                          // عند الضغط - الانتقال لصفحة تفاصيل المريض
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/patients/${patient.id}',
                                arguments: patient,
                              ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء صف معلومات - يعرض أيقونة وتسمية وقيمة
  // Widget = تُرجع عنصر واجهة قابل للعرض
  Widget _buildInfoRow(IconData icon, String label, String value) {
    // صف أفقي - أيقونة + نص
    return Row(
      children: [
        // الأيقونة - صغيرة ورمادية
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        // عنصر قابل للتوسع - يملأ المساحة المتبقية
        Expanded(
          // عمود رأسي - التسمية فوق القيمة
          child: Column(
            // محاذاة إلى البداية
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // التسمية - صغيرة ورمادية
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              // القيمة - أكبر ونصف عريضة
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  // دالة بناء شارة الحالة - تعرض الحالة بلون مناسب
  // status = حالة الطبيب ('active', 'inactive', 'suspended')
  Widget _buildStatusChip(String status) {
    // متغيرات اللون والتسمية - تُحدد حسب الحالة
    Color color;
    String label;

    // تحديد اللون والتسمية حسب الحالة
    switch (status.toLowerCase()) {
      // حالة نشط - أخضر
      case 'active':
        color = Colors.green;
        label = 'Active / نشط';
        break;
      // حالة غير نشط - برتقالي
      case 'inactive':
        color = Colors.orange;
        label = 'Inactive / غير نشط';
        break;
      // حالة افتراضية - رمادي
      default:
        color = Colors.grey;
        label = status;
    }

    // صندوق الشارة - مستطيل مستدير بإطار ملون
    return Container(
      // حشوة داخلية - أفقية 16، عمودية 6
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // تزيين - خلفية شفافة وإطار ملون
      decoration: BoxDecoration(
        // خلفية بنفس اللون مع شفافية 10%
        color: color.withOpacity(0.1),
        // حواف دائرية - نصف قطر 20 للشكل البيضاوي
        borderRadius: BorderRadius.circular(20),
        // إطار بنفس اللون - كامل
        border: Border.all(color: color),
      ),
      // نص التسمية - ملون ونصف عريض
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
