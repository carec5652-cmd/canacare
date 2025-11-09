// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد مستودع الأطباء - للحصول على بيانات الأطباء
import 'package:admin_can_care/data/repositories/doctor_repository.dart';
// استيراد مستودع الممرضين - للحصول على بيانات الممرضين
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
// استيراد مستودع المرضى - للحصول على بيانات المرضى
import 'package:admin_can_care/data/repositories/patient_repository.dart';
// استيراد مستودع النقل - للحصول على بيانات طلبات النقل
import 'package:admin_can_care/data/repositories/transport_repository.dart';
// استيراد عنصر عرض الإحصائيات - لعرض الأرقام والبيانات
import 'package:admin_can_care/ui/widgets/stat_tile.dart';
// استيراد التخطيط الرئيسي - الإطار الأساسي للصفحة
import 'package:admin_can_care/ui/layouts/main_layout.dart';
// استيراد خدمة المصادقة من Firebase - لبيانات المستخدم الحالي
import 'package:firebase_auth/firebase_auth.dart';

// Dashboard Screen - شاشة لوحة التحكم الرئيسية
// الصفحة الأولى التي يراها المشرف بعد تسجيل الدخول
// Path: /dashboard - المسار في التطبيق
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // إنشاء الحالة المتغيرة للصفحة - للتحكم في البيانات المتغيرة
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// الحالة الخاصة بشاشة لوحة التحكم - تحتوي على المنطق والبيانات
class _DashboardScreenState extends State<DashboardScreen> {
  // إنشاء كائن مستودع الأطباء - للوصول إلى بيانات الأطباء من Firestore
  final _doctorRepo = DoctorRepository();
  // إنشاء كائن مستودع الممرضين - للوصول إلى بيانات الممرضين من Firestore
  final _nurseRepo = NurseRepository();
  // إنشاء كائن مستودع المرضى - للوصول إلى بيانات المرضى من Firestore
  final _patientRepo = PatientRepository();
  // إنشاء كائن مستودع النقل - للوصول إلى بيانات طلبات النقل من Firestore
  final _transportRepo = TransportRepository();

  // متغير لتخزين عدد الأطباء النشطين - القيمة الافتراضية 0
  int _doctorsCount = 0;
  // متغير لتخزين عدد الممرضين النشطين - القيمة الافتراضية 0
  int _nursesCount = 0;
  // متغير لتخزين عدد المرضى النشطين - القيمة الافتراضية 0
  int _patientsCount = 0;
  // متغير لتخزين عدد طلبات النقل المعلقة - القيمة الافتراضية 0
  int _pendingTransports = 0;
  // متغير للإشارة إلى حالة التحميل - true = جاري التحميل، false = انتهى التحميل
  bool _isLoading = true;

  @override
  // دالة تُنفذ عند إنشاء الصفحة لأول مرة - قبل عرض الواجهة
  void initState() {
    // استدعاء الدالة الأساسية من الكلاس الأب - ضروري دائماً
    super.initState();
    // تحميل الإحصائيات من قاعدة البيانات
    _loadStats();
  }

