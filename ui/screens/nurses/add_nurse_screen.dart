import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/nurse_model.dart';
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Nurse Screen - شاشة إضافة ممرض
// Path: /nurses/add
class AddNurseScreen extends StatefulWidget {
  const AddNurseScreen({super.key});

  @override
  State<AddNurseScreen> createState() => _AddNurseScreenState();
}

class _AddNurseScreenState extends State<AddNurseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _notesController = TextEditingController();
  final _nurseRepo = NurseRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nurse = NurseModel(
        id: '',
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _nurseRepo.createNurse(nurse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Directionality.of(context) == TextDirection.rtl
                  ? 'تم إضافة الممرض بنجاح'
                  : 'Nurse added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'إضافة ممرض' : 'Add Nurse'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving...',
        messageAr: 'جاري الحفظ...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'الاسم' : 'Name'} *',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? (isRTL ? 'الاسم مطلوب' : 'Name is required')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'القسم' : 'Department'} *',
                    prefixIcon: const Icon(Icons.local_hospital),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? (isRTL ? 'القسم مطلوب' : 'Department is required')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'البريد الإلكتروني' : 'Email'} *',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                    }
                    if (!v.contains('@')) return isRTL ? 'بريد غير صالح' : 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الهاتف (اختياري)' : 'Phone (Optional)',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _photoUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'رابط الصورة (اختياري)' : 'Photo URL (Optional)',
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'ملاحظات (اختياري)' : 'Notes (Optional)',
                    prefixIcon: const Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isRTL ? 'حفظ' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

