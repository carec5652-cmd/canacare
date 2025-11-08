# Can Care Admin Panel 🏥
# لوحة تحكم نظام Can Care الطبي

A comprehensive medical administration system built with Flutter and Firebase for managing doctors, nurses, patients, and medical operations.

نظام إداري طبي شامل مبني بـ Flutter و Firebase لإدارة الأطباء والممرضين والمرضى والعمليات الطبية.

---

## ✨ Features / المميزات

### 🔐 Authentication / المصادقة
- **Admin Login** - تسجيل دخول المشرفين
  - Email/Password authentication
  - Firebase Auth integration
  - Admin role verification
  - Remember me functionality
  - Forgot password with email reset

### 📊 Dashboard / لوحة التحكم
- **Statistics Overview** - نظرة عامة على الإحصائيات
  - Active doctors, nurses, and patients count
  - Pending transport requests
  - Quick action cards
  - Real-time data updates

### 👨‍⚕️ Doctors Management / إدارة الأطباء
- **Doctors List** - قائمة الأطباء
  - Search by name, specialty, or email
  - Filter by specialty and status
  - View active/inactive doctors
- **Doctor Details** - تفاصيل الطبيب
  - Complete profile information
  - Assigned patients list
  - Contact information
  - Status management
- **Add Doctor** - إضافة طبيب
  - Full form validation
  - Required fields: name, specialty, email
  - Optional: phone, photo, notes

### 👩‍⚕️ Nurses Management / إدارة الممرضين
- **Nurses List** - قائمة الممرضين
  - Search and filter functionality
  - Department-based filtering
  - Status management
- **Add Nurse** - إضافة ممرض
  - Complete nurse information form
  - Department assignment
  - Contact details

### 👤 Patients Management / إدارة المرضى
- **Patients List** - قائمة المرضى
  - Search by name or diagnosis
  - View patient age and status
  - Quick access to patient details
- **Add Patient** - إضافة مريض
  - Personal information (name, DOB, gender)
  - Medical information (diagnosis, stage)
  - Doctor/Nurse assignment
  - Contact details

### 📰 Publications / المنشورات
- **Publications Feed** - تدفق المنشورات
  - View all medical articles
  - Cover image support
  - Author information
- **Create Publication** - إنشاء منشور
  - Rich text content
  - Visibility controls (public, doctors only, staff only)
  - Cover image URL
  - Tags support

### 🔔 Notifications / الإشعارات
- **Create Notification** - إنشاء إشعار
  - Send to all or specific audience
  - Target: All, Doctors, Nurses, or Patients
  - Title and body message
  - Instant or scheduled sending

### 🚚 Transport Management / إدارة النقل
- **Transport Requests** - طلبات النقل
  - View all transport requests
  - Filter by status (pending, assigned, completed)
  - Assign drivers to requests
  - Track request progress

### 👤 Admin Profile / الملف الشخصي
- **Profile Management** - إدارة الملف الشخصي
  - Edit admin information
  - Update name and phone
  - Theme toggle (Light/Dark)
  - Language switcher (English/Arabic)
  - View email and role

---

## 🛠️ Technical Stack / التقنيات المستخدمة

### Frontend
- **Flutter** 3.7.2+
- **Material Design 3**
- **Provider** for state management

### Backend
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage** (for images)

### Architecture
- **Repository Pattern**
- **Service Layer**
- **MVVM-inspired structure**

### Key Packages / الحزم الأساسية
```yaml
dependencies:
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  provider: ^6.1.1
  flutter_localizations: (SDK)
```

---

## 📁 Project Structure / هيكل المشروع

```
lib/
├── config/
│   └── routes.dart                 # Navigation configuration
├── data/
│   ├── models/                     # Data models
│   │   ├── admin_model.dart
│   │   ├── doctor_model.dart
│   │   ├── nurse_model.dart
│   │   ├── patient_model.dart
│   │   ├── publication_model.dart
│   │   ├── notification_model.dart
│   │   └── transport_request_model.dart
│   ├── services/                   # Firebase services
│   │   ├── firebase_auth_service.dart
│   │   └── firestore_service.dart
│   └── repositories/               # Data repositories
│       ├── admin_repository.dart
│       ├── doctor_repository.dart
│       ├── nurse_repository.dart
│       ├── patient_repository.dart
│       ├── publication_repository.dart
│       ├── notification_repository.dart
│       └── transport_repository.dart
├── ui/
│   ├── screens/                    # All app screens
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── doctors/
│   │   ├── nurses/
│   │   ├── patients/
│   │   ├── publications/
│   │   ├── notifications/
│   │   ├── transport/
│   │   └── profile/
│   └── widgets/                    # Reusable widgets
│       ├── admin_card.dart
│       ├── stat_tile.dart
│       ├── loading_overlay.dart
│       ├── empty_state.dart
│       ├── confirm_dialog.dart
│       ├── person_card.dart
│       └── search_bar_widget.dart
├── provider/
│   └── app_state_provider.dart     # App state management
├── theme/
│   └── app_theme.dart              # Theme configuration
└── main.dart                       # Entry point
```

---

## 🚀 Getting Started / البدء

### Prerequisites / المتطلبات
1. Flutter SDK (3.7.2 or higher)
2. Firebase project setup
3. Android Studio / VS Code

### Installation / التثبيت