  // دالة لتحميل الإحصائيات من Firebase Firestore - async للانتظار
  Future<void> _loadStats() async {
    // التحقق من أن الصفحة لا تزال موجودة في الشاشة - لتجنب الأخطاء
    if (!mounted) return;
    // تحديث حالة التحميل إلى true - لإظهار مؤشر التحميل
    setState(() => _isLoading = true);

    try {
      // جلب عدد الأطباء النشطين من قاعدة البيانات - انتظار النتيجة
      final doctors = await _doctorRepo.getDoctorsCount(status: 'active');
      // جلب عدد الممرضين النشطين من قاعدة البيانات - انتظار النتيجة
      final nurses = await _nurseRepo.getNursesCount(status: 'active');
      // جلب عدد المرضى النشطين من قاعدة البيانات - انتظار النتيجة
      final patients = await _patientRepo.getPatientsCount(status: 'active');
      // جلب إحصائيات طلبات النقل من قاعدة البيانات - انتظار النتيجة
      final transportStats = await _transportRepo.getTransportStats();

      // التحقق مرة أخرى من أن الصفحة لا تزال موجودة - قبل تحديث الواجهة
      if (mounted) {
        // تحديث الواجهة مع القيم الجديدة - setState تعيد رسم الصفحة
        setState(() {
          // حفظ عدد الأطباء في المتغير
          _doctorsCount = doctors;
          // حفظ عدد الممرضين في المتغير
          _nursesCount = nurses;
          // حفظ عدد المرضى في المتغير
          _patientsCount = patients;
          // حفظ عدد طلبات النقل المعلقة - استخدام 0 كقيمة افتراضية إذا كانت null
          _pendingTransports = transportStats['pending'] ?? 0;
          // إيقاف حالة التحميل - لإخفاء مؤشر التحميل
          _isLoading = false;
        });
      }
    } catch (e) {
      // في حالة حدوث خطأ - طباعة الخطأ في وحدة التحكم للمطورين
      debugPrint('Error loading stats: $e');
      // التحقق من أن الصفحة لا تزال موجودة
      if (mounted) {
        // تحديث الواجهة مع قيم صفرية - في حالة الفشل
        setState(() {
          // إعادة تعيين عدد الأطباء إلى صفر
          _doctorsCount = 0;
          // إعادة تعيين عدد الممرضين إلى صفر
          _nursesCount = 0;
          // إعادة تعيين عدد المرضى إلى صفر
          _patientsCount = 0;
          // إعادة تعيين عدد طلبات النقل إلى صفر
          _pendingTransports = 0;
          // إيقاف حالة التحميل
          _isLoading = false;
        });
      }
    }
  }

