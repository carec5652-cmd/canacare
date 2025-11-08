import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:admin_can_care/provider/app_state_provider.dart';

// Modern Navigation Drawer - القائمة الجانبية الحديثة
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final user = FirebaseAuth.instance.currentUser;
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = appState.themeMode == ThemeMode.dark;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with user info
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.surface,
                        child: Icon(
                          user?.isAnonymous == true
                              ? Icons.person_outline
                              : Icons.admin_panel_settings,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.isAnonymous == true
                          ? (isRTL ? 'مستخدم ضيف' : 'Guest User')
                          : (user?.email?.split('@').first ?? 'Admin'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user?.email != null && user!.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        user?.isAnonymous == true
                            ? (isRTL ? 'ضيف' : 'Guest')
                            : (isRTL ? 'مشرف' : 'Admin'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      avatar: Icon(
                        user?.isAnonymous == true
                            ? Icons.visibility
                            : Icons.verified_user,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: isRTL ? 'لوحة التحكم' : 'Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.medical_services_rounded,
                      title: isRTL ? 'الأطباء' : 'Doctors',
                      badge: '12',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/doctors');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.local_hospital_rounded,
                      title: isRTL ? 'الممرضين' : 'Nurses',
                      badge: '24',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/nurses');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.people_rounded,
                      title: isRTL ? 'المرضى' : 'Patients',
                      badge: '156',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/patients');
                      },
                    ),
                    const Divider(height: 24),
                    _DrawerItem(
                      icon: Icons.article_rounded,
                      title: isRTL ? 'المنشورات' : 'Publications',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/publications');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.notifications_active_rounded,
                      title: isRTL ? 'الإشعارات' : 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications/create');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.local_shipping_rounded,
                      title: isRTL ? 'طلبات النقل' : 'Transport',
                      badge: '8',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/transport/requests');
                      },
                    ),
                    const Divider(height: 24),
                    _DrawerItem(
                      icon: Icons.person_rounded,
                      title: isRTL ? 'الملف الشخصي' : 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Settings Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(isRTL ? 'الوضع الليلي' : 'Dark Mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (value) {
                          appState.toggleTheme();
                        },
                      ),
                    ),
                    
                    // Language Toggle
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Icon(
                        Icons.language,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(isRTL ? 'اللغة' : 'Language'),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('EN')),
                          ButtonSegment(value: 'ar', label: Text('AR')),
                        ],
                        selected: {isRTL ? 'ar' : 'en'},
                        onSelectionChanged: (Set<String> newSelection) {
                          appState.switchLanguage();
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(isRTL ? 'تسجيل الخروج' : 'Sign Out'),
                            content: Text(
                              isRTL
                                  ? 'هل أنت متأكد من تسجيل الخروج؟'
                                  : 'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(isRTL ? 'تسجيل الخروج' : 'Sign Out'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await FirebaseAuth.instance.signOut();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(isRTL ? 'تسجيل الخروج' : 'Sign Out'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Drawer Item Widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

