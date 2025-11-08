import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/patient_model.dart';
import 'package:admin_can_care/data/repositories/patient_repository.dart';
import 'package:admin_can_care/ui/widgets/loading_overlay.dart';

// Add Patient Screen - شاشة إضافة مريض
class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _patientRepo = PatientRepository();

  String? _selectedGender;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final patient = PatientModel(
        id: '',
        name: _nameController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _patientRepo.createPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Directionality.of(context) == TextDirection.rtl
                ? 'تم إضافة المريض بنجاح'
                : 'Patient added successfully'),
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
      appBar: AppBar(title: Text(isRTL ? 'إضافة مريض' : 'Add Patient')),
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
                  controller: _diagnosisController,
                  decoration: InputDecoration(
                    labelText: '${isRTL ? 'التشخيص' : 'Diagnosis'} *',
                    prefixIcon: const Icon(Icons.medical_information),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? (isRTL ? 'التشخيص مطلوب' : 'Diagnosis is required')
                      : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake),
                  title: Text(_dateOfBirth == null
                      ? (isRTL ? 'تاريخ الميلاد' : 'Date of Birth')
                      : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الجنس' : 'Gender',
                    prefixIcon: const Icon(Icons.wc),
                  ),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text(isRTL ? 'ذكر' : 'Male')),
                    DropdownMenuItem(value: 'female', child: Text(isRTL ? 'أنثى' : 'Female')),
                  ],
                  onChanged: (v) => setState(() => _selectedGender = v),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
                    prefixIcon: const Icon(Icons.email),
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

