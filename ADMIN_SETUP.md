# Admin Setup Guide / دليل إعداد المشرف

## Creating First Admin Account / إنشاء أول حساب مشرف

### Step 1: Create Firebase User / الخطوة 1: إنشاء مستخدم Firebase

1. Go to Firebase Console → Authentication → Users
2. Click "Add User"
3. Enter email and password (e.g., `admin@cancare.com` / `admin123`)
4. Copy the **User UID** (you'll need it)

---

### Step 2: Create Admin Document / الخطوة 2: إنشاء وثيقة المشرف

1. Go to Firebase Console → Firestore Database
2. Create a collection named: `admins`
3. Create a document with the **User UID** as the Document ID
4. Add the following fields:

```json
{
  "email": "admin@cancare.com",
  "name": "Admin Name",
  "role": "admin",
  "createdAt": "2025-11-08T00:00:00.000Z",
  "isActive": true
}
```

**Important:** The `role` field must be either `"admin"` or `"superadmin"`

---

### Step 3: Login / الخطوة 3: تسجيل الدخول

Now you can login using:
- **Email**: admin@cancare.com
- **Password**: admin123

---

## Guest Login / تسجيل الدخول كضيف

You can also click **"Continue as Guest"** button to explore the app without authentication.

**Note:** Guest users have limited access and their session is temporary.

---

## Firestore Structure / هيكل Firestore

```
firestore/
├── admins/                    # Admin users
│   └── {userId}/
│       ├── email
│       ├── name
│       ├── role              # "admin" or "superadmin"
│       ├── createdAt
│       └── isActive
│
├── doctors/                  # Doctors data
├── nurses/                   # Nurses data
├── patients/                 # Patients data
├── publications/             # Publications/Posts
├── notifications/            # System notifications
└── transport_requests/       # Transport requests
```

---

## Troubleshooting / استكشاف الأخطاء

### Problem: "Access Denied" after login
**Solution:** Make sure:
1. Admin document exists in `admins` collection
2. Document ID matches the user's UID
3. `role` field is set to `"admin"` or `"superadmin"`

### Problem: Returns to login screen
**Solution:** 
1. Check the console logs for error messages
2. Verify Firebase configuration in `firebase_options.dart`
3. Ensure Firestore rules allow reading the `admins` collection

---

## Security Notes / ملاحظات الأمان

⚠️ **Important:** Update Firestore Security Rules to protect admin data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admins collection - only readable by authenticated users
    match /admins/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'superadmin';
    }
    
    // Allow anonymous (guest) users to read most collections
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && !request.auth.token.firebase.sign_in_provider == 'anonymous';
    }
  }
}
```

---

## Next Steps / الخطوات التالية

1. ✅ Create first admin account
2. ✅ Login to the app
3. ⚪ Configure Firebase Security Rules
4. ⚪ Start adding doctors, nurses, and patients
5. ⚪ Create publications and notifications

---

**Need Help?** Check the console logs for detailed error messages.

