// Doctor Model
// نموذج بيانات الطبيب - يمثل الهيكل الأساسي لبيانات الطبيب
// Model = Class يحتوي على البيانات فقط بدون منطق معقد
// يُستخدم لنقل البيانات بين Firestore والتطبيق
class DoctorModel {
  // معرف الطبيب الفريد - ID من Firestore
  // final = لا يمكن تغييره بعد الإنشاء
  final String id;
  
  // اسم الطبيب الكامل - مطلوب
  final String name;
  
  // التخصص الطبي - مثل "القلب", "الأطفال", "الجراحة"
  final String specialty; // التخصص
  
  // البريد الإلكتروني - مطلوب للتواصل
  final String email;
  
  // رقم الهاتف - اختياري (يمكن أن يكون null)
  // String? = nullable string
  final String? phone;
  
  // رابط صورة الطبيب - اختياري (يمكن أن يكون null)
  final String? photoUrl;
  
  // حالة الطبيب - 'active' (نشط), 'inactive' (غير نشط), 'suspended' (موقوف)
  // يُستخدم لتفعيل/تعطيل حساب الطبيب
  final String status; // 'active', 'inactive', 'suspended'
  
  // ملاحظات إضافية - اختيارية (مثل معلومات إدارية)
  final String? notes;
  
  // تاريخ إنشاء السجل - يُحفظ تلقائياً عند الإضافة
  final DateTime createdAt;
  
  // تاريخ آخر تحديث - اختياري (null إذا لم يُحدث أبداً)
  final DateTime? updatedAt;

  // المُنشئ - Constructor لإنشاء كائن DoctorModel
  // required = معامل إلزامي يجب توفيره
  // معاملات بدون required اختيارية (optional)
  DoctorModel({
    // معرف فريد - مطلوب
    required this.id,
    // الاسم - مطلوب
    required this.name,
    // التخصص - مطلوب
    required this.specialty,
    // البريد الإلكتروني - مطلوب
    required this.email,
    // رقم الهاتف - اختياري
    this.phone,
    // رابط الصورة - اختياري
    this.photoUrl,
    // الحالة - افتراضياً 'active' إذا لم يُحدد
    this.status = 'active',
    // الملاحظات - اختيارية
    this.notes,
    // تاريخ الإنشاء - مطلوب
    required this.createdAt,
    // تاريخ التحديث - اختياري
    this.updatedAt,
  });

  // From Firestore
  // إنشاء كائن DoctorModel من بيانات Firestore - تحويل Map إلى Object
  // factory constructor = مُنشئ مصنعي يُرجع كائن جاهز
  // Map<String, dynamic> = مثل JSON في Firestore
  // id = معرف الوثيقة (يأتي منفصلاً في Firestore)
  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      // معرف الوثيقة من Firestore
      id: id,
      // الاسم - استخدام ?? '' كقيمة افتراضية إذا كان null
      name: map['name'] ?? '',
      // التخصص - قيمة افتراضية فارغة
      specialty: map['specialty'] ?? '',
      // البريد الإلكتروني - قيمة افتراضية فارغة
      email: map['email'] ?? '',
      // رقم الهاتف - يمكن أن يكون null
      phone: map['phone'],
      // رابط الصورة - يمكن أن يكون null
      photoUrl: map['photoUrl'],
      // الحالة - افتراضياً 'active' إذا لم يُحدد
      status: map['status'] ?? 'active',
      // الملاحظات - يمكن أن تكون null
      notes: map['notes'],
      // تاريخ الإنشاء - تحويل Timestamp من Firestore إلى DateTime
      // toDate() تحول Firestore Timestamp إلى DateTime
      // ?? DateTime.now() = استخدام الوقت الحالي إذا كان null
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      // تاريخ التحديث - تحويل Timestamp أو null
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // To Firestore
  // تحويل كائن DoctorModel إلى Map لحفظه في Firestore
  // Map<String, dynamic> = يُحول إلى JSON في Firestore
  Map<String, dynamic> toMap() {
    return {
      // اسم الحقل في Firestore: القيمة
      'name': name,
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      // تاريخ التحديث - استخدام الوقت الحالي إذا كان null
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  // Copy With - إنشاء نسخة من الكائن مع تعديل بعض الحقول
  // مفيد للتحديثات - نسخ الكائن مع تغيير حقل واحد فقط
  // جميع المعاملات اختيارية - فقط المُحدد منها سيتغير
  DoctorModel copyWith({
    // معاملات اختيارية - nullable للسماح بـ null كقيمة جديدة
    String? name,
    String? specialty,
    String? email,
    String? phone,
    String? photoUrl,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      // المعرف لا يتغير - نفس القيمة دائماً
      id: id,
      // إذا تم توفير name جديد استخدمه، وإلا احتفظ بالقديم
      // ?? = null coalescing operator
      name: name ?? this.name,
      // نفس المنطق لبقية الحقول
      specialty: specialty ?? this.specialty,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      // تاريخ الإنشاء لا يتغير - نفس القيمة دائماً
      createdAt: createdAt,
      // تاريخ التحديث - استخدام الوقت الحالي إذا لم يُحدد
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
