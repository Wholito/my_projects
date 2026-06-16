import 'package:flutter/material.dart';

class ToastService {
  static OverlayEntry? _overlayEntry;

  static void showToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _hideToast();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(message, style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(duration, () => _hideToast());
  }

  static void _hideToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}