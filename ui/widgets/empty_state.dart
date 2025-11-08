import 'package:flutter/material.dart';

// Empty State Widget - حالة فارغة
// Shows when there's no data to display
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? messageAr;
  final String? actionLabel;
  final String? actionLabelAr;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.messageAr,
    this.actionLabel,
    this.actionLabelAr,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final displayMessage = isRTL && messageAr != null ? messageAr! : message;
    final displayActionLabel = isRTL && actionLabelAr != null ? actionLabelAr! : actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.textTheme.bodySmall?.color?.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(displayActionLabel ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
