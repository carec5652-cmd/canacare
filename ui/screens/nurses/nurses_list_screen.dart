// استيراد مكتبة Material Design - لعناصر الواجهة
import 'package:flutter/material.dart';
// استيراد نموذج بيانات الممرض - للعمل مع بيانات الممرضين
import 'package:admin_can_care/data/models/nurse_model.dart';
// استيراد مستودع الممرضين - لجلب البيانات من Firestore
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
// استيراد عنصر بطاقة الشخص - لعرض بطاقات الممرضين
import 'package:admin_can_care/ui/widgets/person_card.dart';
// استيراد عنصر الحالة الفارغة - عند عدم وجود ممرضين
import 'package:admin_can_care/ui/widgets/empty_state.dart';
// استيراد عنصر شريط البحث - للبحث في القائمة
import 'package:admin_can_care/ui/widgets/search_bar_widget.dart';
// استيراد التخطيط الرئيسي - الإطار الأساسي مع القائمة الجانبية
import 'package:admin_can_care/ui/layouts/main_layout.dart';

// Nurses List Screen - شاشة قائمة الممرضين
// تعرض جميع الممرضين مع إمكانية البحث والفلترة
// Path: /nurses - يتم الوصول لها من القائمة الجانبية
class NursesListScreen extends StatefulWidget {
  // المُنشئ
  const NursesListScreen({super.key});

  @override
  // إنشاء الحالة المتغيرة - للتحكم في البحث والفلاتر
  State<NursesListScreen> createState() => _NursesListScreenState();
}

// الحالة الخاصة بشاشة قائمة الممرضين
class _NursesListScreenState extends State<NursesListScreen> {
  // كائن مستودع الممرضين - للوصول لبيانات Firestore
  final _nurseRepo = NurseRepository();
  // متحكم شريط البحث - للوصول لنص البحث
  final _searchController = TextEditingController();

  // القسم المحدد للفلترة - اختياري (ICU, ER, Surgery...)
  String? _selectedDepartment;
  // الحالة المحددة للفلترة - اختياري (active, inactive)
  String? _selectedStatus;
  // نص البحث الحالي - للبحث في الاسم/القسم/البريد
  String _searchQuery = '';

