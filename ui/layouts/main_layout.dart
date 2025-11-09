import 'package:flutter/material.dart';
import 'package:admin_can_care/ui/widgets/app_menu_bar.dart';

/// Main Layout with Top Menu Bar
/// تخطيط رئيسي مع شريط قائمة علوي
class MainLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? titleAr;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const MainLayout({
    super.key,
    required this.child,
    this.title,
    this.titleAr,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppMenuBar(title: title, titleAr: titleAr, actions: actions) : null,
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
