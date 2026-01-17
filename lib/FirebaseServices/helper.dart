import 'package:intl/intl.dart';

class Helper {
  // Format DateTime to readable string
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      // Today
      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          if (diff.inMinutes == 0) {
            return 'Just now';
          }
          return '${diff.inMinutes} min ago';
        }
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      }

      // Yesterday
      if (diff.inDays == 1) {
        return 'Yesterday';
      }

      // This week
      if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      }

      // Older - show full date
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  // Format DateTime with time
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  // Validate note fields
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Content is required';
    }
    return null;
  }

  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
