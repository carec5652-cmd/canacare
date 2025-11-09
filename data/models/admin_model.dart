// Admin Model - نموذج بيانات المشرف
// يمثل بنية بيانات مشرف النظام (Admin) في قاعدة البيانات
class AdminModel {
  final String uid; // معرف المشرف الفريد (User ID من Firebase Authentication)
  final String email; // البريد الإلكتروني
  final String displayName; // اسم العرض
  final String? phone; // رقم الهاتف (اختياري)
  final String? photoUrl; // رابط صورة المشرف (اختياري)
  final String role; // الدور: 'admin' (مشرف) أو 'superadmin' (مشرف أعلى)
  final String? preferredLocale; // اللغة المفضلة: 'en' (إنجليزي) أو 'ar' (عربي)
  final String? preferredTheme; // الثيم المفضل: 'light' (فاتح) أو 'dark' (داكن)
  final DateTime createdAt; // تاريخ إنشاء الحساب
  final DateTime? lastLogin; // تاريخ آخر تسجيل دخول (اختياري)

  // المُنشئ - Constructor
  AdminModel({
    required this.uid, // مطلوب: معرف المشرف
    required this.email, // مطلوب: البريد الإلكتروني
    required this.displayName, // مطلوب: اسم العرض
    this.phone, // اختياري: رقم الهاتف
    this.photoUrl, // اختياري: رابط الصورة
    this.role = 'admin', // افتراضي: 'admin'
    this.preferredLocale, // اختياري: اللغة المفضلة
    this.preferredTheme, // اختياري: الثيم المفضل
    required this.createdAt, // مطلوب: تاريخ الإنشاء
    this.lastLogin, // اختياري: تاريخ آخر تسجيل دخول
  });

  // From Firestore - تحويل من Firestore Map إلى AdminModel
  // دالة مصنع لإنشاء كائن AdminModel من بيانات Firestore
  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminModel(
      uid: id, // معرف المستند في Firestore
      email: map['email'] ?? '', // البريد الإلكتروني (افتراضي: سلسلة فارغة)
      displayName: map['displayName'] ?? '', // اسم العرض (افتراضي: سلسلة فارغة)
      phone: map['phone'], // رقم الهاتف (null إذا لم يوجد)
      photoUrl: map['photoUrl'], // رابط الصورة (null إذا لم يوجد)
      role: map['role'] ?? 'admin', // الدور (افتراضي: 'admin')
      preferredLocale: map['preferredLocale'], // اللغة المفضلة (null إذا لم توجد)
      preferredTheme: map['preferredTheme'], // الثيم المفضل (null إذا لم يوجد)
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(), // تاريخ الإنشاء (افتراضي: الآن)
      lastLogin: map['lastLogin']?.toDate(), // تاريخ آخر تسجيل دخول (null إذا لم يوجد)
    );
  }

  // To Firestore - تحويل من AdminModel إلى Firestore Map
  // دالة لتحويل كائن AdminModel إلى Map لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email, // البريد الإلكتروني
      'displayName': displayName, // اسم العرض
      'phone': phone, // رقم الهاتف
      'photoUrl': photoUrl, // رابط الصورة
      'role': role, // الدور
      'preferredLocale': preferredLocale, // اللغة المفضلة
      'preferredTheme': preferredTheme, // الثيم المفضل
      'createdAt': createdAt, // تاريخ الإنشاء
      'lastLogin': lastLogin, // تاريخ آخر تسجيل دخول
    };
  }

  // copyWith - إنشاء نسخة معدّلة من الكائن
  // دالة لإنشاء نسخة جديدة من AdminModel مع تعديل بعض الحقول
  AdminModel copyWith({
    String? displayName, // اسم العرض الجديد (اختياري)
    String? phone, // رقم الهاتف الجديد (اختياري)
    String? photoUrl, // رابط الصورة الجديد (اختياري)
    String? preferredLocale, // اللغة المفضلة الجديدة (اختياري)
    String? preferredTheme, // الثيم المفضل الجديد (اختياري)
    DateTime? lastLogin, // تاريخ آخر تسجيل دخول الجديد (اختياري)
  }) {
    return AdminModel(
      uid: uid, // الإبقاء على معرف المشرف كما هو
      email: email, // الإبقاء على البريد الإلكتروني كما هو
      displayName: displayName ?? this.displayName, // استخدام القيمة الجديدة أو الحالية
      phone: phone ?? this.phone, // استخدام القيمة الجديدة أو الحالية
      photoUrl: photoUrl ?? this.photoUrl, // استخدام القيمة الجديدة أو الحالية
      role: role, // الإبقاء على الدور كما هو
      preferredLocale: preferredLocale ?? this.preferredLocale, // استخدام القيمة الجديدة أو الحالية
      preferredTheme: preferredTheme ?? this.preferredTheme, // استخدام القيمة الجديدة أو الحالية
      createdAt: createdAt, // الإبقاء على تاريخ الإنشاء كما هو
      lastLogin: lastLogin ?? this.lastLogin, // استخدام القيمة الجديدة أو الحالية
    );
  }
}