1. **Clone the repository**
```bash
git clone [repository-url]
cd flutter_application_1
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in appropriate directories
   - Run `flutterfire configure`

4. **Setup Firestore Database**

Create the following collections in Firestore:

**admins** collection:
```json
{
  "email": "admin@cancare.com",
  "displayName": "Admin User",
  "role": "admin",
  "phone": "+1234567890",
  "preferredLocale": "en",
  "preferredTheme": "dark",
  "createdAt": "timestamp",
  "lastLogin": "timestamp"
}
```

**doctors** collection:
```json
{
  "name": "Dr. Ahmed Ali",
  "specialty": "Oncology",
  "email": "ahmed@hospital.com",
  "phone": "+1234567890",
  "status": "active",
  "createdAt": "timestamp"
}
```

**nurses** collection:
```json
{
  "name": "Sarah Mohammed",
  "department": "ICU",
  "email": "sarah@hospital.com",
  "phone": "+1234567890",
  "status": "active",
  "createdAt": "timestamp"
}
```

**patients** collection:
```json
{
  "name": "Patient Name",
  "dateOfBirth": "timestamp",
  "gender": "male",
  "diagnosis": "Cancer Stage 2",
  "doctorId": "doctorDocId",
  "nurseId": "nurseDocId",
  "status": "active",
  "createdAt": "timestamp"
}
```

5. **Create an admin user in Firebase Authentication**
   - Go to Firebase Console → Authentication
   - Add a user with email/password
   - Add a document in `admins` collection with the same UID
   - Set `role: "admin"` in the document

6. **Run the app**
```bash
flutter run
```

---

## 🔒 Security Rules / قواعد الأمان

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Admins collection - only admins can read/write
    match /admins/{adminId} {
      allow read, write: if isAdmin();
    }
    
    // Doctors, Nurses, Patients - only admins can manage
    match /doctors/{docId} {
      allow read, write: if isAdmin();
    }
    
    match /nurses/{nurseId} {
      allow read, write: if isAdmin();
    }
    
    match /patients/{patientId} {
      allow read, write: if isAdmin();
    }
    
    // Publications - admins can write, authenticated users can read
    match /publications/{pubId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    // Notifications - only admins
    match /notifications/{notifId} {
      allow read, write: if isAdmin();
    }
    
    // Transport requests - only admins
    match /transportRequests/{reqId} {
      allow read, write: if isAdmin();
    }
  }
}
```

---

## 🌍 Localization / الترجمة

The app supports **English** and **Arabic** (RTL) languages.

يدعم التطبيق اللغتين **الإنجليزية** و**العربية** (من اليمين لليسار).

### Language Toggle / تبديل اللغة
- Access from Profile screen
- Changes all text instantly
- Persists across app restarts
- Automatic RTL layout for Arabic

---

## 🎨 Theming / السمات

### Dark Mode Support / دعم الوضع الداكن
- Light and dark themes
- Toggle from Profile screen
- Automatic color scheme adaptation
- Material Design 3 color system

### Color Scheme / نظام الألوان
- **Primary**: Blue (#004AAD)
- **Surface (Dark)**: #0B1220
- **Surface (Light)**: #FFFFFF

---

## 🔑 Default Credentials / بيانات الدخول الافتراضية

**Important**: You need to create admin credentials manually in Firebase.

**مهم**: يجب إنشاء بيانات اعتماد المشرف يدوياً في Firebase.

Steps:
1. Firebase Console → Authentication → Add User
2. Use any email/password (e.g., `admin@cancare.com` / `admin123`)
3. Copy the UID
4. Firestore → Create `admins` collection → Add document with that UID
5. Set `role: "admin"` and other fields

---

## 📱 Screenshots / لقطات الشاشة

### Login Screen / شاشة تسجيل الدخول
- Clean and modern UI
- Email and password fields
- Remember me checkbox
- Forgot password link

### Dashboard / لوحة التحكم
- Statistics cards
- Quick action buttons
- Real-time data
- Easy navigation

### Doctors/Nurses/Patients Lists / قوائم الأطباء/الممرضين/المرضى
- Search functionality
- Filter options
- Status badges
- Quick actions menu

---

## 🤝 Contributing / المساهمة

This is a complete admin panel system ready for production use or further customization.

هذا نظام لوحة تحكم كامل جاهز للاستخدام الإنتاجي أو المزيد من التخصيص.

---

## 📄 License / الترخيص

This project is part of the Can Care medical system.

هذا المشروع جزء من نظام Can Care الطبي.

---

## 📞 Support / الدعم

For questions or support, please contact the development team.

للأسئلة أو الدعم، يرجى الاتصال بفريق التطوير.

---

## ✅ Completed Features / الميزات المكتملة

✅ Authentication & Authorization  
✅ Dashboard with Statistics  
✅ Doctors Management (CRUD)  
✅ Nurses Management (CRUD)  
✅ Patients Management (CRUD)  
✅ Publications System  
✅ Notifications System  
✅ Transport Requests Management  
✅ Admin Profile Management  
✅ Dark Mode Support  
✅ English/Arabic Localization  
✅ RTL Support  
✅ Search & Filter Functionality  
✅ Firebase Integration  
✅ Repository Pattern Architecture  
✅ Responsive Design  

---

**Built with ❤️ using Flutter & Firebase**

**صُنع بـ ❤️ باستخدام Flutter و Firebase**
