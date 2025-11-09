// استيراد مكتبة Material Design - لعناصر الواجهة
import 'package:flutter/material.dart';

// Stat Tile Widget - لوحة إحصائيات
// عنصر يُظهر بطاقة إحصائية مع رقم وأيقونة - مستخدم في لوحة التحكم
// Used for displaying statistics on dashboard - مثل عدد الأطباء، المرضى، إلخ
class StatTile extends StatelessWidget {
  // التسمية بالإنجليزية - مثل "Doctors"
  final String label;
  
  // التسمية بالعربية - Arabic label - مثل "الأطباء"
  // اختيارية - إذا لم تُحدد، تُستخدم الإنجليزية
  final String? labelAr;
  
  // القيمة - الرقم المراد عرضه (مثل "25")
  // String لأنه قد يحتوي على رموز (مثل "+5" أو "25%")
  final String value;
  
  // الأيقونة - رمز يمثل الإحصائية (مثل أيقونة طبيب، مريض...)
  final IconData icon;
  
  // اللون - لون الأيقونة والقيمة
  // اختياري - إذا لم يُحدد، يُستخدم اللون الأساسي من الموضوع
  final Color? color;
  
  // دالة عند الضغط - VoidCallback تُنفذ عند النقر على البطاقة
  // اختيارية - إذا كانت null، البطاقة غير قابلة للنقر
  final VoidCallback? onTap;

  // المُنشئ - يستقبل جميع المعاملات
  const StatTile({
    // المفتاح - لتحديد العنصر
    super.key,
    // التسمية الإنجليزية - مطلوبة
    required this.label,
    // التسمية العربية - اختيارية
    this.labelAr,
    // القيمة - مطلوبة
    required this.value,
    // الأيقونة - مطلوبة
    required this.icon,
    // اللون - اختياري
    this.color,
    // دالة الضغط - اختيارية
    this.onTap,
  });

  @override
  // دالة بناء الواجهة - تُرسم البطاقة الإحصائية
  Widget build(BuildContext context) {
    // الحصول على موضوع التطبيق - للألوان والأنماط
    final theme = Theme.of(context);
    // التحقق من اتجاه النص - true = عربي
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // اختيار التسمية المناسبة - عربية إذا كانت اللغة عربية AND محددة
    final displayLabel = isRTL && labelAr != null ? labelAr! : label;
    // تحديد اللون - استخدام المُحدد أو الأساسي من الموضوع
    final statColor = color ?? theme.primaryColor;

    // بطاقة Material Design - مع ظل وحواف دائرية
    return Card(
      // ارتفاع الظل - 2 بكسل للعمق الخفيف
      elevation: 2,
      // شكل البطاقة - حواف دائرية بنصف قطر 12 بكسل
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // InkWell - عنصر قابل للنقر مع تأثير موجي (ripple effect)
      child: InkWell(
        // دالة عند الضغط - تُنفذ onTap إذا كانت محددة
        onTap: onTap,
        // حواف التأثير الموجي - مطابقة لحواف البطاقة
        borderRadius: BorderRadius.circular(12),
        // صندوق المحتوى
        child: Container(
          // حشوة داخلية 20 بكسل - للتباعد
          padding: const EdgeInsets.all(20),
          // عمود رأسي - لترتيب الأيقونة والقيمة والتسمية
          child: Column(
            // محاذاة عمودية في الوسط
            mainAxisAlignment: MainAxisAlignment.center,
            // قائمة العناصر
            children: [
              // صندوق الأيقونة - دائري مع خلفية ملونة
              Container(
                // حشوة 12 بكسل حول الأيقونة
                padding: const EdgeInsets.all(12),
                // تزيين - دائرة بخلفية بلون الإحصائية (شفافية 10%)
                decoration: BoxDecoration(
                  // لون الخلفية - نفس لون الإحصائية مع شفافية
                  color: statColor.withOpacity(0.1),
                  // شكل دائري
                  shape: BoxShape.circle,
                ),
                // الأيقونة - بلون الإحصائية وحجم 32 بكسل
                child: Icon(icon, color: statColor, size: 32),
              ),
              // مسافة فارغة بارتفاع 12 بكسل - بين الأيقونة والقيمة
              const SizedBox(height: 12),
              // القيمة (الرقم) - كبيرة وعريضة وملونة
              Text(
                // النص - القيمة المراد عرضها
                value,
                // نمط النص - متوسط الحجم، عريض، ملون
                style: theme.textTheme.headlineMedium?.copyWith(
                  // وزن عريض - للتأكيد على الرقم
                  fontWeight: FontWeight.bold,
                  // اللون - نفس لون الإحصائية
                  color: statColor,
                ),
              ),
              // مسافة فارغة بارتفاع 4 بكسل - بين القيمة والتسمية
              const SizedBox(height: 4),
              // التسمية (الوصف) - صغيرة ومعتمة
              Text(
                // النص - التسمية المختارة حسب اللغة
                displayLabel,
                // محاذاة النص للوسط - لتجنب مشاكل النصوص الطويلة
                textAlign: TextAlign.center,
                // نمط النص - متوسط الحجم، معتم قليلاً
                style: theme.textTheme.bodyMedium?.copyWith(
                  // لون معتم - لجعلها أقل بروزاً من القيمة
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
