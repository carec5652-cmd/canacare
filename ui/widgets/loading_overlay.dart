import 'package:flutter/material.dart';

// Loading Overlay Widget - تراكب التحميل
// Shows a loading indicator overlay on the screen
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final String? messageAr;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.messageAr,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null || messageAr != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _getDisplayMessage(context),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getDisplayMessage(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    if (isRTL && messageAr != null) return messageAr!;
    return message ?? 'Loading... / جاري التحميل...';
  }
}
