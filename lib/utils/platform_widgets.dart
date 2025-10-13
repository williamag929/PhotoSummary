import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PlatformWidgets {
  static bool get isIOS => Platform.isIOS;

  // Haptic feedback helper
  static void lightHaptic() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumHaptic() {
    if (isIOS) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyHaptic() {
    if (isIOS) {
      HapticFeedback.heavyImpact();
    }
  }

  static void selectionHaptic() {
    if (isIOS) {
      HapticFeedback.selectionClick();
    }
  }

  // Show platform-specific dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }
  }

  // Platform-specific loading indicator
  static Widget loadingIndicator() {
    if (isIOS) {
      return const CupertinoActivityIndicator();
    } else {
      return const CircularProgressIndicator();
    }
  }

  // Platform-specific button
  static Widget primaryButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
    bool isDestructive = false,
  }) {
    if (isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
      );
    }
  }
}