  @override
  // دالة بناء الواجهة - تُستدعى لرسم الصفحة على الشاشة
  Widget build(BuildContext context) {
    // الحصول على موضوع التطبيق الحالي - للألوان والأنماط
    final theme = Theme.of(context);
    // التحقق من اتجاه النص - true = من اليمين لليسار (عربي)، false = من اليسار لليمين (إنجليزي)
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // الحصول على بيانات المستخدم الحالي المسجل دخوله من Firebase
    final user = FirebaseAuth.instance.currentUser;

    // إرجاع التخطيط الرئيسي مع محتوى الصفحة
    return MainLayout(
      // عنوان الصفحة بالإنجليزية - يظهر في شريط التطبيق العلوي
      title: 'Dashboard',
      // عنوان الصفحة بالعربية - يظهر عند تبديل اللغة
      titleAr: 'لوحة التحكم',
      // الأزرار التي تظهر في شريط التطبيق العلوي (يمين الشاشة)
      actions: [
        // زر الإشعارات مع رقم تنبيه
        IconButton(
          // أيقونة الجرس مع شارة رقمية (3) - لعرض عدد الإشعارات
          icon: Badge(label: const Text('3'), child: const Icon(Icons.notifications_outlined)),
          // عند الضغط - الانتقال إلى صفحة إنشاء إشعار جديد
          onPressed: () => Navigator.pushNamed(context, '/notifications/create'),
        ),
        // مسافة فارغة بعرض 8 بكسل - للتباعد
        const SizedBox(width: 8),
      ],
      // محتوى الصفحة الرئيسي - داخل التخطيط
      child: RefreshIndicator(
        // عند السحب للأسفل - إعادة تحميل الإحصائيات
        onRefresh: _loadStats,
        // محتوى قابل للتمرير - SingleChildScrollView يسمح بالتمرير عمودياً
        child: SingleChildScrollView(
          // السماح بالتمرير دائماً - حتى لو كان المحتوى صغيراً
          physics: const AlwaysScrollableScrollPhysics(),
          // حشوة داخلية 16 بكسل من كل الجوانب - للتباعد
          padding: const EdgeInsets.all(16),
          // عمود رأسي - لترتيب العناصر فوق بعضها
          child: Column(
            // محاذاة العناصر إلى البداية (يسار للإنجليزي، يمين للعربي)
            crossAxisAlignment: CrossAxisAlignment.start,
            // قائمة العناصر داخل العمود
            children: [
              // قسم الترحيب مع تدرج لوني - Welcome Section with gradient
              Container(
                // التزيين والتنسيق - decoration للتصميم
                decoration: BoxDecoration(
                  // تدرج لوني من اللون الأساسي إلى الثانوي
                  gradient: LinearGradient(
                    // بداية التدرج من أعلى اليسار
                    begin: Alignment.topLeft,
                    // نهاية التدرج في أسفل اليمين
                    end: Alignment.bottomRight,
                    // الألوان المستخدمة في التدرج - من الموضوع
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                  // حواف دائرية بنصف قطر 20 بكسل - للجمالية
                  borderRadius: BorderRadius.circular(20),
                  // ظل للصندوق - لإضافة عمق وبعد ثلاثي
                  boxShadow: [
                    BoxShadow(
                      // لون الظل - اللون الأساسي مع شفافية 30%
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      // مقدار ضبابية الظل - 20 بكسل
                      blurRadius: 20,
                      // إزاحة الظل - 10 بكسل للأسفل
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                // حشوة داخلية 24 بكسل من كل الجوانب
                padding: const EdgeInsets.all(24),
                // صف أفقي - لترتيب العناصر جنباً إلى جنب
                child: Row(
                  // قائمة العناصر في الصف
                  children: [
                    // صندوق الصورة الشخصية للمستخدم
                    Container(
                      // حشوة 4 بكسل حول الصورة
                      padding: const EdgeInsets.all(4),
                      // تزيين بخلفية شفافة ودائرية
                      decoration: BoxDecoration(
                        // خلفية بيضاء شفافة 20%
                        color: Colors.white.withOpacity(0.2),
                        // شكل دائري
                        shape: BoxShape.circle,
                      ),
                      // صورة دائرية للمستخدم - CircleAvatar
                      child: CircleAvatar(
                        // نصف قطر الدائرة 32 بكسل
                        radius: 32,
                        // خلفية بيضاء للدائرة
                        backgroundColor: Colors.white,
                        // الأيقونة داخل الدائرة - تتغير حسب نوع المستخدم
                        child: Icon(
                          // إذا كان المستخدم ضيف - أيقونة شخص، وإلا - أيقونة مشرف
                          user?.isAnonymous == true
                              ? Icons.person_outline
                              : Icons.admin_panel_settings,
                          // حجم الأيقونة 36 بكسل
                          size: 36,
                          // لون الأيقونة - اللون الأساسي من الموضوع
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    // مسافة فارغة بعرض 20 بكسل - بين الصورة والنص
                    const SizedBox(width: 20),
                    // عنصر قابل للتوسع - Expanded يأخذ المساحة المتبقية
                    Expanded(
                      // عمود رأسي - لترتيب النصوص فوق بعضها
                      child: Column(
                        // محاذاة النصوص إلى البداية
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // قائمة عناصر العمود
                        children: [
                          // نص الترحيب - يتغير حسب اللغة
                          Text(
                            // إذا عربي - "مرحباً بك!"، وإلا - "Welcome Back!"
                            isRTL ? 'مرحباً بك!' : 'Welcome Back!',
                            // نمط النص - أبيض شفاف 70%، حجم 14
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          // مسافة فارغة بارتفاع 4 بكسل - بين النصوص
                          const SizedBox(height: 4),
                          // اسم المستخدم أو "Guest User"
                          Text(
                            // تحديد النص حسب نوع المستخدم
                            user?.isAnonymous == true
                                ? (isRTL ? 'مستخدم ضيف' : 'Guest User')
                                : (user?.email?.split('@').first ?? 'Admin'),
                            // نمط النص - أبيض كامل، حجم 22، عريض
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // إذا كان للمستخدم بريد إلكتروني - عرض البريد
                          if (user?.email != null) ...[
                            // مسافة فارغة بارتفاع 4 بكسل
                            const SizedBox(height: 4),
                            // البريد الإلكتروني للمستخدم
                            Text(
                              // عرض البريد الإلكتروني - غير null بسبب الشرط أعلاه
                              user!.email!,
                              // نمط النص - أبيض شفاف 70%، حجم 12
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              // قص النص بنقاط ... إذا كان طويلاً
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // صندوق سهم الانتقال - للجمالية
                    Container(
                      // حشوة 8 بكسل داخلية
                      padding: const EdgeInsets.all(8),
                      // تزيين بخلفية شفافة وحواف دائرية
                      decoration: BoxDecoration(
                        // خلفية بيضاء شفافة 20%
                        color: Colors.white.withOpacity(0.2),
                        // حواف دائرية بنصف قطر 12 بكسل
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // أيقونة سهم للأمام - باللون الأبيض
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // مسافة فارغة بارتفاع 24 بكسل - بعد قسم الترحيب
              const SizedBox(height: 24),

              // قسم الإحصائيات - Statistics Section
              Text(
                // عنوان القسم - يتغير حسب اللغة
                isRTL ? 'الإحصائيات' : 'Statistics',
                // نمط العنوان - كبير وعريض
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              // مسافة فارغة بارتفاع 12 بكسل - بعد العنوان
              const SizedBox(height: 12),

              // إذا كان جاري التحميل - عرض مؤشر التحميل
              if (_isLoading)
                const Center(
                  // حشوة 32 بكسل حول المؤشر
                  child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                )
              // وإلا - عرض شبكة الإحصائيات
              else
                // شبكة بعدد أعمدة محدد - GridView
                GridView.count(
                  // عدد الأعمدة في الشبكة - 2 عمود
                  crossAxisCount: 2,
                  // قص حجم الشبكة حسب المحتوى - لا تملأ الشاشة
                  shrinkWrap: true,
                  // منع التمرير داخل الشبكة - لأن الصفحة كاملة قابلة للتمرير
                  physics: const NeverScrollableScrollPhysics(),
                  // المسافة العمودية بين العناصر - 16 بكسل
                  mainAxisSpacing: 16,
                  // المسافة الأفقية بين العناصر - 16 بكسل
                  crossAxisSpacing: 16,
                  // نسبة العرض إلى الارتفاع لكل عنصر - 1.1
                  childAspectRatio: 1.1,
                  // قائمة عناصر الشبكة
                  children: [
                    // بطاقة إحصائيات الأطباء
                    StatTile(
                      // التسمية بالإنجليزية
                      label: 'Doctors',
                      // التسمية بالعربية
                      labelAr: 'الأطباء',
                      // القيمة - عدد الأطباء كنص
                      value: _doctorsCount.toString(),
                      // أيقونة الطب
                      icon: Icons.medical_services_rounded,
                      // اللون الأزرق
                      color: const Color(0xFF3B82F6),
                      // عند الضغط - الانتقال إلى صفحة الأطباء
                      onTap: () => Navigator.pushNamed(context, '/doctors'),
                    ),
                    // بطاقة إحصائيات الممرضين
                    StatTile(
                      // التسمية بالإنجليزية
                      label: 'Nurses',
                      // التسمية بالعربية
                      labelAr: 'الممرضين',
                      // القيمة - عدد الممرضين كنص
                      value: _nursesCount.toString(),
                      // أيقونة المستشفى
                      icon: Icons.local_hospital_rounded,
                      // اللون الفيروزي
                      color: const Color(0xFF14B8A6),
                      // عند الضغط - الانتقال إلى صفحة الممرضين
                      onTap: () => Navigator.pushNamed(context, '/nurses'),
                    ),
                    // بطاقة إحصائيات المرضى
                    StatTile(
                      // التسمية بالإنجليزية
                      label: 'Patients',
                      // التسمية بالعربية
                      labelAr: 'المرضى',
                      // القيمة - عدد المرضى كنص
                      value: _patientsCount.toString(),
                      // أيقونة الأشخاص
                      icon: Icons.people_rounded,
                      // اللون الأخضر
                      color: const Color(0xFF10B981),
                      // عند الضغط - الانتقال إلى صفحة المرضى
                      onTap: () => Navigator.pushNamed(context, '/patients'),
                    ),
                    // بطاقة إحصائيات طلبات النقل
                    StatTile(
                      // التسمية بالإنجليزية
                      label: 'Transport',
                      // التسمية بالعربية
                      labelAr: 'طلبات النقل',
                      // القيمة - عدد الطلبات المعلقة كنص
                      value: _pendingTransports.toString(),
                      // أيقونة الشحن
                      icon: Icons.local_shipping_rounded,
                      // اللون البرتقالي
                      color: const Color(0xFFF59E0B),
                      // عند الضغط - الانتقال إلى صفحة طلبات النقل
                      onTap: () => Navigator.pushNamed(context, '/transport/requests'),
                    ),
                  ],
                ),

              // مسافة فارغة بارتفاع 24 بكسل - بعد شبكة الإحصائيات
              const SizedBox(height: 24),

              // قسم الإجراءات السريعة - Quick Actions Section
              Row(
                // قائمة عناصر الصف
                children: [
                  // أيقونة البرق - للإشارة إلى السرعة
                  Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 28),
                  // مسافة فارغة بعرض 8 بكسل
                  const SizedBox(width: 8),
                  // عنوان القسم
                  Text(
                    // النص يتغير حسب اللغة
                    isRTL ? 'الإجراءات السريعة' : 'Quick Actions',
                    // نمط العنوان - كبير وعريض
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // مسافة فارغة بارتفاع 16 بكسل
              const SizedBox(height: 16),

              // بطاقة إجراء - إدارة الأطباء
              _buildActionCard(
                // السياق الحالي - لاستخدام الموضوع والتنقل
                context,
                // العنوان بالإنجليزية
                title: 'Manage Doctors',
                // العنوان بالعربية
                titleAr: 'إدارة الأطباء',
                // الوصف
                subtitle: 'View, add, and edit doctors',
                // الأيقونة
                icon: Icons.medical_services_rounded,
                // اللون الأزرق
                iconColor: const Color(0xFF3B82F6),
                // عند الضغط - الانتقال لصفحة الأطباء
                onTap: () => Navigator.pushNamed(context, '/doctors'),
              ),
              // مسافة فارغة بارتفاع 12 بكسل - بين البطاقات
              const SizedBox(height: 12),

              // بطاقة إجراء - إدارة الممرضين
              _buildActionCard(
                context,
                title: 'Manage Nurses',
                titleAr: 'إدارة الممرضين',
                subtitle: 'View, add, and edit nurses',
                icon: Icons.local_hospital_rounded,
                iconColor: const Color(0xFF14B8A6),
                onTap: () => Navigator.pushNamed(context, '/nurses'),
              ),
              const SizedBox(height: 12),

              // بطاقة إجراء - إدارة المرضى
              _buildActionCard(
                context,
                title: 'Manage Patients',
                titleAr: 'إدارة المرضى',
                subtitle: 'View, add, and edit patients',
                icon: Icons.people_rounded,
                iconColor: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, '/patients'),
              ),
              const SizedBox(height: 12),

              // بطاقة إجراء - المنشورات
              _buildActionCard(
                context,
                title: 'Publications',
                titleAr: 'المنشورات',
                subtitle: 'Manage articles and announcements',
                icon: Icons.article_rounded,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, '/publications'),
              ),
              const SizedBox(height: 12),

              // بطاقة إجراء - إرسال الإشعارات
              _buildActionCard(
                context,
                title: 'Send Notifications',
                titleAr: 'إرسال إشعارات',
                subtitle: 'Send push notifications to users',
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFEF4444),
                onTap: () => Navigator.pushNamed(context, '/notifications/create'),
              ),
              const SizedBox(height: 12),

              // بطاقة إجراء - طلبات النقل
              _buildActionCard(
                context,
                title: 'Transport Requests',
                titleAr: 'طلبات النقل',
                subtitle: 'Manage transportation requests',
                icon: Icons.local_shipping_rounded,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => Navigator.pushNamed(context, '/transport/requests'),
              ),

              // مسافة فارغة بارتفاع 24 بكسل - في نهاية الصفحة
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء بطاقة إجراء - Widget لإعادة الاستخدام
  Widget _buildActionCard(
    // السياق - لاستخدام الموضوع والتنقل
    BuildContext context, {
    // العنوان بالإنجليزية - إلزامي
    required String title,
    // العنوان بالعربية - إلزامي
    required String titleAr,
    // الوصف - إلزامي
    required String subtitle,
    // الأيقونة - إلزامية
    required IconData icon,
    // لون الأيقونة - إلزامي
    required Color iconColor,
    // الدالة المنفذة عند الضغط - إلزامية
    required VoidCallback onTap,
  }) {
    // الحصول على الموضوع الحالي
    final theme = Theme.of(context);
    // التحقق من اتجاه النص - عربي أم إنجليزي
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // اختيار العنوان المناسب حسب اللغة
    final displayTitle = isRTL ? titleAr : title;

    // بطاقة بتصميم Material Design
    return Card(
      // ارتفاع الظل - 2 بكسل
      elevation: 2,
      // شكل البطاقة - حواف دائرية 16 بكسل
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // عنصر قابل للضغط مع تأثير موجي
      child: InkWell(
        // تنفيذ الدالة عند الضغط
        onTap: onTap,
        // حواف التأثير الموجي - مطابقة للبطاقة
        borderRadius: BorderRadius.circular(16),
        // حشوة داخلية للمحتوى
        child: Padding(
          // حشوة 16 بكسل من كل الجوانب
          padding: const EdgeInsets.all(16),
          // صف أفقي - لترتيب العناصر جنباً إلى جنب
          child: Row(
            // قائمة العناصر
            children: [
              // صندوق الأيقونة مع خلفية ملونة
              Container(
                // حشوة 12 بكسل حول الأيقونة
                padding: const EdgeInsets.all(12),
                // تزيين - خلفية بلون الأيقونة الشفاف 10%
                decoration: BoxDecoration(
                  // لون الخلفية
                  color: iconColor.withOpacity(0.1),
                  // حواف دائرية 12 بكسل
                  borderRadius: BorderRadius.circular(12),
                ),
                // الأيقونة
                child: Icon(icon, color: iconColor, size: 28),
              ),
              // مسافة فارغة بعرض 16 بكسل - بين الأيقونة والنص
              const SizedBox(width: 16),
              // عنصر قابل للتوسع - يأخذ المساحة المتبقية
              Expanded(
                // عمود رأسي - للنصوص
                child: Column(
                  // محاذاة النصوص إلى البداية
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // قائمة العناصر
                  children: [
                    // العنوان الرئيسي
                    Text(
                      // النص المختار حسب اللغة
                      displayTitle,
                      // نمط النص - متوسط وعريض
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // مسافة فارغة بارتفاع 4 بكسل
                    const SizedBox(height: 4),
                    // الوصف
                    Text(
                      // نص الوصف
                      subtitle,
                      // نمط النص - صغير ومعتم قليلاً
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // أيقونة سهم صغيرة - للإشارة للتنقل
              Icon(
                // أيقونة سهم للأمام (iOS style)
                Icons.arrow_forward_ios,
                // حجم صغير 16 بكسل
                size: 16,
                // لون معتم قليلاً
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
