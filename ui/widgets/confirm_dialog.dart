import 'package:flutter/material.dart';

// Confirm Dialog - مربع حوار التأكيد
// Shows a confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? titleAr;
  final String message;
  final String? messageAr;
  final String confirmText;
  final String? confirmTextAr;
  final String cancelText;
  final String? cancelTextAr;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.titleAr,
    required this.message,
    this.messageAr,
    this.confirmText = 'Confirm',
    this.confirmTextAr = 'تأكيد',
    this.cancelText = 'Cancel',
    this.cancelTextAr = 'إلغاء',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final displayTitle = isRTL && titleAr != null ? titleAr! : title;
    final displayMessage = isRTL && messageAr != null ? messageAr! : message;
    final displayConfirm = isRTL && confirmTextAr != null ? confirmTextAr! : confirmText;
    final displayCancel = isRTL && cancelTextAr != null ? cancelTextAr! : cancelText;

    return AlertDialog(
      title: Text(displayTitle),
      content: Text(displayMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(displayCancel)),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style:
              isDestructive
                  ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                  : null,
          child: Text(displayConfirm),
        ),
      ],
    );
  }

  // Helper method to show dialog
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? titleAr,
    required String message,
    String? messageAr,
    String confirmText = 'Confirm',
    String? confirmTextAr = 'تأكيد',
    String cancelText = 'Cancel',
    String? cancelTextAr = 'إلغاء',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: title,
            titleAr: titleAr,
            message: message,
            messageAr: messageAr,
            confirmText: confirmText,
            confirmTextAr: confirmTextAr,
            cancelText: cancelText,
            cancelTextAr: cancelTextAr,
            isDestructive: isDestructive,
          ),
    );
    return result ?? false;
  }
}
