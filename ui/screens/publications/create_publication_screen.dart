import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_can_care/data/models/publication_model.dart';
import 'package:admin_can_care/data/repositories/publication_repository.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Create Publication Screen - شاشة إنشاء منشور
class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _repo = PublicationRepository();

  String _visibility = 'public';
  bool _isLoading = false;

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final publication = PublicationModel(
        id: '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        coverImageUrl: _coverUrlController.text.trim().isEmpty ? null : _coverUrlController.text.trim(),
        authorId: user.uid,
        authorName: user.email,
        visibility: _visibility,
        createdAt: DateTime.now(),
      );

      await _repo.createPublication(publication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Directionality.of(context) == TextDirection.rtl
                ? 'تم نشر المقال بنجاح'
                : 'Published successfully'),
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
      appBar: AppBar(title: Text(isRTL ? 'إنشاء منشور' : 'Create Publication')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'العنوان' : 'Title'} *',
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? (isRTL ? 'العنوان مطلوب' : 'Title is required') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'المحتوى' : 'Content'} *',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? (isRTL ? 'المحتوى مطلوب' : 'Content is required') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _coverUrlController,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'رابط صورة الغلاف (اختياري)' : 'Cover Image URL (Optional)',
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _visibility,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الظهور' : 'Visibility',
                  ),
                  items: [
                    DropdownMenuItem(value: 'public', child: Text(isRTL ? 'عام' : 'Public')),
                    DropdownMenuItem(value: 'doctors_only', child: Text(isRTL ? 'الأطباء فقط' : 'Doctors Only')),
                    DropdownMenuItem(value: 'staff_only', child: Text(isRTL ? 'الموظفين فقط' : 'Staff Only')),
                  ],
                  onChanged: (v) => setState(() => _visibility = v!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(isRTL ? 'نشر' : 'Publish'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

