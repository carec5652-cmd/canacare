import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_can_care/data/models/notification_model.dart';
import 'package:admin_can_care/data/repositories/notification_repository.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Create Notification Screen - شاشة إنشاء إشعار
class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _repo = NotificationRepository();

  String _targetAudience = 'all';
  bool _isLoading = false;

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final notification = NotificationModel(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        targetAudience: _targetAudience,
        createdAt: DateTime.now(),
        createdBy: user.uid,
        status: 'sent',
      );

      await _repo.createNotification(notification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Directionality.of(context) == TextDirection.rtl
                ? 'تم إرسال الإشعار بنجاح'
                : 'Notification sent successfully'),
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
      appBar: AppBar(title: Text(isRTL ? 'إنشاء إشعار' : 'Create Notification')),
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
                  controller: _bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'الرسالة' : 'Message'} *',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? (isRTL ? 'الرسالة مطلوبة' : 'Message is required') : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _targetAudience,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الجمهور المستهدف' : 'Target Audience',
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(isRTL ? 'الجميع' : 'All')),
                    DropdownMenuItem(value: 'doctors', child: Text(isRTL ? 'الأطباء' : 'Doctors')),
                    DropdownMenuItem(value: 'nurses', child: Text(isRTL ? 'الممرضين' : 'Nurses')),
                    DropdownMenuItem(value: 'patients', child: Text(isRTL ? 'المرضى' : 'Patients')),
                  ],
                  onChanged: (v) => setState(() => _targetAudience = v!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSend,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(isRTL ? 'إرسال الآن' : 'Send Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

