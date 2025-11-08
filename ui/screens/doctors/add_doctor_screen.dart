// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/doctor_model.dart';
import 'package:admin_can_care/data/repositories/doctor_repository.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Doctor Screen - شاشة إضافة طبيب
// Path: /doctors/add
class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _notesController = TextEditingController();
  final _doctorRepo = DoctorRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
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
      final doctor = DoctorModel(
        id: '',
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty ? null : _photoUrlController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _doctorRepo.createDoctor(doctor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Directionality.of(context) == TextDirection.rtl
                  ? 'تم إضافة الطبيب بنجاح'
                  : 'Doctor added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(title: Text(isRTL ? 'إضافة طبيب' : 'Add Doctor')),
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
                // Name Field *
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'الاسم' : 'Name'} *',
                    hintText: isRTL ? 'أدخل اسم الطبيب' : 'Enter doctor name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'الاسم مطلوب' : 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Specialty Field *
                TextFormField(
                  controller: _specialtyController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'التخصص' : 'Specialty'} *',
                    hintText: isRTL ? 'أدخل التخصص' : 'Enter specialty',
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'التخصص مطلوب' : 'Specialty is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field *
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'البريد الإلكتروني' : 'Email'} *',
                    hintText: isRTL ? 'أدخل البريد الإلكتروني' : 'Enter email',
                    prefixIcon: const Icon(Icons.email),
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

                // Phone Field (Optional)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الهاتف (اختياري)' : 'Phone (Optional)',
                    hintText: isRTL ? 'أدخل رقم الهاتف' : 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),

                // Photo URL Field (Optional)
                TextFormField(
                  controller: _photoUrlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'رابط الصورة (اختياري)' : 'Photo URL (Optional)',
                    hintText: isRTL ? 'أدخل رابط الصورة' : 'Enter photo URL',
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Field (Optional)
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'ملاحظات (اختياري)' : 'Notes (Optional)',
                    hintText: isRTL ? 'أدخل ملاحظات' : 'Enter notes',
                    prefixIcon: const Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
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
