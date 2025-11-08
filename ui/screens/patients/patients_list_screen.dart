import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/patient_model.dart';
import 'package:admin_can_care/data/repositories/patient_repository.dart';
import 'package:admin_can_care/ui/widgets/person_card.dart';
import 'package:admin_can_care/ui/widgets/empty_state.dart';
import 'package:admin_can_care/ui/widgets/search_bar_widget.dart';
import 'package:admin_can_care/ui/widgets/animated_list_item.dart';
import 'package:admin_can_care/ui/widgets/app_drawer.dart';

// Patients List Screen - شاشة قائمة المرضى
class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _patientRepo = PatientRepository();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(isRTL ? 'المرضى' : 'Patients'),
        actions: const [SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/patients/add'),
        icon: const Icon(Icons.add),
        label: Text(isRTL ? 'إضافة مريض' : 'Add Patient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search patients...',
              hintTextAr: 'البحث عن المرضى...',
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PatientModel>>(
              stream: _patientRepo.streamPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final patients = snapshot.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? patients
                    : patients.where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.diagnosis.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    message: 'No patients found',
                    messageAr: 'لا يوجد مرضى',
                    actionLabel: 'Add Patient',
                    actionLabelAr: 'إضافة مريض',
                    onAction: () => Navigator.pushNamed(context, '/patients/add'),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final patient = filtered[index];
                    return AnimatedListItem(
                      index: index,
                      delay: 30,
                      child: PersonCard(
                        name: patient.name,
                        subtitle: '${patient.diagnosis}${patient.age != null ? ' • ${patient.age} years' : ''}',
                        photoUrl: patient.photoUrl,
                        status: patient.status,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/patients/${patient.id}',
                          arguments: patient,
                        ),
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
}

