// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد خدمة المصادقة من Firebase - للتحقق من المستخدمين
import 'package:firebase_auth/firebase_auth.dart';
// استيراد خدمة Firebase Auth المخصصة - لعمليات تسجيل الدخول
import 'package:admin_can_care/data/services/firebase_auth_service.dart';
// استيراد خدمة FCM - لحفظ رمز الإشعارات عند تسجيل الدخول
import 'package:admin_can_care/data/services/fcm_service.dart';
// استيراد عنصر شاشة التحميل - لإظهار حالة المعالجة
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Admin Login Screen - شاشة تسجيل دخول المشرف
// الصفحة الأولى التي يراها المستخدم لتسجيل الدخول للنظام
// Path: /auth/login - المسار في التطبيق
class AdminLoginScreen extends StatefulWidget {
  // المُنشئ - يستقبل مفتاح اختياري
  const AdminLoginScreen({super.key});

  @override
  // إنشاء الحالة المتغيرة للصفحة - للتحكم في البيانات المتغيرة
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

// الحالة الخاصة بشاشة تسجيل الدخول - تحتوي على المنطق والبيانات
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // مفتاح النموذج - للتحقق من صحة البيانات المدخلة
  final _formKey = GlobalKey<FormState>();
  // متحكم حقل البريد الإلكتروني - للوصول إلى النص المدخل
  final _emailController = TextEditingController();
  // متحكم حقل كلمة المرور - للوصول إلى النص المدخل
  final _passwordController = TextEditingController();
  // كائن خدمة المصادقة - للتعامل مع Firebase Auth
  final _authService = FirebaseAuthService();

  // حالة التحميل - false = جاهز، true = جاري المعالجة
  bool _isLoading = false;
  // تذكرني - للحفاظ على تسجيل الدخول (غير مستخدم حالياً)
  bool _rememberMe = false;
  // إخفاء كلمة المرور - true = مخفية بنقاط، false = مرئية
  bool _obscurePassword = true;

  @override
  // دالة التنظيف - تُنفذ عند إغلاق الصفحة لتحرير الذاكرة
  void dispose() {
    // تحرير موارد متحكم البريد الإلكتروني
    _emailController.dispose();
    // تحرير موارد متحكم كلمة المرور
    _passwordController.dispose();
    // استدعاء الدالة الأساسية من الكلاس الأب
    super.dispose();
  }

  // Login Handler - معالج تسجيل الدخول
  // دالة معالجة تسجيل الدخول - تُنفذ عند الضغط على زر "تسجيل الدخول"
  Future<void> _handleLogin() async {
    // التحقق من صحة البيانات المدخلة - إذا فشلت التحققات، لا تكمل
    if (!_formKey.currentState!.validate()) return;

    // تحديث حالة التحميل إلى true - لإظهار شاشة التحميل
    setState(() => _isLoading = true);

    try {
      // Sign in with email & password
      // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
      final userCredential = await _authService.signInWithEmailAndPassword(
        // البريد الإلكتروني - من حقل الإدخال مع إزالة المسافات
        email: _emailController.text.trim(),
        // كلمة المرور - من حقل الإدخال
        password: _passwordController.text,
      );

      // التحقق من أن الصفحة لا تزال موجودة على الشاشة - لتجنب الأخطاء
      if (!mounted) return;

      // Check if user is admin
      // التحقق من أن المستخدم مشرف - من مجموعة admins في Firestore
      final isAdmin = await _authService.isAdmin(userCredential.user!.uid);

      // إذا لم يكن المستخدم مشرفاً
      if (!isAdmin) {
        // Not an admin, sign out
        // تسجيل خروج المستخدم - لأنه ليس مشرفاً
        await _authService.signOut();
        // التحقق من أن الصفحة لا تزال موجودة
        if (!mounted) return;
        // إظهار رسالة خطأ - الوصول محظور
        _showError(
          // العنوان - بالإنجليزية والعربية
          'Access Denied / الوصول محظور',
          // الرسالة - شرح المشكلة بلغتين
          'You do not have admin privileges. Please create an admin document in Firestore.\n\nليس لديك صلاحيات المشرف. يرجى إنشاء وثيقة مشرف في Firestore.',
        );
        // إيقاف حالة التحميل
        setState(() => _isLoading = false);
        // الخروج من الدالة
        return;
      }

      // Save FCM token for this admin (for push notifications)
      // حفظ رمز FCM لهذا المشرف - لاستقبال الإشعارات على المتصفح/الجهاز
      await FCMService().saveTokenToFirestore(
        // معرف المستخدم - من بيانات المصادقة
        userId: userCredential.user!.uid,
        // المجموعة في Firestore - admins
        collection: 'admins',
      );

      // Success - The AuthGate in main.dart will handle navigation automatically
      // نجح تسجيل الدخول - بوابة المصادقة في main.dart ستتولى التنقل تلقائياً
    } on FirebaseAuthException catch (e) {
      // معالجة أخطاء Firebase Auth - مثل بريد خاطئ أو كلمة مرور خاطئة
      // التحقق من أن الصفحة لا تزال موجودة
      if (!mounted) return;
      // إظهار رسالة الخطأ - فشل تسجيل الدخول
      _showError('Login Failed / فشل تسجيل الدخول', e.message ?? 'Unknown error');
    } catch (e) {
      // معالجة أي أخطاء أخرى - غير متوقعة
      // التحقق من أن الصفحة لا تزال موجودة
      if (!mounted) return;
      // إظهار رسالة خطأ عامة
      _showError('Error / خطأ', e.toString());
    } finally {
      // هذا الجزء يُنفذ دائماً - سواء نجحت العملية أو فشلت
      // التحقق من أن الصفحة لا تزال موجودة
      if (mounted) {
        // إيقاف حالة التحميل - لإخفاء شاشة التحميل
        setState(() => _isLoading = false);
      }
    }
  }

