import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension TimeExtension on TimeOfDay {
  String get convertToDateTime {
    final now = DateTime.now();
    return DateFormat('HH:mm:ss').format(DateTime(now.year, now.month, now.day, hour, minute));
  }

  String get convertToDateTimeHHMMA {
    final now = DateTime.now();
    return DateFormat('hh:mm a').format(DateTime(now.year, now.month, now.day, hour, minute));
  }
}


extension DateFormatting on DateTime? {
  String toYMDString() {
    if (this == null) return '';
    return '${this!.year.toString().padLeft(4, '0')}-'
        '${this!.month.toString().padLeft(2, '0')}-'
        '${this!.day.toString().padLeft(2, '0')}';
  }

  bool isToday() {
    if (this == null) return false;

    final now = DateTime.now();
    return this!.year == now.year &&
        this!.month == now.month &&
        this!.day == now.day;
  }
}