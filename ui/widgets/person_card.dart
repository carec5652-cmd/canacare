import 'package:flutter/material.dart';

// Person Card Widget - بطاقة شخص
// Used for displaying doctor/nurse/patient info in lists
class PersonCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? photoUrl;
  final String? status;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const PersonCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.photoUrl,
    this.status,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                backgroundImage:
                    (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
                child:
                    (photoUrl == null || photoUrl!.isEmpty)
                        ? Icon(Icons.person, color: theme.primaryColor, size: 28)
                        : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 4),
                      _buildStatusChip(context, status!),
                    ],
                  ],
                ),
              ),
              // Actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        label = 'Active / نشط';
        break;
      case 'inactive':
        color = Colors.orange;
        label = 'Inactive / غير نشط';
        break;
      case 'suspended':
        color = Colors.red;
        label = 'Suspended / موقوف';
        break;
      case 'discharged':
        color = Colors.blue;
        label = 'Discharged / خرج';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
