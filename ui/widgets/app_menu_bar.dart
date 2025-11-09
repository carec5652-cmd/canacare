import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:admin_can_care/provider/app_state_provider.dart';

/// Modern Top Menu Bar - شريط القائمة العلوي الحديث
class AppMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? titleAr;
  final List<Widget>? actions;

  const AppMenuBar({
    super.key,
    this.title,
    this.titleAr,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final user = FirebaseAuth.instance.currentUser;
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = appState.themeMode == ThemeMode.dark;
    
    final displayTitle = isRTL ? (titleAr ?? title) : title;

    return AppBar(
      title: Text(displayTitle ?? 'Can Care Admin'),
      leading: _buildLogoMenu(context, theme),
      actions: [
        // Main Navigation Menu
        _buildNavMenu(context, theme, isRTL),
        
        const SizedBox(width: 8),
        
        // Notifications
        IconButton(
          icon: Badge(
            label: const Text('3'),
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => Navigator.pushNamed(context, '/notifications/create'),
          tooltip: isRTL ? 'الإشعارات' : 'Notifications',
        ),
        
        // Dark Mode Toggle
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => appState.toggleTheme(),
          tooltip: isRTL ? 'الوضع الليلي' : 'Dark Mode',
        ),
        
        // Language Toggle
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => appState.switchLanguage(),
          tooltip: isRTL ? 'English' : 'العربية',
        ),
        
        // User Menu
        _buildUserMenu(context, theme, isRTL, user),
        
        const SizedBox(width: 8),
        
        // Custom Actions
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildLogoMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
      ),
      tooltip: 'Menu',
      onSelected: (value) => Navigator.pushNamed(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: '/dashboard',
          child: ListTile(
            leading: Icon(Icons.dashboard_rounded),
            title: Text('Dashboard / لوحة التحكم'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildNavMenu(BuildContext context, ThemeData theme, bool isRTL) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_rounded),
      tooltip: isRTL ? 'القائمة' : 'Menu',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => Navigator.pushNamed(context, value),
      itemBuilder: (context) => [
        // Doctors
        PopupMenuItem(
          value: '/doctors',
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_services_rounded, color: Colors.blue),
            ),
            title: Text(isRTL ? 'الأطباء' : 'Doctors'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        
        // Nurses
        PopupMenuItem(
          value: '/nurses',
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: Colors.teal),
            ),
            title: Text(isRTL ? 'الممرضين' : 'Nurses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        
        // Patients
        PopupMenuItem(
          value: '/patients',
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people_rounded, color: Colors.green),
            ),
            title: Text(isRTL ? 'المرضى' : 'Patients'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        
        const PopupMenuDivider(),
        
        // Publications
        PopupMenuItem(
          value: '/publications',
          child: ListTile(
            leading: const Icon(Icons.article_rounded, color: Colors.purple),
            title: Text(isRTL ? 'المنشورات' : 'Publications'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        
        // Transport
        PopupMenuItem(
          value: '/transport/requests',
          child: ListTile(
            leading: const Icon(Icons.local_shipping_rounded, color: Colors.orange),
            title: Text(isRTL ? 'طلبات النقل' : 'Transport'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '8',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, ThemeData theme, bool isRTL, User? user) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                user?.isAnonymous == true ? Icons.person_outline : Icons.admin_panel_settings,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              user?.isAnonymous == true
                  ? (isRTL ? 'ضيف' : 'Guest')
                  : (user?.email?.split('@').first ?? 'Admin'),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        // Profile
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(isRTL ? 'الملف الشخصي' : 'Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        
        const PopupMenuDivider(),
        
        // Logout
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              isRTL ? 'تسجيل الخروج' : 'Sign Out',
              style: const TextStyle(color: Colors.red),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(isRTL ? 'تسجيل الخروج' : 'Sign Out'),
              content: Text(
                isRTL ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to sign out?',
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
        } else if (value == 'profile') {
          Navigator.pushNamed(context, '/profile');
        }
      },
    );
  }
}

