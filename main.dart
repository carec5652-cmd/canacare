// استيراد مكتبة Material Design من Flutter - لواجهة المستخدم
import 'package:flutter/material.dart';
// استيراد مكتبة Provider - لإدارة حالة التطبيق (state management)
import 'package:provider/provider.dart';
// استيراد Firebase Core - للاتصال مع خدمات Firebase
import 'package:firebase_core/firebase_core.dart';
// استيراد Firebase Auth - للتحقق من حالة تسجيل الدخول
import 'package:firebase_auth/firebase_auth.dart';
// استيراد localization delegates - لدعم اللغات المتعددة (عربي/إنجليزي)
import 'package:flutter_localizations/flutter_localizations.dart';

// استيراد ملف المسارات - يحتوي على جميع روابط الصفحات في التطبيق
import 'package:admin_can_care/config/routes.dart';
// استيراد إعدادات FCM - يحتوي على مفتاح الخادم للإشعارات
import 'package:admin_can_care/config/fcm_config.dart';
// استيراد شاشة تسجيل الدخول - الصفحة الأولى للمستخدمين غير المسجلين
import 'package:admin_can_care/ui/screens/auth/admin_login_screen.dart';
// استيراد شاشة لوحة التحكم - الصفحة الرئيسية بعد تسجيل الدخول
import 'package:admin_can_care/ui/screens/dashboard/dashboard_screen.dart';
// استيراد خدمة المصادقة - للتحقق من صلاحيات المشرف
import 'package:admin_can_care/data/services/firebase_auth_service.dart';
// استيراد خدمة FCM - لإدارة الإشعارات Push Notifications
import 'package:admin_can_care/data/services/fcm_service.dart';
// استيراد موفر حالة التطبيق - لإدارة الموضوع واللغة
import 'package:admin_can_care/provider/app_state_provider.dart';
// استيراد موضوع التطبيق - الألوان والأنماط
import 'package:admin_can_care/theme/app_theme.dart';
// استيراد خيارات Firebase - تُولد تلقائياً من Firebase CLI
import 'firebase_options.dart';

// نقطة بداية التطبيق - أول دالة تُنفذ عند تشغيل التطبيق
// main function - entry point of the application
Future<void> main() async {
  // التأكد من تهيئة Flutter Binding - ضروري قبل استخدام أي خدمات Firebase
  // ensure Flutter widgets binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // تهيئة Firebase - الاتصال مع خدمات Firebase (Auth, Firestore, FCM...)
  // await = انتظار اكتمال العملية قبل المتابعة
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM Service
  // تهيئة خدمة FCM - لإدارة الإشعارات Push Notifications
  // Update your FCM Server Key in: lib/config/fcm_config.dart
  // قم بتحديث مفتاح خادم FCM في: lib/config/fcm_config.dart
  await FCMService().initialize(serverKey: FCMConfig.serverKey);

  // Subscribe all app users to 'all_users' topic for broadcast notifications
  // اشتراك جميع مستخدمي التطبيق في موضوع 'all_users' - لاستقبال الإشعارات العامة
  // على الموبايل فقط - Web لا يدعم Topics
  await FCMService().subscribeToTopic('all_users');

  // Get and display FCM token for this device/browser
  // الحصول على رمز FCM لهذا الجهاز/المتصفح - لإرسال إشعارات مخصصة
  final token = await FCMService().getToken();
  // إذا تم الحصول على الرمز بنجاح
  if (token != null) {
    // طباعة الرمز في console المطورين - للتتبع والتشخيص
    debugPrint('🔑 Your FCM Token: $token');
    // رسالة تأكيد - أن الجهاز/المتصفح سيستقبل الإشعارات
    debugPrint('💡 This device/browser will receive notifications!');
  }

  // تشغيل التطبيق - runApp هي الدالة التي تبدأ واجهة Flutter
  // ChangeNotifierProvider يوفر AppStateProvider لجميع أجزاء التطبيق
  // create: يُنشئ كائن AppStateProvider عند بداية التطبيق
  runApp(ChangeNotifierProvider(create: (_) => AppStateProvider(), child: const MainApp()));
}

// الصف الرئيسي للتطبيق - يحتوي على إعدادات التطبيق الأساسية
// Main App Widget - contains core app configuration
class MainApp extends StatelessWidget {
  // المُنشئ - const للأداء (compile-time constant)
  const MainApp({super.key});

