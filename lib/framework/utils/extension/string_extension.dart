import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:chassis_timeline_viewer/framework/utils/session.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_enums.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/theme.dart';

extension StringExtension on String {
  String get capsFirstLetterOfSentence => '${this[0].toUpperCase()}${substring(1)}';

  String get allInCaps => toUpperCase();

  String get capitalizeFirstLetterOfSentence => split(' ').map((str) => str.capsFirstLetterOfSentence).join(' ');

  String get removeWhiteSpace => replaceAll(' ', '');

  bool get isEmptyString => removeWhiteSpace.isEmpty;

  String get trimSpace => trim().replaceAll(RegExp(r'\s+'), ' ');

  String get encodedURL => Uri.encodeFull(this);

  bool toBool() => toLowerCase() == 'true';

  String get removeNewLines {
    return replaceAll(RegExp(r'[\n\r]+'), '');
  }

  String get encrypt {
    if (Session.aesIv.isNotEmpty && Session.aesKey.isNotEmpty) {
      //TODO : REPLACE WITH AES WHEN DONE
      return endPointEncrypt;
    }
    return endPointEncrypt;
  }

  String get decrypt {
    if (Session.aesIv.isNotEmpty && Session.aesKey.isNotEmpty) {
      //TODO : REPLACE WITH AES WHEN DONE
      return endPointDecrypt;
    }
    return endPointDecrypt;
  }

  String get endPointEncrypt {
    return this;
    // var str = base64Encode(utf8.encode(this)); /// getting Y2l0eVV1aWQ=
    final base64Str = base64Url.encode(utf8.encode(this)).replaceAll('=', '');

    /// Remove '=' padding manually
    final encodedKey = Uri.encodeQueryComponent(base64Str);

    /// getting Y2l0eVV1aWQ to avoid key is not match when route restore, safe for route URL/query parsing
    return encodedKey;
  }

  String get endPointDecrypt {
    return this;
    // var str = utf8.decode(base64Decode(this));
    final percentDecoded = Uri.decodeQueryComponent(this);
    final padded = percentDecoded.padRight((percentDecoded.length + 3) ~/ 4 * 4, '=');
    var str = utf8.decode(base64Url.decode(padded));
    return str;
  }

  String get cleanAddress {
    return replaceAll(RegExp(r'[\t\r\n]+'), ' ') // Replace tabs, \r, \n with space
        .replaceAll(RegExp(r'\s*,\s*'), ', ') // Ensure single space after commas
        .replaceAll(RegExp(r'\s+'), ' ') // Collapse multiple spaces
        .trim(); // Trim start/end spaces
  }

  bool get isTrue => (this == '1' || toLowerCase() == 't' || toLowerCase() == 'true' || toLowerCase() == 'y' || toLowerCase() == 'yes');

  String get localized => this.tr();

  String get currencyForm => NumberFormat.currency(locale: 'en_US', name: Session.appCurrency).format(double.tryParse(this) ?? 0);

  String get currencyFormShort {
    final value = double.tryParse(this) ?? 0.0;

    if (value >= 1000000) {
      return '${NumberFormat.currency(locale: 'en_US', name: Session.appCurrency, decimalDigits: 1).format(value / 1000000)}M';
    } else if (value >= 1000) {
      return '${NumberFormat.currency(locale: 'en_US', name: Session.appCurrency, decimalDigits: 1).format(value / 1000)}K';
    } else {
      return NumberFormat.currency(locale: 'en_US', name: Session.appCurrency, decimalDigits: 2).format(value);
    }
  }

  ///Date Format
  String getCustomDateTimeFormat(String inputFormat, String outputFormat, {bool isCheckPresent = false}) {
    if (this == '' || inputFormat == '' || outputFormat == '') {
      return '';
    }
    DateTime dateTime = getDateTimeObject(inputFormat);
    String value = DateFormat(outputFormat).format(dateTime);
    if (isCheckPresent) {
      DateTime currentDateTime = DateTime.now();
      if (dateTime.year == currentDateTime.year && dateTime.month == currentDateTime.month && dateTime.day == currentDateTime.day) {
        value = 'Present';
      }
    }
    return value;
  }

