// Nurse Model - نموذج بيانات الممرض
// يمثل بنية بيانات ممرض في النظام
class NurseModel {
  final String id; // معرف الممرض الفريد
  final String name; // اسم الممرض
  final String department; // القسم الذي يعمل به الممرض
  final String email; // البريد الإلكتروني
  final String? phone; // رقم الهاتف (اختياري)
  final String? photoUrl; // رابط صورة الممرض (اختياري)
  final String status; // حالة الممرض: 'active' (نشط)، 'inactive' (غير نشط)، 'suspended' (معلق)
  final String? notes; // ملاحظات إضافية (اختياري)
  final DateTime createdAt; // تاريخ إضافة الممرض للنظام
  final DateTime? updatedAt; // تاريخ آخر تحديث (اختياري)

  // المُنشئ - Constructor
  NurseModel({
    required this.id, // مطلوب: معرف الممرض
    required this.name, // مطلوب: اسم الممرض
    required this.department, // مطلوب: القسم
    required this.email, // مطلوب: البريد الإلكتروني
    this.phone, // اختياري: رقم الهاتف
    this.photoUrl, // اختياري: رابط الصورة
    this.status = 'active', // افتراضي: 'active' (نشط)
    this.notes, // اختياري: الملاحظات
    required this.createdAt, // مطلوب: تاريخ الإنشاء
    this.updatedAt, // اختياري: تاريخ التحديث
  });

  // From Firestore - تحويل من Firestore Map إلى NurseModel
  factory NurseModel.fromMap(Map<String, dynamic> map, String id) {
    return NurseModel(
      id: id, // معرف المستند
      name: map['name'] ?? '', // الاسم (افتراضي: سلسلة فارغة)
      department: map['department'] ?? '', // القسم (افتراضي: سلسلة فارغة)
      email: map['email'] ?? '', // البريد الإلكتروني (افتراضي: سلسلة فارغة)
      phone: map['phone'], // رقم الهاتف (null إذا لم يوجد)
      photoUrl: map['photoUrl'], // رابط الصورة (null إذا لم يوجد)
      status: map['status'] ?? 'active', // الحالة (افتراضي: 'active')
      notes: map['notes'], // الملاحظات (null إذا لم توجد)
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(), // تاريخ الإنشاء
      updatedAt: map['updatedAt']?.toDate(), // تاريخ التحديث (null إذا لم يوجد)
    );
  }

  // To Firestore - تحويل من NurseModel إلى Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name, // الاسم
      'department': department, // القسم
      'email': email, // البريد الإلكتروني
      'phone': phone, // رقم الهاتف
      'photoUrl': photoUrl, // رابط الصورة
      'status': status, // الحالة
      'notes': notes, // الملاحظات
      'createdAt': createdAt, // تاريخ الإنشاء
      'updatedAt': updatedAt ?? DateTime.now(), // تاريخ التحديث (افتراضي: الآن)
    };
  }

  // copyWith - إنشاء نسخة معدّلة من الكائن
  NurseModel copyWith({
    String? name, // الاسم الجديد (اختياري)
    String? department, // القسم الجديد (اختياري)
    String? email, // البريد الإلكتروني الجديد (اختياري)
    String? phone, // رقم الهاتف الجديد (اختياري)
    String? photoUrl, // رابط الصورة الجديد (اختياري)
    String? status, // الحالة الجديدة (اختياري)
    String? notes, // الملاحظات الجديدة (اختياري)
    DateTime? updatedAt, // تاريخ التحديث الجديد (اختياري)
  }) {
    return NurseModel(
      id: id, // الإبقاء على المعرف كما هو
      name: name ?? this.name, // استخدام القيمة الجديدة أو الحالية
      department: department ?? this.department, // استخدام القيمة الجديدة أو الحالية
      email: email ?? this.email, // استخدام القيمة الجديدة أو الحالية
      phone: phone ?? this.phone, // استخدام القيمة الجديدة أو الحالية
      photoUrl: photoUrl ?? this.photoUrl, // استخدام القيمة الجديدة أو الحالية
      status: status ?? this.status, // استخدام القيمة الجديدة أو الحالية
      notes: notes ?? this.notes, // استخدام القيمة الجديدة أو الحالية
      createdAt: createdAt, // الإبقاء على تاريخ الإنشاء كما هو
      updatedAt: updatedAt ?? DateTime.now(), // استخدام القيمة الجديدة أو الوقت الحالي
    );
  }
}