  @override
  // دالة build - تبني واجهة التطبيق
  Widget build(BuildContext context) {
    // الحصول على حالة التطبيق من Provider - للوصول للموضوع واللغة
    final appState = Provider.of<AppStateProvider>(context);

    // MaterialApp - الجذر الأساسي لتطبيق Flutter Material Design
    return MaterialApp(
      // إخفاء شريط "Debug" في الزاوية - للإنتاج
      debugShowCheckedModeBanner: false,
      // عنوان التطبيق - يظهر في شريط المهام وعند التبديل بين التطبيقات
      title: 'Can Care Admin',
      // موضوع الوضع الفاتح - الألوان والأنماط للوضع النهاري
      theme: AppTheme.light(),
      // موضوع الوضع الداكن - الألوان والأنماط للوضع الليلي
      darkTheme: AppTheme.dark(),
      // وضع الموضوع الحالي - يأتي من appState (light/dark/system)
      themeMode: appState.themeMode,
      // اللغة الحالية - يأتي من appState (en/ar)
      locale: appState.locale,
      // مفوضو الترجمة - لدعم اللغات المحلية (تواريخ، أرقام، نصوص)
      localizationsDelegates: const [
        // مفوض Material Design - للنصوص الأساسية
        GlobalMaterialLocalizations.delegate,
        // مفوض Widgets - لنصوص الأدوات
        GlobalWidgetsLocalizations.delegate,
        // مفوض Cupertino - لنصوص iOS style
        GlobalCupertinoLocalizations.delegate,
      ],
      // اللغات المدعومة في التطبيق - الإنجليزية والعربية
      supportedLocales: const [Locale('en'), Locale('ar')],
      // دالة توليد المسارات - لإنشاء الصفحات حسب الاسم
      onGenerateRoute: AppRoutes.generateRoute,
      // الصفحة الرئيسية - AuthGate يتحكم في عرض تسجيل الدخول أو لوحة التحكم
      home: const AuthGate(),
    );
  }
}

// بوابة المصادقة - تتحكم في عرض الصفحة المناسبة حسب حالة تسجيل الدخول
// Authentication Gate - controls which screen to show based on auth state
class AuthGate extends StatelessWidget {
  // المُنشئ - const للأداء
  const AuthGate({super.key});

  @override
  // دالة build - تبني الواجهة المناسبة
  Widget build(BuildContext context) {
    // StreamBuilder - يستمع للتغيرات في حالة المصادقة ويعيد البناء تلقائياً
    return StreamBuilder<User?>(
      // الاستماع لتغيرات حالة المصادقة - عند تسجيل دخول/خروج
      stream: FirebaseAuth.instance.authStateChanges(),
      // دالة البناء - تُنفذ عند كل تغيير في Stream
      builder: (context, snapshot) {
        // إذا كان جاري الانتظار - عرض مؤشر تحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          // شاشة فارغة مع مؤشر تحميل دائري في الوسط
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // إذا كان المستخدم مسجل دخول - snapshot.hasData = true
        if (snapshot.hasData) {
          // الحصول على بيانات المستخدم - غير null لأن hasData = true
          final user = snapshot.data!;

          // Allow anonymous (guest) users to access dashboard
          // السماح للضيوف بالوصول للوحة التحكم - بدون التحقق من الصلاحيات
          if (user.isAnonymous) {
            // عرض لوحة التحكم مباشرة - للمستخدمين الضيوف
            return const DashboardScreen();
          }

          // Verify admin role for email users
          // التحقق من صلاحيات المشرف - للمستخدمين المسجلين بالبريد
          // FutureBuilder - ينتظر نتيجة التحقق من Firestore
          return FutureBuilder<bool>(
            // استدعاء دالة التحقق من كون المستخدم مشرف
            future: FirebaseAuthService().isAdmin(user.uid),
            // دالة البناء - تُنفذ عند اكتمال Future
            builder: (context, adminSnapshot) {
              // إذا كان جاري الانتظار - عرض مؤشر تحميل
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                // شاشة فارغة مع مؤشر تحميل
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // If admin verification succeeded
              // إذا كان التحقق ناجح - المستخدم مشرف (data = true)
              if (adminSnapshot.data == true) {
                // عرض لوحة التحكم - للمشرفين المصرح لهم
                return const DashboardScreen();
              }

              // Not an admin or no admin document found
              // ليس مشرفاً أو لم يتم العثور على وثيقة المشرف في Firestore
              // Sign out and show login screen
              // تسجيل الخروج وعرض شاشة تسجيل الدخول
              // addPostFrameCallback - تنفيذ بعد اكتمال رسم الإطار الحالي - لتجنب الأخطاء
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // تسجيل الخروج تلقائياً
                FirebaseAuth.instance.signOut();
              });
              // عرض شاشة تسجيل الدخول - لأن المستخدم ليس مشرفاً
              return const AdminLoginScreen();
            },
          );
        }

        // إذا لم يكن هناك بيانات مستخدم - snapshot.hasData = false
        // المستخدم غير مسجل دخول - عرض شاشة تسجيل الدخول
        return const AdminLoginScreen();
      },
    );
  }
}