  DateTime getDateTimeObject(String inputFormat) {
    return DateFormat(inputFormat).parse(this);
  }

  String get removeLast {
    if (isEmpty) return this;
    var list = split('');
    list.removeLast();
    return list.join('');
  }

  bool containsCharactersInOrder(String pattern) {
    if (isEmpty) return true;
    final source = toLowerCase();
    final target = pattern.toLowerCase();

    // Ensure string starts with the first character of the pattern
    if (target.isEmpty || source.isEmpty) return false;
    if (source.indexOf(target[0]) != 0) return false;

    int lastIndex = 0;
    for (int i = 1; i < target.length; i++) {
      lastIndex = source.indexOf(target[i], lastIndex + 1);
      if (lastIndex == -1) return false;
    }

    return true;
  }

  String getCustomDateTimeFromUTC(String outputFormat) {
    if (this != '' && outputFormat != '') {
      try {
        DateTime temp = DateTime.parse(this).toUtc().toLocal();
        return DateFormat(outputFormat).format(temp);
      } catch (e) {
        return DateFormat(outputFormat).format(DateTime.now());
      }
    } else {
      return '';
    }
  }

  ///Validations
  bool isPasswordValid() {
    if (length >= 8 && length <= 15) {
      return true;
    } else {
      return false;
    }
  }

  bool isPhoneNumberValid() {
    if (length > 0 && length == 10) {
      return true;
    } else {
      return false;
    }
  }

  bool isEmailValid() {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    // RegExp regex = new RegExp(pattern);
    RegExp regex = RegExp(pattern.toString());
    if (!(regex.hasMatch(this))) {
      return false;
    } else {
      return true;
    }
  }

  bool isWebsiteValid() {
    final urlRegExp = RegExp(r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');

    if (!(urlRegExp.hasMatch(this))) {
      return false;
    } else {
      return true;
    }
  }

  String get toRequiredText => '$this ${LocaleKeys.keyShouldBeRequired.localized}';

  TicketReasonPlatformType? ticketReasonPlatformTypeToString() {
    switch (this) {
      case 'CLIENT':
        return TicketReasonPlatformType.CLIENT;
      case 'DESTINATION':
        return TicketReasonPlatformType.DESTINATION;
    }
    return null;
  }

  String toCapitalized() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  Color getStatusColor() {
    String status = this;
    final Color statusColor;
    switch (status) {
      case 'PENDING':
        statusColor = AppColors.clrF79009;
        break;
      case 'REJECTED':
        statusColor = AppColors.clrF04438;
        break;
      case 'ACTIVE':
        statusColor = AppColors.clr12B76A;
        break;
      case 'INACTIVE':
        statusColor = AppColors.clrF04438;
        break;
      default:
        statusColor = AppColors.clr12B76A;
        break;
    }
    return statusColor;
  }

  Color get colorFromHex {
    var hex = replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }
}

extension BoolExtension on bool? {
  /// get active, de active from bool value
  String? get toActiveStatusText => (this == null)
      ? null
      : (this == true)
      ? LocaleKeys.keyActive.localized
      : LocaleKeys.keyDeActive.localized;
}



extension ListJoinExtension on List {
  String get joinChunks {
    return join();
  }
}

extension NumExtension on num {
  String get digitValues{
    if (this % 1 == 0) {return this.toInt().toString();} else {return this.toStringAsFixed(3);}
  }
}


extension TrimmedNumericString on String {
  String toTrimmedNumeric() {
    final value = double.tryParse(this);
    if (value == null) return this; // fallback if not a valid number

    final rounded = double.parse(value.toStringAsFixed(2));
    return rounded % 1 == 0
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(2);
  }
}