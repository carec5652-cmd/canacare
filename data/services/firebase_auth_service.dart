// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Authentication Service
// خدمة مصادقة Firebase
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current User
  User? get currentUser => _auth.currentUser;

  // Auth State Changes Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In with Email & Password
  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      if (userCredential.user != null) {
        await _firestore.collection('admins').doc(userCredential.user!.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if user is admin
  // التحقق من أن المستخدم مشرف
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('admins').doc(uid).get();
      if (!doc.exists) {
        print('Admin document not found for UID: $uid');
        return false;
      }
      final role = doc.data()?['role'];
      print('User role: $role');
      return role == 'admin' || role == 'superadmin';
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }

  // Sign In Anonymously (Guest)
  // تسجيل الدخول كضيف
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send Password Reset Email
  // إرسال بريد إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update Password
  // تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email. / لم يتم العثور على مستخدم بهذا البريد.';
      case 'wrong-password':
        return 'Wrong password. / كلمة المرور غير صحيحة.';
      case 'invalid-email':
        return 'Invalid email format. / تنسيق البريد الإلكتروني غير صالح.';
      case 'user-disabled':
        return 'This account has been disabled. / تم تعطيل هذا الحساب.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later. / محاولات كثيرة جداً. حاول مرة أخرى لاحقاً.';
      case 'weak-password':
        return 'Password should be at least 6 characters. / يجب أن تكون كلمة المرور 6 أحرف على الأقل.';
      case 'email-already-in-use':
        return 'Email already in use. / البريد الإلكتروني مستخدم بالفعل.';
      default:
        return e.message ?? 'Authentication error. / خطأ في المصادقة.';
    }
  }
}
