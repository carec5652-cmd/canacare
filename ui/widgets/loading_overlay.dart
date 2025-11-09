// استيراد مكتبة Material Design - لعناصر الواجهة
import 'package:flutter/material.dart';

// Loading Overlay Widget - تراكب التحميل
// عنصر يُظهر طبقة تحميل شفافة فوق المحتوى - لإظهار حالة المعالجة
// Shows a loading indicator overlay on the screen
// يستخدم عند العمليات التي تأخذ وقت: تسجيل دخول، إرسال بيانات، جلب معلومات...
class LoadingOverlay extends StatelessWidget {
  // حالة التحميل - true = إظهار طبقة التحميل، false = إخفاءها
  final bool isLoading;
  
  // المحتوى الأساسي - الصفحة أو العنصر تحت طبقة التحميل
  final Widget child;
  
  // رسالة التحميل بالإنجليزية - اختيارية (مثل "Signing in...")
  final String? message;
  
  // رسالة التحميل بالعربية - اختيارية (مثل "جاري تسجيل الدخول...")
  final String? messageAr;

  // المُنشئ - يستقبل المعاملات المطلوبة والاختيارية
  const LoadingOverlay({
    // المفتاح - لتحديد العنصر في شجرة الأدوات
    super.key,
    // حالة التحميل - مطلوبة
    required this.isLoading,
    // المحتوى الأساسي - مطلوب
    required this.child,
    // رسالة التحميل بالإنجليزية - اختيارية
    this.message,
    // رسالة التحميل بالعربية - اختيارية
    this.messageAr,
  });

  @override
  // دالة بناء الواجهة - تُرسم العنصر على الشاشة
  Widget build(BuildContext context) {
    // Stack - يكدس العناصر فوق بعضها (طبقات)
    return Stack(
      // قائمة الطبقات - من الأسفل للأعلى
      children: [
        // الطبقة الأولى (الأسفل) - المحتوى الأساسي
        child,
        // الطبقة الثانية (فوق المحتوى) - طبقة التحميل
        // if (isLoading) = تُعرض فقط إذا كان isLoading = true
        if (isLoading)
          // صندوق يغطي كامل الشاشة بلون شفاف داكن
          Container(
            // لون خلفية أسود شفاف 54% - لتعتيم المحتوى تحته
            color: Colors.black54,
            // توسيط محتوى الطبقة في الشاشة
            child: Center(
              // بطاقة بيضاء تحتوي على مؤشر التحميل والرسالة
              child: Card(
                // حشوة داخلية 24 بكسل - للتباعد الجميل
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  // عمود رأسي - لترتيب المؤشر والرسالة
                  child: Column(
                    // حجم العمود - أصغر حجم ممكن حسب المحتوى
                    mainAxisSize: MainAxisSize.min,
                    // قائمة العناصر في العمود
                    children: [
                      // مؤشر التحميل الدائري - الدوران اللانهائي
                      const CircularProgressIndicator(),
                      // إذا كان هناك رسالة - إظهارها
                      // if = شرط داخل قائمة، ...[] = spread operator لإضافة عدة عناصر
                      if (message != null || messageAr != null) ...[
                        // مسافة فارغة بارتفاع 16 بكسل - بين المؤشر والرسالة
                        const SizedBox(height: 16),
                        // نص الرسالة - يختار الرسالة المناسبة حسب اللغة
                        Text(
                          // دالة خاصة لاختيار الرسالة المناسبة
                          _getDisplayMessage(context),
                          // نمط النص - كبير من موضوع التطبيق
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // دالة خاصة للحصول على الرسالة المناسبة حسب اللغة
  // _ = underscore يعني private method (خاصة بهذا الكلاس)
  String _getDisplayMessage(BuildContext context) {
    // التحقق من اتجاه النص - true = عربي (RTL)
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // إذا كانت اللغة عربية AND هناك رسالة عربية - استخدامها
    if (isRTL && messageAr != null) return messageAr!;
    // وإلا - استخدام الرسالة الإنجليزية أو رسالة افتراضية
    // ?? = null coalescing - إذا كانت message null، استخدم الرسالة الافتراضية
    return message ?? 'Loading... / جاري التحميل...';
  }
}
