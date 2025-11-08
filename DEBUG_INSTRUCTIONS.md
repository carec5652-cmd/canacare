# 🐛 تعليمات Debug للمشكلة

## المشكلة:
عند تسجيل الدخول بمعلومات صحيحة، يرجعك لشاشة Login

---

## الحل السريع (بدون Firebase):

### اختبر الكود أولاً:

1. **شغل التطبيق:**
```bash
cd "C:\Users\User\Desktop\this is final\flutter_application_1"
flutter run
```

2. **اضغط على "Continue as Guest"**
   - إذا دخلت للـ Dashboard بنجاح ← الكود يعمل ✅
   - المشكلة فقط في Firebase Setup

---

## إذا كان الكود يعمل مع Guest:

معناها **100%** المشكلة هي:
- ❌ لا يوجد admin document في Firestore
- ❌ أو Firestore Rules تمنع القراءة

---

## الحل النهائي:

### الخطوة 1: افتح Firebase Console

اذهب إلى:
```
https://console.firebase.google.com
```

---

### الخطوة 2: افحص Authentication

1. من القائمة الجانبية → **Authentication**
2. اضغط على تبويب **Users**
3. **ابحث عن المستخدم** الذي تسجل به
4. **انسخ UID** (سيكون شيء مثل: `xYz123AbC456DeF789`)

**مثال:**
```
Email: admin@example.com
UID: xYz123AbC456DeF789  ← انسخ هذا!
```

---

### الخطوة 3: اذهب إلى Firestore Database

1. من القائمة الجانبية → **Firestore Database**
2. إذا كانت فارغة → اضغط **Create database**
3. اختر **Test mode** (مؤقت)
4. اضغط **Enable**

---

### الخطوة 4: أنشئ Collection اسمها admins

1. اضغط **Start collection**
2. Collection ID: اكتب `admins` بالضبط
3. اضغط **Next**

---

### الخطوة 5: أضف Document

**مهم جداً:** Document ID = UID الذي نسخته!

1. **Document ID:** الصق الـ UID هنا (مثال: `xYz123AbC456DeF789`)
2. أضف الحقول:

| Field | Type | Value |
|-------|------|-------|
| email | string | admin@example.com |
| name | string | Admin User |
| role | string | **admin** |
| createdAt | timestamp | اضغط الساعة واختر التاريخ |
| isActive | boolean | true |

3. اضغط **Save**

---

### الخطوة 6: تحديث Firestore Rules

1. في Firestore Database، اضغط على تبويب **Rules**
2. الصق هذا الكود:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. اضغط **Publish**

---

### الخطوة 7: جرب Login الآن

1. أغلق التطبيق وشغله مرة أخرى
2. سجل دخول بنفس البريد الإلكتروني
3. يجب أن يدخل للـ Dashboard ✅

---

## ✅ كيف تتأكد أن كل شيء صحيح:

بعد إضافة الـ document، يجب أن تبدو هيكلة Firestore هكذا:

```
Firestore Database
└── admins (collection)
    └── xYz123AbC456DeF789 (document)
        ├── email: "admin@example.com"
        ├── name: "Admin User"
        ├── role: "admin"
        ├── createdAt: Timestamp
        └── isActive: true
```

---

## 📸 مثال بالصور:

### في Authentication:
```
Users Tab:
┌─────────────────────────────────────────┐
│ Email: admin@example.com                │
│ UID: xYz123AbC456DeF789                 │ ← انسخ هذا
│ Created: 2025-11-08                     │
└─────────────────────────────────────────┘
```

### في Firestore:
```
admins (collection)
└── xYz123AbC456DeF789 (document ID = UID)
    ├── email: "admin@example.com"
    ├── name: "Admin User"
    ├── role: "admin"  ← مهم جداً!
    ├── createdAt: [timestamp]
    └── isActive: true
```

---

## 🆘 إذا ما زالت المشكلة:

أرسل لي:
1. Screenshot من Authentication Users
2. Screenshot من Firestore admins collection
3. الـ UID الذي تستخدمه

---

## 🎯 ملاحظة نهائية:

**Document ID في Firestore MUST = UID في Authentication**

إذا لم يكونا متطابقين، لن يعمل!

❌ خطأ:
- Authentication UID: `abc123`
- Firestore Document ID: `xyz789`

✅ صحيح:
- Authentication UID: `abc123`
- Firestore Document ID: `abc123`

---

**جرب هذه الخطوات واخبرني!** 🚀

