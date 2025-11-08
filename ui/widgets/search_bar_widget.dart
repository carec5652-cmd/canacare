import 'package:flutter/material.dart';

// Search Bar Widget - شريط البحث
// Custom search bar with RTL support
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? hintTextAr;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.hintTextAr,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final displayHint = isRTL && hintTextAr != null ? hintTextAr! : hintText;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: displayHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear!();
                    if (onChanged != null) onChanged!('');
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
