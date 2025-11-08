import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/doctor_model.dart';
import 'package:admin_can_care/data/models/patient_model.dart';
import 'package:admin_can_care/data/repositories/patient_repository.dart';
import 'package:admin_can_care/ui/widgets/person_card.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';

// Doctor Details Screen - شاشة تفاصيل الطبيب
// Path: /doctors/:id
class DoctorDetailsScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final _patientRepo = PatientRepository();
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _patientRepo.getPatientsByDoctor(widget.doctor.id);
      if (mounted) {
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'تفاصيل الطبيب' : 'Doctor Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor.withOpacity(0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    backgroundImage: widget.doctor.photoUrl != null
                        ? NetworkImage(widget.doctor.photoUrl!)
                        : null,
                    child: widget.doctor.photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.doctor.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.doctor.specialty,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(widget.doctor.status),
                ],
              ),
            ),

            // Contact Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'معلومات الاتصال' : 'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.email,
                            isRTL ? 'البريد الإلكتروني' : 'Email',
                            widget.doctor.email,
                          ),
                          if (widget.doctor.phone != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.phone,
                              isRTL ? 'الهاتف' : 'Phone',
                              widget.doctor.phone!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Notes
                  if (widget.doctor.notes != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      isRTL ? 'ملاحظات' : 'Notes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.doctor.notes!),
                      ),
                    ),
                  ],

                  // Patients Section
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRTL ? 'المرضى' : 'Patients',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_patients.length} ${isRTL ? 'مريض' : 'patients'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_patients.isEmpty)
                    EmptyState(
                      icon: Icons.people_outline,
                      message: 'No patients assigned',
                      messageAr: 'لا يوجد مرضى مسجلين',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return PersonCard(
                          name: patient.name,
                          subtitle: patient.diagnosis,
                          photoUrl: patient.photoUrl,
                          status: patient.status,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/patients/${patient.id}',
                            arguments: patient,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        label = 'Active / نشط';
        break;
      case 'inactive':
        color = Colors.orange;
        label = 'Inactive / غير نشط';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

