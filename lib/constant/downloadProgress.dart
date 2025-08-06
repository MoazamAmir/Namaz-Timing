import 'package:flutter/material.dart';

class DownloadProgress {
  final int chapterId;
  final String reciterName;
  final double progress;
  final bool isCompleted;
  final bool isFailed;

  DownloadProgress({
    required this.chapterId,
    required this.reciterName,
    required this.progress,
    this.isCompleted = false,
    this.isFailed = false,
  });
}

// Constants
class AppColors {
  static Color primary = Colors.teal[800]!;
  static Color primaryLight = Colors.teal[600]!;
  static Color background = Colors.white;
  static Color cardBackground = Colors.white;
  static Color textPrimary = Colors.teal[800]!;
  static Color textSecondary = Colors.grey[600]!;
  static Color downloadColor = Colors.teal[600]!;
  static Color successColor = Colors.teal[600]!;
}