  // Guest Sign In - تسجيل الدخول كضيف
  // دالة تسجيل الدخول كضيف - بدون حساب مسبق
  Future<void> _handleGuestLogin() async {
    // بدء حالة التحميل
    setState(() => _isLoading = true);

    try {
      // تسجيل الدخول كضيف - باستخدام Firebase Anonymous Auth
      await _authService.signInAnonymously();
      // Success - The AuthGate will handle navigation
      // نجح تسجيل الدخول - بوابة المصادقة ستتولى التنقل
    } catch (e) {
      // معالجة أخطاء تسجيل الدخول كضيف
      // التحقق من أن الصفحة لا تزال موجودة
      if (!mounted) return;
      // إظهار رسالة الخطأ
      _showError('Error / خطأ', e.toString());
    } finally {
      // هذا الجزء يُنفذ دائماً
      // التحقق من أن الصفحة لا تزال موجودة
      if (mounted) {
        // إيقاف حالة التحميل
        setState(() => _isLoading = false);
      }
    }
  }

  // Show Error Dialog
  // دالة إظهار نافذة الخطأ - تعرض رسالة منبثقة
  void _showError(String title, String message) {
    // عرض نافذة حوار منبثقة
    showDialog(
      // السياق الحالي - للواجهة
      context: context,
      // بناء محتوى النافذة
      builder:
          (context) => AlertDialog(
            // عنوان النافذة - يظهر في الأعلى
            title: Text(title),
            // محتوى الرسالة - نص الخطأ
            content: Text(message),
            // أزرار النافذة
            actions: [
              // زر "OK" لإغلاق النافذة
              TextButton(
                // عند الضغط - إغلاق النافذة
                onPressed: () => Navigator.pop(context),
                // نص الزر
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Navigate to Forgot Password
  // دالة التنقل لصفحة نسيت كلمة المرور
  void _navigateToForgotPassword() {
    // الانتقال إلى صفحة استعادة كلمة المرور
    Navigator.pushNamed(context, '/auth/forgot-password');
  }

  @override
  // دالة بناء الواجهة - تُستدعى لرسم الصفحة على الشاشة
  Widget build(BuildContext context) {
    // الحصول على موضوع التطبيق الحالي - للألوان والأنماط
    final theme = Theme.of(context);
    // التحقق من اتجاه النص - true = عربي، false = إنجليزي
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // إرجاع هيكل الصفحة الأساسي
    return Scaffold(
      // محتوى الصفحة الرئيسي مع طبقة التحميل
      body: LoadingOverlay(
        // حالة التحميل - لإظهار/إخفاء شاشة التحميل
        isLoading: _isLoading,
        // رسالة التحميل بالإنجليزية
        message: 'Signing in...',
        // رسالة التحميل بالعربية
        messageAr: 'جاري تسجيل الدخول...',
        // محتوى الصفحة تحت طبقة التحميل
        child: Container(
          // تزيين الخلفية بتدرج لوني
          decoration: BoxDecoration(
            // تدرج لوني رأسي - من الأعلى للأسفل
            gradient: LinearGradient(
              // بداية التدرج - أعلى الشاشة
              begin: Alignment.topCenter,
              // نهاية التدرج - أسفل الشاشة
              end: Alignment.bottomCenter,
              // الألوان - اللون الأساسي شفاف 10% ثم لون السطح
              colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            ),
          ),
          // منطقة آمنة - تتجنب notch والشق في الشاشة
          child: SafeArea(
            // توسيط المحتوى في الشاشة
            child: Center(
              // محتوى قابل للتمرير - SingleChildScrollView
              child: SingleChildScrollView(
                // حشوة 24 بكسل من كل الجوانب
                padding: const EdgeInsets.all(24),
                // بطاقة تحتوي على نموذج تسجيل الدخول
                child: Card(
                  // ارتفاع الظل - 8 بكسل لعمق ثلاثي
                  elevation: 8,
                  // شكل البطاقة - حواف دائرية 16 بكسل
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  // محتوى البطاقة
                  child: Container(
                    // قيود على العرض - أقصى عرض 400 بكسل للشاشات الكبيرة
                    constraints: const BoxConstraints(maxWidth: 400),
                    // حشوة داخلية 32 بكسل
                    padding: const EdgeInsets.all(32),
                    // نموذج تسجيل الدخول
                    child: Form(
                      // مفتاح النموذج - للتحقق من الصحة
                      key: _formKey,
                      // عمود رأسي - لترتيب العناصر فوق بعضها
                      child: Column(
                        // حجم العمود - أصغر حجم ممكن حسب المحتوى
                        mainAxisSize: MainAxisSize.min,
                        // محاذاة العناصر للعرض الكامل
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        // قائمة عناصر النموذج
                        children: [
                          // Logo/Icon
                          // أيقونة المشرف - في أعلى النموذج
                          Icon(
                            // أيقونة لوحة إعدادات المشرف
                            Icons.admin_panel_settings,
                            // حجم الأيقونة - 80 بكسل
                            size: 80,
                            // اللون - اللون الأساسي من الموضوع
                            color: theme.colorScheme.primary,
                          ),
                          // مسافة فارغة بارتفاع 16 بكسل
                          const SizedBox(height: 16),

                          // Title
                          // عنوان الصفحة - "تسجيل دخول المشرف"
                          Text(
                            // النص يتغير حسب اللغة
                            isRTL ? 'تسجيل دخول المشرف' : 'Admin Login',
                            // محاذاة النص للوسط
                            textAlign: TextAlign.center,
                            // نمط النص - كبير وعريض
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // مسافة فارغة بارتفاع 8 بكسل
                          const SizedBox(height: 8),
                          // نص الترحيب - "مرحباً بك في نظام Can Care"
                          Text(
                            // النص يتغير حسب اللغة
                            isRTL ? 'مرحباً بك في نظام Can Care' : 'Welcome to Can Care System',
                            // محاذاة النص للوسط
                            textAlign: TextAlign.center,
                            // نمط النص - متوسط الحجم
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          // مسافة فارغة بارتفاع 32 بكسل
                          const SizedBox(height: 32),

                          // Email Field
                          // حقل إدخال البريد الإلكتروني
                          TextFormField(
                            // ربط المتحكم للوصول إلى القيمة
                            controller: _emailController,
                            // نوع لوحة المفاتيح - بريد إلكتروني (@، .com)
                            keyboardType: TextInputType.emailAddress,
                            // إجراء لوحة المفاتيح - الانتقال للحقل التالي
                            textInputAction: TextInputAction.next,
                            // تزيين الحقل
                            decoration: InputDecoration(
                              // تسمية الحقل - تتغير حسب اللغة
                              labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
                              // نص مساعد - placeholder
                              hintText: isRTL ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                              // أيقونة على يسار الحقل - أيقونة بريد
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            // دالة التحقق من الصحة - تُنفذ عند الضغط على تسجيل الدخول
                            validator: (value) {
                              // التحقق من أن الحقل ليس فارغاً
                              if (value == null || value.isEmpty) {
                                return isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                              }
                              // التحقق من وجود @ في البريد
                              if (!value.contains('@')) {
                                return isRTL ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                              }
                              // إذا نجحت جميع التحققات - إرجاع null (لا خطأ)
                              return null;
                            },
                          ),
                          // مسافة فارغة بارتفاع 16 بكسل - بين الحقول
                          const SizedBox(height: 16),

                          // Password Field
                          // حقل إدخال كلمة المرور
                          TextFormField(
                            // ربط المتحكم للوصول إلى القيمة
                            controller: _passwordController,
                            // إخفاء النص - حسب حالة _obscurePassword
                            obscureText: _obscurePassword,
                            // إجراء لوحة المفاتيح - تم (Done) لتنفيذ تسجيل الدخول
                            textInputAction: TextInputAction.done,
                            // عند الضغط على Done - تنفيذ تسجيل الدخول
                            onFieldSubmitted: (_) => _handleLogin(),
                            // تزيين الحقل
                            decoration: InputDecoration(
                              // تسمية الحقل - تتغير حسب اللغة
                              labelText: isRTL ? 'كلمة المرور' : 'Password',
                              // نص مساعد - placeholder
                              hintText: isRTL ? 'أدخل كلمة المرور' : 'Enter your password',
                              // أيقونة على يسار الحقل - أيقونة قفل
                              prefixIcon: const Icon(Icons.lock_outline),
                              // زر على يمين الحقل - لإظهار/إخفاء كلمة المرور
                              suffixIcon: IconButton(
                                // أيقونة العين - مفتوحة أو مغلقة
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                // عند الضغط - عكس حالة الإخفاء
                                onPressed: () {
                                  setState(() {
                                    // تبديل الحالة - من مخفي لمرئي أو العكس
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            // دالة التحقق من الصحة
                            validator: (value) {
                              // التحقق من أن الحقل ليس فارغاً
                              if (value == null || value.isEmpty) {
                                return isRTL ? 'كلمة المرور مطلوبة' : 'Password is required';
                              }
                              // التحقق من أن الطول 6 أحرف على الأقل
                              if (value.length < 6) {
                                return isRTL
                                    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                    : 'Password must be at least 6 characters';
                              }
                              // إذا نجحت التحققات - إرجاع null
                              return null;
                            },
                          ),
                          // مسافة فارغة بارتفاع 8 بكسل
                          const SizedBox(height: 8),

                          // Remember Me & Forgot Password
                          // صف يحتوي على "تذكرني" و "نسيت كلمة المرور"
                          Row(
                            // توزيع العناصر - مسافة بينهما
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // قائمة العناصر
                            children: [
                              // "تذكرني" - مربع اختيار مع نص
                              Row(
                                children: [
                                  // مربع الاختيار
                                  Checkbox(
                                    // القيمة الحالية - محددة أم لا
                                    value: _rememberMe,
                                    // عند التغيير - تحديث القيمة
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value!);
                                    },
                                  ),
                                  // نص "تذكرني"
                                  Text(
                                    isRTL ? 'تذكرني' : 'Remember me',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              // زر "نسيت كلمة المرور"
                              TextButton(
                                // عند الضغط - الانتقال لصفحة استعادة كلمة المرور
                                onPressed: _navigateToForgotPassword,
                                // نص الزر
                                child: Text(isRTL ? 'نسيت كلمة المرور؟' : 'Forgot password?'),
                              ),
                            ],
                          ),
                          // مسافة فارغة بارتفاع 24 بكسل
                          const SizedBox(height: 24),

                          // Login Button
                          // زر تسجيل الدخول الرئيسي
                          ElevatedButton(
                            // تعطيل الزر أثناء التحميل - لمنع التسجيل المتكرر
                            onPressed: _isLoading ? null : _handleLogin,
                            // تنسيق الزر
                            style: ElevatedButton.styleFrom(
                              // حشوة عمودية 16 بكسل - لزر أطول
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              // شكل الزر - حواف دائرية 12 بكسل
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // نص الزر
                            child: Text(
                              // يتغير حسب اللغة
                              isRTL ? 'تسجيل الدخول' : 'Log In',
                              // نمط النص - حجم 16، عريض
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // مسافة فارغة بارتفاع 16 بكسل
                          const SizedBox(height: 16),

                          // Divider
                          // خط فاصل مع كلمة "أو" في الوسط
                          Row(
                            children: [
                              // خط فاصل قابل للتوسع - يملأ المساحة المتبقية
                              const Expanded(child: Divider()),
                              // حشوة حول كلمة "أو"
                              Padding(
                                // حشوة أفقية 16 بكسل
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                // نص "أو"
                                child: Text(isRTL ? 'أو' : 'OR', style: theme.textTheme.bodySmall),
                              ),
                              // خط فاصل آخر - على الجانب الآخر
                              const Expanded(child: Divider()),
                            ],
                          ),

                          // مسافة فارغة بارتفاع 16 بكسل
                          const SizedBox(height: 16),

                          // Guest Sign In Button
                          // زر الدخول كضيف - بإطار فقط (غير ممتلئ)
                          OutlinedButton.icon(
                            // تعطيل الزر أثناء التحميل
                            onPressed: _isLoading ? null : _handleGuestLogin,
                            // تنسيق الزر
                            style: OutlinedButton.styleFrom(
                              // حشوة عمودية 16 بكسل
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              // شكل الزر - حواف دائرية 12 بكسل
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // أيقونة الزر - شخص
                            icon: const Icon(Icons.person_outline),
                            // نص الزر
                            label: Text(
                              // يتغير حسب اللغة
                              isRTL ? 'الدخول كضيف' : 'Continue as Guest',
                              // نمط النص - حجم 16، نصف عريض
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
