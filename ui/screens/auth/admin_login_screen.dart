import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_can_care/data/services/firebase_auth_service.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Admin Login Screen - شاشة تسجيل دخول المشرف
// Path: /auth/login
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login Handler - معالج تسجيل الدخول
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sign in with email & password
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Check if user is admin
      final isAdmin = await _authService.isAdmin(userCredential.user!.uid);

      if (!isAdmin) {
        // Not an admin, sign out
        await _authService.signOut();
        if (!mounted) return;
        _showError(
          'Access Denied / الوصول محظور',
          'You do not have admin privileges. Please create an admin document in Firestore.\n\nليس لديك صلاحيات المشرف. يرجى إنشاء وثيقة مشرف في Firestore.',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Success - The AuthGate in main.dart will handle navigation automatically
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError('Login Failed / فشل تسجيل الدخول', e.message ?? 'Unknown error');
    } catch (e) {
      if (!mounted) return;
      _showError('Error / خطأ', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Guest Sign In - تسجيل الدخول كضيف
  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInAnonymously();
      // Success - The AuthGate will handle navigation
    } catch (e) {
      if (!mounted) return;
      _showError('Error / خطأ', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Show Error Dialog
  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
    );
  }

  // Navigate to Forgot Password
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/auth/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Signing in...',
        messageAr: 'جاري تسجيل الدخول...',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo/Icon
                          Icon(
                            Icons.admin_panel_settings,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            isRTL ? 'تسجيل دخول المشرف' : 'Admin Login',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isRTL ? 'مرحباً بك في نظام Can Care' : 'Welcome to Can Care System',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
                              hintText: isRTL ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return isRTL ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              labelText: isRTL ? 'كلمة المرور' : 'Password',
                              hintText: isRTL ? 'أدخل كلمة المرور' : 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isRTL ? 'كلمة المرور مطلوبة' : 'Password is required';
                              }
                              if (value.length < 6) {
                                return isRTL
                                    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                    : 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value!);
                                    },
                                  ),
                                  Text(
                                    isRTL ? 'تذكرني' : 'Remember me',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _navigateToForgotPassword,
                                child: Text(isRTL ? 'نسيت كلمة المرور؟' : 'Forgot password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isRTL ? 'تسجيل الدخول' : 'Log In',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(isRTL ? 'أو' : 'OR', style: theme.textTheme.bodySmall),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Guest Sign In Button
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleGuestLogin,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.person_outline),
                            label: Text(
                              isRTL ? 'الدخول كضيف' : 'Continue as Guest',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
