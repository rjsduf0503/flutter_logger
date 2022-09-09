import 'package:flutter/material.dart';
import 'fab.dart';

class FlutterLoggerOverlay {
  static late BuildContext context;
  static bool isOpen = false;
  static OverlayEntry? overlay;

  // Insert overlay in app
  static void insertOverlay() {
    if (!isOpen) {
      overlay = OverlayEntry(
        builder: (context) => const Positioned(
          right: 15,
          bottom: 15,
          child: SafeArea(child: Fab()),
        ),
      );
      Navigator.of(context).overlay!.insert(overlay!);
      isOpen = !isOpen;
    }
  }

  // Remove overlay at app
  static void removeOverlay() {
    if (overlay != null && isOpen) {
      if (overlay?.mounted ?? false) {
        overlay?.remove();
        isOpen = !isOpen;
      }
    }
  }

  static set setOverlay(parentContext) => context = parentContext;
}