  @override
  // دالة التنظيف - تحرير موارد المتحكم
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  // دالة بناء الواجهة
  Widget build(BuildContext context) {
    // التحقق من اتجاه النص
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // MainLayout - التخطيط الرئيسي مع القائمة الجانبية
    return MainLayout(
      // عنوان الصفحة بالإنجليزية
      title: 'Nurses',
      // عنوان الصفحة بالعربية
      titleAr: 'الممرضين',
      // أزرار شريط التطبيق العلوي
      actions: [
        // زر الفلاتر
        IconButton(
          // أيقونة قائمة الفلترة
          icon: const Icon(Icons.filter_list_rounded),
          // عند الضغط - إظهار نافذة الفلاتر
          onPressed: _showFilterDialog,
        ),
        // مسافة فارغة
        const SizedBox(width: 8),
      ],
      // زر الإضافة العائم - أسفل يمين الشاشة
      floatingActionButton: FloatingActionButton.extended(
        // عند الضغط - الانتقال لصفحة إضافة ممرض
        onPressed: () => Navigator.pushNamed(context, '/nurses/add'),
        // أيقونة +
        icon: const Icon(Icons.add),
        // نص الزر
        label: Text(isRTL ? 'إضافة ممرض' : 'Add Nurse'),
      ),
      // محتوى الصفحة - عمود يحتوي على البحث والقائمة
      child: Column(
        children: [
          // شريط البحث - في أعلى القائمة
          Padding(
            // حشوة 16 بكسل من جميع الجوانب
            padding: const EdgeInsets.all(16),
            // عنصر شريط البحث المخصص
            child: SearchBarWidget(
              // ربط المتحكم
              controller: _searchController,
              // نص المساعدة بالإنجليزية
              hintText: 'Search nurses...',
              // نص المساعدة بالعربية
              hintTextAr: 'البحث عن الممرضين...',
              // عند تغيير النص - تحديث نتائج البحث
              onChanged: (value) {
                // تحديث نص البحث مع تحويله لأحرف صغيرة للمقارنة
                setState(() => _searchQuery = value.toLowerCase());
              },
              // عند الضغط على مسح - إعادة تعيين البحث
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          ),
          // قائمة الممرضين - Expanded لملء المساحة المتبقية
          Expanded(
            // StreamBuilder - يستمع للتغييرات في Firestore ويحدث الواجهة تلقائياً
            child: StreamBuilder<List<NurseModel>>(
              // الاستماع لتدفق الممرضين مع الفلاتر المحددة
              stream: _nurseRepo.streamNurses(
                // فلتر القسم - null = جميع الأقسام
                department: _selectedDepartment,
                // فلتر الحالة - null = جميع الحالات
                status: _selectedStatus,
              ),
              // دالة بناء الواجهة حسب حالة Stream
              builder: (context, snapshot) {
                // إذا كان جاري الانتظار - عرض مؤشر تحميل
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // إذا كان هناك خطأ - عرض رسالة الخطأ
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // الحصول على قائمة الممرضين - ?? [] = قائمة فارغة كقيمة افتراضية
                final nurses = snapshot.data ?? [];

                // تطبيق فلتر البحث المحلي - على النتائج من Firestore
                final filteredNurses =
                    _searchQuery.isEmpty
                        // إذا كان البحث فارغ - عرض جميع الممرضين
                        ? nurses
                        // وإلا - فلترة حسب نص البحث
                        : nurses.where((nurse) {
                          // البحث في الاسم أو القسم أو البريد الإلكتروني
                          return nurse.name.toLowerCase().contains(_searchQuery) ||
                              nurse.department.toLowerCase().contains(_searchQuery) ||
                              nurse.email.toLowerCase().contains(_searchQuery);
                        }).toList();

                // إذا كانت القائمة المفلترة فارغة - عرض حالة فارغة
                if (filteredNurses.isEmpty) {
                  return EmptyState(
                    // أيقونة المستشفى
                    icon: Icons.local_hospital_outlined,
                    // رسالة بالإنجليزية
                    message: 'No nurses found',
                    // رسالة بالعربية
                    messageAr: 'لا يوجد ممرضين',
                    // تسمية زر الإجراء
                    actionLabel: 'Add Nurse',
                    actionLabelAr: 'إضافة ممرض',
                    // عند الضغط - الانتقال لصفحة الإضافة
                    onAction: () => Navigator.pushNamed(context, '/nurses/add'),
                  );
                }

                // عرض قائمة الممرضين - ListView.builder
                return ListView.builder(
                  // عدد العناصر في القائمة
                  itemCount: filteredNurses.length,
                  // حشوة سفلية 80 بكسل - لتجنب تغطية الزر العائم
                  padding: const EdgeInsets.only(bottom: 80),
                  // دالة بناء كل عنصر
                  itemBuilder: (context, index) {
                    // الحصول على بيانات الممرض الحالي
                    final nurse = filteredNurses[index];
                    // إرجاع بطاقة الممرض
                    return PersonCard(
                      // اسم الممرض
                      name: nurse.name,
                      // القسم - كعنوان فرعي
                      subtitle: nurse.department,
                      // صورة الممرض
                      photoUrl: nurse.photoUrl,
                      // حالة الممرض - نشط/غير نشط
                      status: nurse.status,
                      // عند الضغط - الانتقال لصفحة تفاصيل الممرض
                      onTap:
                          () =>
                              Navigator.pushNamed(context, '/nurses/${nurse.id}', arguments: nurse),
                      // قائمة الإجراءات - قائمة منبثقة على يمين البطاقة
                      actions: [
                        // قائمة منبثقة بالخيارات
                        PopupMenuButton<String>(
                          // عند اختيار خيار - تنفيذ الإجراء المناسب
                          onSelected: (value) => _handleAction(value, nurse),
                          // بناء عناصر القائمة
                          itemBuilder:
                              (context) => [
                                // خيار "عرض" - لعرض التفاصيل
                                PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      // أيقونة العين
                                      const Icon(Icons.visibility),
                                      const SizedBox(width: 8),
                                      // نص الخيار
                                      Text(isRTL ? 'عرض' : 'View'),
                                    ],
                                  ),
                                ),
                                // خيار "تنشيط/تعطيل" - حسب الحالة الحالية
                                PopupMenuItem(
                                  // القيمة تتغير حسب الحالة
                                  value: nurse.status == 'active' ? 'deactivate' : 'activate',
                                  child: Row(
                                    children: [
                                      // الأيقونة تتغير حسب الحالة
                                      Icon(
                                        nurse.status == 'active'
                                            ? Icons
                                                .block // أيقونة منع
                                            : Icons.check_circle, // أيقونة تفعيل
                                      ),
                                      const SizedBox(width: 8),
                                      // النص يتغير حسب الحالة
                                      Text(
                                        nurse.status == 'active'
                                            ? (isRTL ? 'تعطيل' : 'Deactivate')
                                            : (isRTL ? 'تنشيط' : 'Activate'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
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

  // دالة إظهار نافذة الفلاتر - تعرض نافذة حوار بخيارات الفلترة
  void _showFilterDialog() {
    // التحقق من اتجاه النص
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // إظهار نافذة حوار
    showDialog(
      context: context,
      // بناء محتوى النافذة
      builder:
          (context) => AlertDialog(
            // عنوان النافذة
            title: Text(isRTL ? 'الفلاتر' : 'Filters'),
            // محتوى النافذة - StatefulBuilder للتحكم في حالة النافذة
            content: StatefulBuilder(
              // builder يتيح تحديث حالة النافذة بشكل مستقل
              builder:
                  (context, setDialogState) => Column(
                    // حجم أصغر ما يمكن
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // قائمة منسدلة للقسم - Department
                      DropdownButtonFormField<String>(
                        // القيمة الحالية المختارة
                        value: _selectedDepartment,
                        // تزيين الحقل
                        decoration: InputDecoration(labelText: isRTL ? 'القسم' : 'Department'),
                        // قائمة الخيارات المتاحة
                        items: [
                          // خيار "الكل" - null = لا فلتر
                          DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                          // خيارات الأقسام المختلفة
                          DropdownMenuItem(
                            value: 'ICU',
                            child: Text(isRTL ? 'العناية المركزة' : 'ICU'),
                          ),
                          DropdownMenuItem(value: 'ER', child: Text(isRTL ? 'الطوارئ' : 'ER')),
                          DropdownMenuItem(
                            value: 'Surgery',
                            child: Text(isRTL ? 'الجراحة' : 'Surgery'),
                          ),
                          DropdownMenuItem(
                            value: 'Pediatrics',
                            child: Text(isRTL ? 'الأطفال' : 'Pediatrics'),
                          ),
                        ],
                        // عند تغيير الاختيار - تحديث القيمة في حالة النافذة
                        onChanged: (value) => setDialogState(() => _selectedDepartment = value),
                      ),
                      // مسافة بين القوائم
                      const SizedBox(height: 16),
                      // قائمة منسدلة للحالة - Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(labelText: isRTL ? 'الحالة' : 'Status'),
                        items: [
                          DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                          DropdownMenuItem(value: 'active', child: Text(isRTL ? 'نشط' : 'Active')),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(isRTL ? 'غير نشط' : 'Inactive'),
                          ),
                        ],
                        onChanged: (value) => setDialogState(() => _selectedStatus = value),
                      ),
                    ],
                  ),
            ),
            // أزرار النافذة - إعادة تعيين / تطبيق
            actions: [
              // زر "إعادة تعيين" - لمسح جميع الفلاتر
              TextButton(
                onPressed: () {
                  // مسح الفلاتر في الحالة الرئيسية
                  setState(() {
                    _selectedDepartment = null;
                    _selectedStatus = null;
                  });
                  // إغلاق النافذة
                  Navigator.pop(context);
                },
                child: Text(isRTL ? 'إعادة تعيين' : 'Reset'),
              ),
              // زر "تطبيق" - لحفظ الفلاتر وإغلاق النافذة
              ElevatedButton(
                onPressed: () {
                  // تحديث الواجهة الرئيسية - لتطبيق الفلاتر
                  setState(() {});
                  // إغلاق النافذة
                  Navigator.pop(context);
                },
                child: Text(isRTL ? 'تطبيق' : 'Apply'),
              ),
            ],
          ),
    );
  }

  // دالة معالجة الإجراء المختار من القائمة المنبثقة
  // action = اسم الإجراء ('view', 'activate', 'deactivate')
  // nurse = بيانات الممرض المختار
  void _handleAction(String action, NurseModel nurse) {
    // إذا كان الإجراء "عرض" - الانتقال لصفحة التفاصيل
    if (action == 'view') {
      Navigator.pushNamed(context, '/nurses/${nurse.id}', arguments: nurse);
    }
    // وإلا - تنشيط أو تعطيل الممرض
    else {
      _toggleNurseStatus(nurse);
    }
  }

  // دالة تبديل حالة الممرض - بين نشط وغير نشط
  Future<void> _toggleNurseStatus(NurseModel nurse) async {
    // التحقق من اتجاه النص
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // تحديد الحالة الجديدة - عكس الحالة الحالية
    final newStatus = nurse.status == 'active' ? 'inactive' : 'active';

    try {
      // تحديث الحالة في Firestore
      await _nurseRepo.updateNurse(nurse.id, {'status': newStatus});
      // إذا نجح - إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isRTL ? 'تم تحديث الحالة' : 'Status updated')));
      }
    } catch (e) {
      // معالجة الخطأ - إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
