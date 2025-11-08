# Quick Start Guide / دليل البدء السريع
# Can Care Admin Panel

---

## ⚡ 5-Minute Setup / الإعداد في 5 دقائق

### Prerequisites / المتطلبات المسبقة
- ✅ Flutter SDK installed (3.7.2+)
- ✅ Firebase account
- ✅ Android Studio or VS Code
- ✅ Git

---

## 📦 Step 1: Get the Project / الخطوة 1: الحصول على المشروع

```bash
# Clone the repository
git clone [repository-url]
cd flutter_application_1

# Install dependencies
flutter pub get
```

---

## 🔥 Step 2: Firebase Setup / الخطوة 2: إعداد Firebase

### Option A: Quick Setup (5 minutes) / الخيار أ: إعداد سريع

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Click "Add Project" → Name it "Can Care" → Continue

2. **Add Flutter App**:
   - Click Flutter icon
   - Follow the wizard
   - Download config files

3. **Enable Authentication**:
   - Authentication → Sign-in method → Enable Email/Password

4. **Create Firestore Database**:
   - Firestore Database → Create Database → Production mode

5. **Add Admin User**:
   ```
   Authentication → Add User:
   Email: admin@cancare.com
   Password: Admin@123
   
   Copy the UID!
   ```

6. **Create Admin Document**:
   ```
   Firestore → Start Collection: "admins"
   Document ID: [Paste UID]
   Fields:
   - email: "admin@cancare.com"
   - displayName: "Admin"
   - role: "admin"
   - createdAt: [timestamp]
   ```

7. **Update Security Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       function isAdmin() {
         return request.auth != null && 
                exists(/databases/$(database)/documents/admins/$(request.auth.uid)) &&
                get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
       }
       match /{document=**} {
         allow read, write: if isAdmin();
       }
     }
   }
   ```

### Option B: Detailed Setup / الخيار ب: إعداد تفصيلي

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for complete step-by-step instructions.

---

## 🚀 Step 3: Run the App / الخطوة 3: تشغيل التطبيق

```bash
# Configure Firebase (generates firebase_options.dart)
flutterfire configure

# Run the app
flutter run
```

---

## 🔐 Step 4: Login / الخطوة 4: تسجيل الدخول

**Default Credentials** (from Step 2):
```
Email: admin@cancare.com
Password: Admin@123
```

---

## 🎉 You're Done! / انتهيت!

You should now see the Dashboard with:
- Statistics cards
- Quick action buttons
- Navigation menu

---

## 🧪 Add Sample Data / إضافة بيانات تجريبية

### Quick Sample Data:

**Add a Doctor**:
1. Dashboard → "Manage Doctors"
2. Click "Add Doctor" button
3. Fill:
   - Name: Dr. Ahmed Ali
   - Specialty: Oncology
   - Email: ahmed@hospital.com
   - Phone: +966501234567
4. Click Save

**Add a Nurse**:
1. Dashboard → "Manage Nurses"
2. Click "Add Nurse" button
3. Fill:
   - Name: Sarah Mohammed
   - Department: ICU
   - Email: sarah@hospital.com
   - Phone: +966509876543
4. Click Save

**Add a Patient**:
1. Dashboard → "Manage Patients"
2. Click "Add Patient" button
3. Fill:
   - Name: Ali Hassan
   - Diagnosis: Cancer Stage 2
   - Date of Birth: [Select date]
   - Gender: Male
   - Phone: +966507654321
4. Click Save

---

## 📱 Features to Try / الميزات للتجربة

### 1. Dashboard / لوحة التحكم
- View statistics
- Click stat cards to navigate
- Use quick action cards

### 2. Search & Filter / البحث والتصفية
- Go to Doctors list
- Use search bar
- Try filter button
- Change status

### 3. Dark Mode / الوضع الداكن
- Profile → Toggle "Dark Mode"
- See instant theme change

### 4. Language Switch / تبديل اللغة
- Profile → Tap "Language"
- Switches between English/Arabic
- Notice RTL layout for Arabic

### 5. Publications / المنشورات
- Publications → Create Publication
- Add title and content
- Choose visibility
- Click Publish

### 6. Notifications / الإشعارات
- Dashboard → Send Notifications
- Add title and message
- Select audience
- Click Send Now

### 7. Transport Requests / طلبات النقل
- Transport Requests
- View pending requests
- Filter by status
- Assign driver

---

## 🛠️ Troubleshooting / حل المشكلات

### "Permission denied" error:
**Fix**: Update Firestore security rules (see Step 2.7)

### Cannot login:
**Fix**: 
1. Check admin user exists in Firebase Authentication
2. Check admin document exists in Firestore with `role: "admin"`
3. UID in Firestore must match Authentication UID

### App crashes on startup:
**Fix**:
```bash
flutter clean
flutter pub get
flutter run
```

### "Index required" error:
**Fix**: Click the link in error message to create index in Firebase

---

## 📚 Next Steps / الخطوات التالية

1. ✅ Read [FEATURES.md](FEATURES.md) for complete feature list
2. ✅ Review [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup
3. ✅ Check [README.md](README.md) for project overview
4. ✅ Customize admin credentials
5. ✅ Add more sample data
6. ✅ Configure Firebase Storage (for image uploads)
7. ✅ Set up FCM (for push notifications)

---

## 🆘 Need Help? / تحتاج مساعدة?

**Check Documentation**:
- [README.md](README.md) - Project overview
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Complete Firebase guide
- [FEATURES.md](FEATURES.md) - Feature documentation
- [CHANGELOG.md](CHANGELOG.md) - Version history

**Common Commands**:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run

# Check Flutter doctor
flutter doctor

# View logs
flutter logs
```

---

## 🎯 Quick Reference / مرجع سريع

### Default Routes:
- `/auth/login` - Login screen
- `/dashboard` - Dashboard
- `/doctors` - Doctors list
- `/nurses` - Nurses list
- `/patients` - Patients list
- `/publications` - Publications
- `/notifications/create` - Create notification
- `/transport/requests` - Transport requests
- `/profile` - Admin profile

### Firebase Collections:
- `admins` - Admin users
- `doctors` - Doctors
- `nurses` - Nurses
- `patients` - Patients
- `publications` - Publications
- `notifications` - Notifications
- `transportRequests` - Transport requests

---

## ⚡ Performance Tips / نصائح الأداء

1. Use Firebase indexes for complex queries
2. Enable persistence for offline support
3. Implement pagination for large lists
4. Use cached data when possible
5. Optimize images before upload

---

## 🔒 Security Checklist / قائمة الأمان

- ✅ Firestore security rules configured
- ✅ Admin role verification enabled
- ✅ Strong password policy (≥6 chars)
- ✅ Email validation
- ✅ Protected routes with AuthGate
- ⬜ Enable App Check (recommended for production)
- ⬜ Enable 2FA for admin accounts (recommended)

---

**🚀 Start Building! / ابدأ البناء!**

You're all set to use and customize the Can Care Admin Panel.

أنت جاهز الآن لاستخدام وتخصيص لوحة تحكم Can Care.

---

**Need more details?** → [FIREBASE_SETUP.md](FIREBASE_SETUP.md)  
**Want to see all features?** → [FEATURES.md](FEATURES.md)  
**Project overview?** → [README.md](README.md)

