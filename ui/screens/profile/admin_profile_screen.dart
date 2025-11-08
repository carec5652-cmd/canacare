import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:admin_can_care/data/models/admin_model.dart';
import 'package:admin_can_care/data/repositories/admin_repository.dart';
import 'package:admin_can_care/provider/app_state_provider.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Admin Profile Screen - شاشة ملف المشرف
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repo = AdminRepository();

  AdminModel? _admin;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final admin = await _repo.getAdmin(user.uid);
      if (mounted && admin != null) {
        setState(() {
          _admin = admin;
          _nameController.text = admin.displayName;
          _phoneController.text = admin.phone ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _repo.updateAdmin(user.uid, {
        'displayName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Directionality.of(context) == TextDirection.rtl
                ? 'تم التحديث بنجاح'
                : 'Updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'الملف الشخصي' : 'Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                backgroundImage: _admin?.photoUrl != null ? NetworkImage(_admin!.photoUrl!) : null,
                child: _admin?.photoUrl == null
                    ? Icon(Icons.person, size: 60, color: theme.primaryColor)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _admin?.displayName ?? 'Admin',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _admin?.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Profile Form
              if (_isEditing)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isRTL ? 'الاسم' : 'Name',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? (isRTL ? 'الاسم مطلوب' : 'Name is required')
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: isRTL ? 'الهاتف' : 'Phone',
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _isEditing = false);
                                _loadProfile();
                              },
                              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSave,
                              child: Text(isRTL ? 'حفظ' : 'Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text(isRTL ? 'البريد الإلكتروني' : 'Email'),
                            subtitle: Text(_admin?.email ?? ''),
                          ),
                          if (_admin?.phone != null)
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text(isRTL ? 'الهاتف' : 'Phone'),
                              subtitle: Text(_admin!.phone!),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(isRTL ? 'الوضع الداكن' : 'Dark Mode'),
                            secondary: const Icon(Icons.dark_mode),
                            value: appState.isDark,
                            onChanged: (_) => appState.toggleTheme(),
                          ),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(isRTL ? 'اللغة' : 'Language'),
                            subtitle: Text(isRTL ? 'العربية' : 'English'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: appState.switchLanguage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

