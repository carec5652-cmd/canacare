# Firebase Setup Guide
# دليل إعداد Firebase

This guide will help you set up Firebase for the Can Care Admin Panel.

سيساعدك هذا الدليل في إعداد Firebase للوحة تحكم Can Care.

---

## Step 1: Create Firebase Project / الخطوة 1: إنشاء مشروع Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" / انقر على "إضافة مشروع"
3. Enter project name: "Can Care" / أدخل اسم المشروع: "Can Care"
4. Enable Google Analytics (optional) / تفعيل Google Analytics (اختياري)
5. Click "Create Project" / انقر على "إنشاء المشروع"

---

## Step 2: Add Flutter App / الخطوة 2: إضافة تطبيق Flutter

### For Android / لنظام Android:
1. Click on Android icon
2. Register app with package name: `com.example.admin_can_care`
3. Download `google-services.json`
4. Place it in `android/app/`

### For iOS / لنظام iOS:
1. Click on iOS icon
2. Register app with bundle ID: `com.example.adminCanCare`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### For Web (Optional) / للويب (اختياري):
1. Click on Web icon
2. Register app
3. Copy the configuration

---

## Step 3: Enable Authentication / الخطوة 3: تفعيل المصادقة

1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Click **Save**

### Create Admin User / إنشاء مستخدم مشرف:
1. Go to **Authentication** → **Users**
2. Click **Add User**
3. Email: `admin@cancare.com` (or your choice)
4. Password: `Admin@123` (or your choice - minimum 6 characters)
5. Click **Add User**
6. **Copy the User UID** (you'll need it in Step 5)

---

## Step 4: Setup Firestore Database / الخطوة 4: إعداد قاعدة بيانات Firestore

1. Go to **Firestore Database**
2. Click **Create Database**
3. Choose **Start in production mode**
4. Select location closest to you
5. Click **Enable**

---

## Step 5: Create Collections / الخطوة 5: إنشاء المجموعات

### 1. Create `admins` collection / إنشاء مجموعة `admins`:

Click **Start Collection** → Collection ID: `admins`

**Add first document with the UID from Step 3:**

```
Document ID: [Paste the UID you copied]

Fields:
- email (string): "admin@cancare.com"
- displayName (string): "System Administrator"
- role (string): "admin"
- phone (string): "+966500000000"
- photoUrl (string): "" (leave empty)
- preferredLocale (string): "en"
- preferredTheme (string): "dark"
- createdAt (timestamp): [Click "Use timestamp"]
- lastLogin (timestamp): [Click "Use timestamp"]
```

### 2. Create empty collections / إنشاء مجموعات فارغة:

Create these collections (you can add sample data later):
- `doctors`
- `nurses`
- `patients`
- `publications`
- `notifications`
- `transportRequests`

---

## Step 6: Setup Security Rules / الخطوة 6: إعداد قواعد الأمان

1. Go to **Firestore Database** → **Rules**
2. Replace with the following:

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
    
    // Doctors collection
    match /doctors/{docId} {
      allow read, write: if isAdmin();
    }
    
    // Nurses collection
    match /nurses/{nurseId} {
      allow read, write: if isAdmin();
    }
    
    // Patients collection
    match /patients/{patientId} {
      allow read, write: if isAdmin();
    }
    
    // Publications - admins write, authenticated users read
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

3. Click **Publish**

---

## Step 7: Setup Indexes (Optional) / الخطوة 7: إعداد الفهارس (اختياري)

Go to **Firestore Database** → **Indexes** → **Composite**

You may need to create indexes for queries if you see errors when running the app. Firebase will provide the exact index link in the error message.

---

## Step 8: Configure Flutter Project / الخطوة 8: تكوين مشروع Flutter

### Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase:
```bash
flutterfire configure
```

This will:
- Generate `firebase_options.dart`
- Link your Flutter app to Firebase project
- Set up configuration for all platforms

---

## Step 9: Test the Setup / الخطوة 9: اختبار الإعداد

1. Run the app:
```bash
flutter run
```

2. Login with:
   - Email: `admin@cancare.com` (or the email you created)
   - Password: `Admin@123` (or the password you set)

3. You should see the Dashboard! / يجب أن ترى لوحة التحكم!

---

## Sample Data / بيانات تجريبية

### Add Sample Doctor:

Collection: `doctors`

```
Document ID: [Auto-generated]

Fields:
- name (string): "Dr. Ahmed Ali"
- specialty (string): "Oncology"
- email (string): "ahmed@hospital.com"
- phone (string): "+966501234567"
- photoUrl (string): ""
- status (string): "active"
- notes (string): "Senior oncologist with 15 years experience"
- createdAt (timestamp): [Use timestamp]
- updatedAt (timestamp): [Use timestamp]
```

### Add Sample Nurse:

Collection: `nurses`

```
Document ID: [Auto-generated]

Fields:
- name (string): "Sarah Mohammed"
- department (string): "ICU"
- email (string): "sarah@hospital.com"
- phone (string): "+966509876543"
- photoUrl (string): ""
- status (string): "active"
- notes (string): "Experienced ICU nurse"
- createdAt (timestamp): [Use timestamp]
- updatedAt (timestamp): [Use timestamp]
```

### Add Sample Patient:

Collection: `patients`

```
Document ID: [Auto-generated]

Fields:
- name (string): "Ali Hassan"
- dateOfBirth (timestamp): [Set a date]
- gender (string): "male"
- phone (string): "+966507654321"
- email (string): "ali@email.com"
- diagnosis (string): "Cancer Stage 2"
- stage (string): "2"
- doctorId (string): [Copy doctor document ID from above]
- nurseId (string): [Copy nurse document ID from above]
- allergies (string): "Penicillin"
- status (string): "active"
- notes (string): "Under chemotherapy treatment"
- createdAt (timestamp): [Use timestamp]
- updatedAt (timestamp): [Use timestamp]
```

---

## Troubleshooting / حل المشكلات

### Problem: "Permission denied" errors
**Solution**: Make sure you've published the security rules in Step 6.

### Problem: Cannot login
**Solution**: 
1. Check that admin user exists in Authentication
2. Check that admin document exists in `admins` collection with correct UID
3. Verify `role` field is set to "admin"

### Problem: "Index required" error
**Solution**: Click the link in the error message to create the required index in Firebase.

### Problem: App crashes on startup
**Solution**:
1. Make sure `google-services.json` is in `android/app/`
2. Make sure `GoogleService-Info.plist` is in `ios/Runner/`
3. Run `flutter clean` then `flutter pub get`

---

## Security Best Practices / أفضل ممارسات الأمان

1. ✅ Never commit Firebase configuration files to public repositories
2. ✅ Use strong passwords for admin accounts
3. ✅ Enable App Check for production
4. ✅ Set up billing alerts in Firebase Console
5. ✅ Regularly review Firestore security rules
6. ✅ Enable two-factor authentication for Firebase Console access

---

## Next Steps / الخطوات التالية

1. Customize the admin email and password
2. Add more sample data for testing
3. Configure Firebase Storage for image uploads (optional)
4. Set up Firebase Cloud Messaging for push notifications (optional)
5. Enable Firebase Analytics (optional)

---

## Support / الدعم

If you encounter any issues, please:
1. Check Firebase Console for errors
2. Review Flutter logs: `flutter logs`
3. Verify all steps were followed correctly

---

**🎉 Setup Complete! / اكتمل الإعداد!**

You're now ready to use the Can Care Admin Panel!

أنت الآن جاهز لاستخدام لوحة تحكم Can Care!

