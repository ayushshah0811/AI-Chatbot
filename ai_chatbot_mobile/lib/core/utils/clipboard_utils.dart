import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility for clipboard operations with user feedback.
///
/// Wraps Flutter's [Clipboard] API and provides methods to copy text
/// with optional snackbar/overlay feedback to the user.
class ClipboardUtils {
  ClipboardUtils._();

  /// Copies [text] to the system clipboard.
  ///
  /// Returns `true` if the copy operation succeeded, `false` otherwise.
  static Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      debugPrint('ClipboardUtils: Failed to copy to clipboard: $e');
      return false;
    }
  }

  /// Reads text from the system clipboard.
  ///
  /// Returns the clipboard text, or `null` if the clipboard is empty
  /// or an error occurred.
  static Future<String?> readFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('ClipboardUtils: Failed to read from clipboard: $e');
      return null;
    }
  }

  /// Copies [text] to the clipboard and shows a brief feedback message
  /// using the nearest [ScaffoldMessenger].
  ///
  /// If [context] is not mounted or has no [ScaffoldMessenger], the copy
  /// still occurs but no feedback is shown.
  static Future<bool> copyWithFeedback(
    String text, {
    required BuildContext context,
    String successMessage = 'Copied to clipboard',
    String failureMessage = 'Failed to copy',
  }) async {
    final success = await copyToClipboard(text);

    if (context.mounted) {
      _showFeedback(context, success ? successMessage : failureMessage);
    }

    return success;
  }

  /// Shows a brief snackbar-style feedback message.
  static void _showFeedback(BuildContext context, String message) {
    // Using overlay to avoid ScaffoldMessenger dependency at utility level.
    // Consumers can also use ScaffoldMessenger directly if preferred.
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: const Color(0xDD000000),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}
