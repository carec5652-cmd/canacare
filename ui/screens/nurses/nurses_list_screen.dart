import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/nurse_model.dart';
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
import 'package:admin_can_care/ui/widgets/person_card.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';
import 'package:admin_can_care/ui/widgets/search_bar_widget.dart';
import 'package:admin_can_care/ui/widgets/animated_list_item.dart';
import 'package:admin_can_care/ui/widgets/app_drawer.dart';

// Nurses List Screen - شاشة قائمة الممرضين
// Path: /nurses
class NursesListScreen extends StatefulWidget {
  const NursesListScreen({super.key});

  @override
  State<NursesListScreen> createState() => _NursesListScreenState();
}

class _NursesListScreenState extends State<NursesListScreen> {
  final _nurseRepo = NurseRepository();
  final _searchController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(isRTL ? 'الممرضين' : 'Nurses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/nurses/add'),
        icon: const Icon(Icons.add),
        label: Text(isRTL ? 'إضافة ممرض' : 'Add Nurse'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search nurses...',
              hintTextAr: 'البحث عن الممرضين...',
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<NurseModel>>(
              stream: _nurseRepo.streamNurses(
                department: _selectedDepartment,
                status: _selectedStatus,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final nurses = snapshot.data ?? [];

                final filteredNurses = _searchQuery.isEmpty
                    ? nurses
                    : nurses.where((nurse) {
                        return nurse.name.toLowerCase().contains(_searchQuery) ||
                            nurse.department.toLowerCase().contains(_searchQuery) ||
                            nurse.email.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (filteredNurses.isEmpty) {
                  return EmptyState(
                    icon: Icons.local_hospital_outlined,
                    message: 'No nurses found',
                    messageAr: 'لا يوجد ممرضين',
                    actionLabel: 'Add Nurse',
                    actionLabelAr: 'إضافة ممرض',
                    onAction: () => Navigator.pushNamed(context, '/nurses/add'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredNurses.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final nurse = filteredNurses[index];
                    return AnimatedListItem(
                      index: index,
                      delay: 30,
                      child: PersonCard(
                        name: nurse.name,
                        subtitle: nurse.department,
                        photoUrl: nurse.photoUrl,
                        status: nurse.status,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/nurses/${nurse.id}',
                          arguments: nurse,
                        ),
                        actions: [
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleAction(value, nurse),
                          itemBuilder: (context) => [
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
                              value: nurse.status == 'active'
                                  ? 'deactivate'
                                  : 'activate',
                              child: Row(
                                children: [
                                  Icon(nurse.status == 'active'
                                      ? Icons.block
                                      : Icons.check_circle),
                                  const SizedBox(width: 8),
                                  Text(
                                    nurse.status == 'active'
                                        ? (isRTL ? 'تعطيل' : 'Deactivate')
                                        : (isRTL ? 'تنشيط' : 'Activate'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      ),
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
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'الفلاتر' : 'Filters'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: isRTL ? 'القسم' : 'Department',
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                  DropdownMenuItem(value: 'ICU', child: Text(isRTL ? 'العناية المركزة' : 'ICU')),
                  DropdownMenuItem(value: 'ER', child: Text(isRTL ? 'الطوارئ' : 'ER')),
                  DropdownMenuItem(value: 'Surgery', child: Text(isRTL ? 'الجراحة' : 'Surgery')),
                  DropdownMenuItem(value: 'Pediatrics', child: Text(isRTL ? 'الأطفال' : 'Pediatrics')),
                ],
                onChanged: (value) => setDialogState(() => _selectedDepartment = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: isRTL ? 'الحالة' : 'Status',
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(isRTL ? 'الكل' : 'All')),
                  DropdownMenuItem(value: 'active', child: Text(isRTL ? 'نشط' : 'Active')),
                  DropdownMenuItem(value: 'inactive', child: Text(isRTL ? 'غير نشط' : 'Inactive')),
                ],
                onChanged: (value) => setDialogState(() => _selectedStatus = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDepartment = null;
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

  void _handleAction(String action, NurseModel nurse) {
    if (action == 'view') {
      Navigator.pushNamed(context, '/nurses/${nurse.id}', arguments: nurse);
    } else {
      _toggleNurseStatus(nurse);
    }
  }

  Future<void> _toggleNurseStatus(NurseModel nurse) async {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final newStatus = nurse.status == 'active' ? 'inactive' : 'active';

    try {
      await _nurseRepo.updateNurse(nurse.id, {'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRTL ? 'تم تحديث الحالة' : 'Status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

