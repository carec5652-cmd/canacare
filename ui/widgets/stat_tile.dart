import 'package:flutter/material.dart';

// Stat Tile Widget - لوحة إحصائيات
// Used for displaying statistics on dashboard
class StatTile extends StatelessWidget {
  final String label;
  final String? labelAr; // Arabic label
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.label,
    this.labelAr,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final displayLabel = isRTL && labelAr != null ? labelAr! : label;
    final statColor = color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: statColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
