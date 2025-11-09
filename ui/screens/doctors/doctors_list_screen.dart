// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/doctor_model.dart';
import 'package:admin_can_care/data/repositories/doctor_repository.dart';
import 'package:admin_can_care/ui/widgets/person_card.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';
import 'package:admin_can_care/ui/widgets/search_bar_widget.dart';
import 'package:admin_can_care/ui/layouts/main_layout.dart';

// Doctors List Screen - شاشة قائمة الأطباء
// Path: /doctors
class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final _doctorRepo = DoctorRepository();
  final _searchController = TextEditingController();

  String? _selectedSpecialty;
  String? _selectedStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return MainLayout(
      title: 'Doctors',
      titleAr: 'الأطباء',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: _showFilterDialog,
        ),
        const SizedBox(width: 8),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/doctors/add'),
        icon: const Icon(Icons.add),
        label: Text(isRTL ? 'إضافة طبيب' : 'Add Doctor'),
      ),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search doctors...',
              hintTextAr: 'البحث عن الأطباء...',
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // Doctors List
          Expanded(
            child: StreamBuilder<List<DoctorModel>>(
              stream: _doctorRepo.streamDoctors(
                specialty: _selectedSpecialty,
                status: _selectedStatus,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final doctors = snapshot.data ?? [];

                // Apply search filter
                final filteredDoctors =
                    _searchQuery.isEmpty
                        ? doctors
                        : doctors.where((doctor) {
                          return doctor.name.toLowerCase().contains(_searchQuery) ||
                              doctor.specialty.toLowerCase().contains(_searchQuery) ||
                              doctor.email.toLowerCase().contains(_searchQuery);
                        }).toList();

                if (filteredDoctors.isEmpty) {
                  return EmptyState(
                    icon: Icons.medical_services_outlined,
                    message: 'No doctors found',
                    messageAr: 'لا يوجد أطباء',
                    actionLabel: 'Add Doctor',
                    actionLabelAr: 'إضافة طبيب',
                    onAction: () => Navigator.pushNamed(context, '/doctors/add'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDoctors.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];
                    return PersonCard(
                      name: doctor.name,
                      subtitle: doctor.specialty,
                      photoUrl: doctor.photoUrl,
                      status: doctor.status,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/doctors/${doctor.id}',
                            arguments: doctor,
                          ),
                      actions: [
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleAction(value, doctor),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.visibility),
                                      const SizedBox(width: 8),
                                      Text(isRTL ? 'عرض' : 'View'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit),
                                      const SizedBox(width: 8),
                                      Text(isRTL ? 'تعديل' : 'Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: doctor.status == 'active' ? 'deactivate' : 'activate',
                                  child: Row(
                                    children: [
                                      Icon(
                                        doctor.status == 'active'
                                            ? Icons.block
                                            : Icons.check_circle,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        doctor.status == 'active'
                                            ? (isRTL ? 'تعطيل' : 'Deactivate')
                                            : (isRTL ? 'تنشيط' : 'Activate'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'الفلاتر' : 'Filters'),
            content: StatefulBuilder(
              builder:
                  (context, setDialogState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedSpecialty,
                        decoration: InputDecoration(labelText: isRTL ? 'التخصص' : 'Specialty'),
                        items: [
                          DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                          DropdownMenuItem(
                            value: 'Oncology',
                            child: Text(isRTL ? 'الأورام' : 'Oncology'),
                          ),
                          DropdownMenuItem(
                            value: 'Cardiology',
                            child: Text(isRTL ? 'القلب' : 'Cardiology'),
                          ),
                          DropdownMenuItem(
                            value: 'Neurology',
                            child: Text(isRTL ? 'الأعصاب' : 'Neurology'),
                          ),
                          DropdownMenuItem(
                            value: 'Pediatrics',
                            child: Text(isRTL ? 'الأطفال' : 'Pediatrics'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() => _selectedSpecialty = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(labelText: isRTL ? 'الحالة' : 'Status'),
                        items: [
                          DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                          DropdownMenuItem(value: 'active', child: Text(isRTL ? 'نشط' : 'Active')),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(isRTL ? 'غير نشط' : 'Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() => _selectedStatus = value);
                        },
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSpecialty = null;
                    _selectedStatus = null;
                  });
                  Navigator.pop(context);
                },
                child: Text(isRTL ? 'إعادة تعيين' : 'Reset'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Text(isRTL ? 'تطبيق' : 'Apply'),
              ),
            ],
          ),
    );
  }

  void _handleAction(String action, DoctorModel doctor) {
    switch (action) {
      case 'view':
        Navigator.pushNamed(context, '/doctors/${doctor.id}', arguments: doctor);
        break;
      case 'edit':
        // Navigate to edit screen
        break;
      case 'activate':
      case 'deactivate':
        _toggleDoctorStatus(doctor);
        break;
    }
  }

  Future<void> _toggleDoctorStatus(DoctorModel doctor) async {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final newStatus = doctor.status == 'active' ? 'inactive' : 'active';

    try {
      await _doctorRepo.updateDoctor(doctor.id, {'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRTL ? 'تم تحديث الحالة' : 'Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
