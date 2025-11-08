import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDark;
  final Locale locale;
  final VoidCallback onToggleTheme;
  final VoidCallback onSwitchLanguage;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isDark,
    required this.locale,
    required this.onToggleTheme,
    required this.onSwitchLanguage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isArabic = locale.languageCode == 'ar';
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      actions: [
        IconButton(
          tooltip: isDark ? 'Light' : 'Dark',
          onPressed: onToggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
        TextButton(
          onPressed: onSwitchLanguage,
          child: Text(isArabic ? 'EN' : 'AR'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
