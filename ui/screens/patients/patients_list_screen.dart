// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد نموذج بيانات المريض - لتعريف بنية بيانات المريض
import 'package:admin_can_care/data/models/patient_model.dart';
// استيراد مستودع المرضى - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/repositories/patient_repository.dart';
// استيراد بطاقة العرض الشخصية - لعرض بيانات كل مريض
import 'package:admin_can_care/ui/widgets/person_card.dart';
// استيراد واجهة الحالة الفارغة - تظهر عند عدم وجود نتائج
import 'package:admin_can_care/ui/widgets/empty_state.dart';
// استيراد شريط البحث - للبحث عن المرضى
import 'package:admin_can_care/ui/widgets/search_bar_widget.dart';
// استيراد تخطيط الشاشة الرئيسي - لتوحيد تصميم الشاشات
import 'package:admin_can_care/ui/layouts/main_layout.dart';

// Patients List Screen - شاشة قائمة المرضى
// تعرض جميع المرضى في النظام مع إمكانية البحث والفلترة
class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key}); // المُنشئ الثابت للشاشة

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState(); // إنشاء حالة الشاشة
}

// حالة شاشة قائمة المرضى - تدير البيانات والبحث
class _PatientsListScreenState extends State<PatientsListScreen> {
  final _patientRepo = PatientRepository(); // مثيل مستودع المرضى للتفاعل مع Firestore
  final _searchController = TextEditingController(); // متحكم حقل البحث
  String _searchQuery = ''; // نص البحث الحالي (صغيرة الأحرف)

  @override
  Widget build(BuildContext context) {
    final isRTL =
        Directionality.of(context) ==
        TextDirection.rtl; // تحديد ما إذا كانت اللغة من اليمين لليسار (RTL)

    return MainLayout(
      // استخدام تخطيط الشاشة الرئيسي الموحد
      title: 'Patients', // عنوان الشاشة بالإنجليزية
      titleAr: 'المرضى', // عنوان الشاشة بالعربية
      floatingActionButton: FloatingActionButton.extended(
        // زر عائم ممتد لإضافة مريض جديد
        onPressed: () => Navigator.pushNamed(context, '/patients/add'), // الانتقال لشاشة إضافة مريض
        icon: const Icon(Icons.add), // أيقونة إضافة
        label: Text(isRTL ? 'إضافة مريض' : 'Add Patient'), // نص الزر حسب اللغة
      ),
      child: Column(
        // عمود يحتوي على شريط البحث والقائمة
        children: [
          Padding(
            // مسافة داخلية حول شريط البحث
            padding: const EdgeInsets.all(16), // 16 بكسل من جميع الجوانب
            child: SearchBarWidget(
              // شريط البحث المخصص
              controller: _searchController, // المتحكم في نص البحث
              hintText: 'Search patients...', // نص تلميح البحث بالإنجليزية
              hintTextAr: 'البحث عن المرضى...', // نص تلميح البحث بالعربية
              onChanged:
                  (value) => setState(
                    () => _searchQuery = value.toLowerCase(),
                  ), // تحديث نص البحث عند التغيير (تحويل للأحرف الصغيرة)
              onClear:
                  () => setState(() => _searchQuery = ''), // مسح نص البحث عند الضغط على زر المسح
            ),
          ),
          Expanded(
            // جعل القائمة تملأ باقي المساحة المتاحة
            child: StreamBuilder<List<PatientModel>>(
              // بناء الواجهة من بيانات Stream في الوقت الفعلي
              stream: _patientRepo.streamPatients(), // الاتصال بـ Stream المرضى من Firestore
              builder: (context, snapshot) {
                // دالة البناء التي تستجيب للتغييرات
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // إذا كان Stream ينتظر البيانات
                  return const Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل دائري
                }
                final patients =
                    snapshot.data ??
                    []; // الحصول على قائمة المرضى (أو قائمة فارغة إذا لم توجد بيانات)
                final filtered = // تطبيق فلتر البحث على القائمة
                    _searchQuery
                            .isEmpty // إذا كان نص البحث فارغاً
                        ? patients // عرض جميع المرضى
                        : patients // وإلا فلترة المرضى
                            .where(
                              // تصفية العناصر
                              (p) => // شرط التصفية: البحث في الاسم أو التشخيص
                                  p.name.toLowerCase().contains(
                                    _searchQuery,
                                  ) || // إذا كان الاسم يحتوي على نص البحث
                                  p.diagnosis.toLowerCase().contains(
                                    _searchQuery,
                                  ), // أو إذا كان التشخيص يحتوي على نص البحث
                            )
                            .toList(); // تحويل النتيجة إلى قائمة

                if (filtered.isEmpty) {
                  // إذا كانت القائمة المفلترة فارغة
                  return EmptyState(
                    // عرض واجهة الحالة الفارغة
                    icon: Icons.people_outline, // أيقونة أشخاص
                    message: 'No patients found', // رسالة بالإنجليزية
                    messageAr: 'لا يوجد مرضى', // رسالة بالعربية
                    actionLabel: 'Add Patient', // نص زر الإضافة بالإنجليزية
                    actionLabelAr: 'إضافة مريض', // نص زر الإضافة بالعربية
                    onAction:
                        () => Navigator.pushNamed(
                          context,
                          '/patients/add',
                        ), // الانتقال لشاشة إضافة مريض عند الضغط
                  );
                }

                return ListView.builder(
                  // بناء قائمة قابلة للتمرير
                  itemCount: filtered.length, // عدد العناصر في القائمة المفلترة
                  padding: const EdgeInsets.only(bottom: 80), // مسافة سفلية لتجنب تغطية الزر العائم
                  itemBuilder: (context, index) {
                    // دالة بناء كل عنصر في القائمة
                    final patient = filtered[index]; // الحصول على المريض في الفهرس الحالي
                    return PersonCard(
                      // عرض بطاقة المريض
                      name: patient.name, // اسم المريض
                      subtitle: // النص الثانوي: التشخيص والعمر
                          '${patient.diagnosis}${patient.age != null ? ' • ${patient.age} years' : ''}',
                      photoUrl: patient.photoUrl, // رابط صورة المريض
                      status: patient.status, // حالة المريض (نشط/غير نشط)
                      onTap: // عند النقر على البطاقة
                          () => Navigator.pushNamed(
                            // الانتقال لشاشة تفاصيل المريض
                            context,
                            '/patients/${patient.id}', // المسار مع معرف المريض
                            arguments: patient, // تمرير كائن المريض كوسيط
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
