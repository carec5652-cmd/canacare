import 'package:flutter/material.dart';
import 'package:admin_can_care/data/repositories/doctor_repository.dart';
import 'package:admin_can_care/data/repositories/nurse_repository.dart';
import 'package:admin_can_care/data/repositories/patient_repository.dart';
import 'package:admin_can_care/data/repositories/transport_repository.dart';
import 'package:admin_can_care/ui/widgets/animated_stat_card.dart';
import 'package:admin_can_care/ui/widgets/animated_action_card.dart';
import 'package:admin_can_care/ui/widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Dashboard Screen - شاشة لوحة التحكم
// Path: /dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _doctorRepo = DoctorRepository();
  final _nurseRepo = NurseRepository();
  final _patientRepo = PatientRepository();
  final _transportRepo = TransportRepository();

  int _doctorsCount = 0;
  int _nursesCount = 0;
  int _patientsCount = 0;
  int _pendingTransports = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final doctors = await _doctorRepo.getDoctorsCount(status: 'active');
      final nurses = await _nurseRepo.getNursesCount(status: 'active');
      final patients = await _patientRepo.getPatientsCount(status: 'active');
      final transportStats = await _transportRepo.getTransportStats();

      if (mounted) {
        setState(() {
          _doctorsCount = doctors;
          _nursesCount = nurses;
          _patientsCount = patients;
          _pendingTransports = transportStats['pending'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _doctorsCount = 0;
          _nursesCount = 0;
          _patientsCount = 0;
          _pendingTransports = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(isRTL ? 'لوحة التحكم' : 'Dashboard'),
        actions: [
          IconButton(
            icon: Badge(label: const Text('3'), child: const Icon(Icons.notifications_outlined)),
            onPressed: () => Navigator.pushNamed(context, '/notifications/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          user?.isAnonymous == true
                              ? Icons.person_outline
                              : Icons.admin_panel_settings,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRTL ? 'مرحباً بك!' : 'Welcome Back!',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.isAnonymous == true
                                ? (isRTL ? 'مستخدم ضيف' : 'Guest User')
                                : (user?.email?.split('@').first ?? 'Admin'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user?.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user!.email!,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Text(
                isRTL ? 'الإحصائيات' : 'Statistics',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    AnimatedStatCard(
                      label: 'Doctors',
                      labelAr: 'الأطباء',
                      value: _doctorsCount,
                      icon: Icons.medical_services_rounded,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () => Navigator.pushNamed(context, '/doctors'),
                      animationDelay: 0,
                    ),
                    AnimatedStatCard(
                      label: 'Nurses',
                      labelAr: 'الممرضين',
                      value: _nursesCount,
                      icon: Icons.local_hospital_rounded,
                      color: const Color(0xFF14B8A6), // Teal
                      onTap: () => Navigator.pushNamed(context, '/nurses'),
                      animationDelay: 100,
                    ),
                    AnimatedStatCard(
                      label: 'Patients',
                      labelAr: 'المرضى',
                      value: _patientsCount,
                      icon: Icons.people_rounded,
                      color: const Color(0xFF10B981), // Green
                      onTap: () => Navigator.pushNamed(context, '/patients'),
                      animationDelay: 200,
                    ),
                    AnimatedStatCard(
                      label: 'Transport',
                      labelAr: 'طلبات النقل',
                      value: _pendingTransports,
                      icon: Icons.local_shipping_rounded,
                      color: const Color(0xFFF59E0B), // Orange
                      onTap: () => Navigator.pushNamed(context, '/transport/requests'),
                      animationDelay: 300,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Quick Actions Section
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    isRTL ? 'الإجراءات السريعة' : 'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AnimatedActionCard(
                title: 'Manage Doctors',
                titleAr: 'إدارة الأطباء',
                subtitle: 'View, add, and edit doctors',
                icon: Icons.medical_services_rounded,
                iconColor: const Color(0xFF3B82F6),
                onTap: () => Navigator.pushNamed(context, '/doctors'),
                animationDelay: 100,
              ),
              const SizedBox(height: 12),

              AnimatedActionCard(
                title: 'Manage Nurses',
                titleAr: 'إدارة الممرضين',
                subtitle: 'View, add, and edit nurses',
                icon: Icons.local_hospital_rounded,
                iconColor: const Color(0xFF14B8A6),
                onTap: () => Navigator.pushNamed(context, '/nurses'),
                animationDelay: 150,
              ),
              const SizedBox(height: 12),

              AnimatedActionCard(
                title: 'Manage Patients',
                titleAr: 'إدارة المرضى',
                subtitle: 'View, add, and edit patients',
                icon: Icons.people_rounded,
                iconColor: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, '/patients'),
                animationDelay: 200,
              ),
              const SizedBox(height: 12),

              AnimatedActionCard(
                title: 'Publications',
                titleAr: 'المنشورات',
                subtitle: 'Manage articles and announcements',
                icon: Icons.article_rounded,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, '/publications'),
                animationDelay: 250,
              ),
              const SizedBox(height: 12),

              AnimatedActionCard(
                title: 'Send Notifications',
                titleAr: 'إرسال إشعارات',
                subtitle: 'Send push notifications to users',
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFEF4444),
                onTap: () => Navigator.pushNamed(context, '/notifications/create'),
                animationDelay: 300,
              ),
              const SizedBox(height: 12),

              AnimatedActionCard(
                title: 'Transport Requests',
                titleAr: 'طلبات النقل',
                subtitle: 'Manage transportation requests',
                icon: Icons.local_shipping_rounded,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => Navigator.pushNamed(context, '/transport/requests'),
                animationDelay: 350,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
