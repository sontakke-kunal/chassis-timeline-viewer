import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_strings.g.dart';

String? validateText(String? value, String error, {int? minLength}) {
  if (value == null || value.trim().isEmpty || value.trim().length < (minLength ?? 1)) {
    return error;
  } else {
    return null;
  }
}

String? validateTextPreventSpecialCharacters(String? value, String error, {int? minLength}) {
  final trimmed = value?.trim() ?? '';

  // Regex explanation:
  // ^[0-9A-Za-z,\-\/\s]+$
  // └─── allowed chars ──┘
  //   digits, letters, comma, hyphen, slash, whitespace
  final validPattern = RegExp(r'^[0-9A-Za-z,\/\-\s]+$');

  if (trimmed.isEmpty || trimmed.length < (minLength ?? 1)) {
    return error;
  } else if (!validPattern.hasMatch(trimmed)) {
    return LocaleKeys.keySpecialCharactersShouldNotAllowed.localized;
  }
  return null;
}

String? validatePostalCode(String? value, String error, {int? minLength}) {
  final trimmed = value?.trim() ?? '';

  // Regex explanation:
  // ^[0-9A-Za-z,\-\/\s]+$
  // └─── allowed chars ──┘
  //   digits, letters, comma, hyphen, slash, whitespace
  final validPattern = RegExp(r'^[0-9A-Za-z,\/\-\s]+$');

  if (trimmed.isEmpty || trimmed.length < (minLength ?? 1)) {
    return error;
  } else if (trimmed.length < 4 ) {
    return LocaleKeys.keyPostalCodeLengthShouldBeBetween4To10.localized;
  } else if (!validPattern.hasMatch(trimmed)) {
    return LocaleKeys.keySpecialCharactersShouldNotAllowed.localized;
  }
  return null;
}

String? validateLandMarkPreventSpecialCharacters(String? value, String error, {int? minLength}) {
  final trimmed = value?.trim() ?? '';

  // Allowed characters: letters, digits, comma, dot, hyphen, slash, whitespace
  final validPattern = RegExp(r'^[0-9A-Za-z,./\-\s]+$');

  if (trimmed.isEmpty || trimmed.length < (minLength ?? 1)) {
    return error;
  } else if (!validPattern.hasMatch(trimmed)) {
    return LocaleKeys.keySpecialCharactersShouldNotAllowed.localized;
  }
  return null;
}


String? validatePrice(String? value, String error,String zeroError) {
  if (value == null || value.trim().isEmpty) {
    return error;
  } else if((double.tryParse(value)??0) <= 0) {
    return zeroError;
  }else{
    return null;
  }
}

String? validateDropDown(String? value, String error) {
  if (value == null) {
    return error;
  } else {
    return null;
  }
}


String? validateTextIgnoreLength(String? value, String error) {
  if (value == null || value.trim().isEmpty) {
    return error;
  } else {
    return null;
  }
}

/*String? validateMobile(String? value) {
// Indian Mobile number are of 10 digit only
  if (value?.isEmpty == true) {
    return LocalizationStrings.keyYourNumberRequiredValidation.localized;
  } else if(value?.isNotEmpty == true && (value?.trim().length ?? 0) == 9) {
    return LocalizationStrings.keyYourNumberLengthValidation.localized;
  } else {
    return null;
  }
}*/

RegExp mobileRegEx = RegExp(r'[0-9]');
RegExp passwordRegex = RegExp(r'^\S+$');
 RegExp emailRegex = RegExp(r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');
 //Pattern emailRegex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

//
// String? validateMobile(String? value) {
// // Indian Mobile number are of 10 digit only
//   if (value == null || value.trim().length < maxMobileLength) {
//     return LocaleKeys.keyYourNumberRequiredValidation.localized;
//   } else if (!mobileRegEx.hasMatch(value)) {
//     return LocaleKeys.keyYourNumberLengthValidation.localized;
//   } else {
//     return null;
//   }
// }

String? validateMobile(String? value) {
  // Indian Mobile number are of 10 digit only
  if (value == null || value == '') {
    return LocaleKeys.keyContactNumberValidation.localized;
  } else if (value.trim().startsWith('0')) {
    return LocaleKeys.keyMobileNumberCannotStartWith0.localized;
  } else if (value.trim().length < AppConstants.minMobileLength) {
    return'${LocaleKeys.keyContactNumberLengthValidation.localized} ${AppConstants.minMobileLength}-${AppConstants.maxMobileLength} ${LocaleKeys.keyContactNumberLengthValidationMsg2.localized}';
  } else {
    return null;
  }
}

/// Validation function for the validate email
String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  //RegExp regex = RegExp(emailRegex.toString());
  if (trimmed == null || trimmed.isEmpty) {
    return LocaleKeys.keyEmailRequired.localized;
  } else if (!emailRegex.hasMatch(trimmed)) {
    return LocaleKeys.keyInvalidEmailValidation.localized;
  } else {
    return null;
  }
}

/// Validation function for the validate email
String? validateUrl(String? value, String? error) {
  String pattern = r'^(http|https):\/\/([\w.]+\/?)\S*';
  RegExp regExp = RegExp(pattern);
  if ((value ?? '').isEmpty) {
    return LocaleKeys.keyUrlValidation.localized;
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'Please enter valid url';
  }
  return null;
}

/// Validating the password
String? validatePassword(String? value, {bool? isForOld}) {
  if (value == null || value.trim().isEmpty) {
    return (isForOld ?? false) ? LocaleKeys.keyOldPasswordRequired.localized : LocaleKeys.keyPasswordRequired.localized;
  } else if (value.contains(' ')) {
    return (isForOld ?? false) ? LocaleKeys.keyOldPasswordSpaceValidationMsg.localized : LocaleKeys.keyPasswordSpaceValidationMsg.localized;
  } else if (value.length < AppConstants.minPasswordLength || value.length > AppConstants.maxPasswordLength) {
    return (isForOld ?? false) ? LocaleKeys.keyInvalidOldPasswordValidation.localized : LocaleKeys.keyInvalidPasswordValidation.localized;
  } else if (!passwordRegex.hasMatch(value)) {
    return (isForOld ?? false) ? LocaleKeys.keyInvalidOldPasswordValidation.localized : LocaleKeys.keyInvalidPasswordValidation.localized;
  } else {
    return null;
  }
}

/// Validating the passcode
String? validatePasscode(String? value) {
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyPasscodeRequired.localized;
  } else if (value.contains(' ')) {
    return LocaleKeys.keyPasscodeSpaceValidationMsg.localized;
  } else if (value.length < AppConstants.maxLength6) {
    return LocaleKeys.keyInvalidPasscodeValidation.localized;
  } else if (!passwordRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidPasscodeValidation.localized;
  } else {
    return null;
  }
}

String? validateCurrentPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyCurrentPasswordRequired.localized;
  } else if (value.contains(' ')) {
    return LocaleKeys.keyCurrentPasswordSpaceValidationMsg.localized;
  } else if (value.length < AppConstants.minPasswordLength || value.length > AppConstants.maxPasswordLength) {
    return LocaleKeys.keyInvalidCurrentPasswordValidation.localized;
  } else if (!passwordRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidCurrentPasswordValidation.localized;
  } else {
    return null;
  }
}

String? validateConfirmPassword(String? value, String? newPasswordText) {
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyConfirmPasswordRequired.localized;
  } else if (value.contains(' ')) {
    return LocaleKeys.keyConfirmPasswordSpaceValidationMsg.localized;
  } else if (value != newPasswordText) {
    return LocaleKeys.keyConfirmPasswordMustAsPassword.localized;
  } else if (value.length < AppConstants.minPasswordLength || value.length > AppConstants.maxPasswordLength) {
    return LocaleKeys.keyInvalidConfirmPassword.localized;
  }
  // else if (!passwordRegex.hasMatch(value)) {
  //   return LocaleKeys.keyInvalidConfirmPassword.localized;
  // }
   else {
    return null;
  }
}

String? validateNewPassword(String? value, {String? oldPasswordText,bool? isPasswordField}) {
  String removeWhiteSpace = value!.replaceAll(' ', '');

  bool hasUppercase = removeWhiteSpace.contains(RegExp(r'[A-Z]'));
  bool hasDigits = removeWhiteSpace.contains(RegExp(r'[0-9]'));
  bool hasLowercase = removeWhiteSpace.contains(RegExp(r'[a-z]'));
  bool hasSpecialCharacters = removeWhiteSpace.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  if (value.removeWhiteSpace.isEmpty) {
    return isPasswordField??false?LocaleKeys.keyPasswordRequired.localized:LocaleKeys.keyNewPasswordRequired.localized;
  } else if (!hasUppercase) {
    return LocaleKeys.keyContainUpper.localized;
  } else if (!hasLowercase) {
    return LocaleKeys.keyContainLower.localized;
  } else if (!hasDigits) {
    return LocaleKeys.keyContainNumeric.localized;
  } else if (!hasSpecialCharacters) {
    return LocaleKeys.keyContainSpecialCharacter.localized;
  } else if (value.removeWhiteSpace.length > AppConstants.maxPasswordLength || value.removeWhiteSpace.length < AppConstants.minPasswordLength) {
    return isPasswordField??false?LocaleKeys.keyInvalidPasswordValidation.localized:LocaleKeys.keyInvalidNewPasswordValidation.localized;
  } else if ((oldPasswordText?.isNotEmpty ?? false) && oldPasswordText == value) {
    return LocaleKeys.keyNewPasswordMustDifferent.localized;
  }else {
    return null;
  }
  // if (value == null || value.trim().isEmpty) {
  //   return LocaleKeys.keyNewPasswordRequired.localized;
  // } else if (value.contains(' ')) {
  //   return LocaleKeys.keyNewPasswordSpaceValidationMsg.localized;
  // } else if (value.length < AppConstants.minPasswordLength || value.length > AppConstants.maxPasswordLength) {
  //   return LocaleKeys.keyInvalidNewPasswordValidation.localized;
  // } else if (!passwordRegex.hasMatch(value)) {
  //   return LocaleKeys.keyInvalidNewPasswordValidation.localized;
  // } else if ((oldPasswordText?.isNotEmpty ?? false) && oldPasswordText == value) {
  //   return LocaleKeys.keyNewPasswordMustDifferent.localized;
  // } else {
  //   return null;
  // }
}

String? validateOtp(String? value) {
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyOTPShouldBeRequired.localized;
  } else if (value.trim().length < AppConstants.otpLength) {
    return LocaleKeys.keyPleaseEnterValidOTP.localized;
  }
  return null;
}

String? validateFloorNumber(String? value, int? minValue) {
  final int? currentValue = int.tryParse(value ?? '0');
  if (value == null || value.isEmpty) {
    return LocaleKeys.keyNoOfFloorRequired.localized;
  } else if (minValue == null) {
    return null;
  } else if (currentValue! < minValue) {
    return LocaleKeys.keyFloorNoIncrementedValidationMsg.localized;
  }
  return null;
}

final hostNameRegex = RegExp(r'^[A-Za-z0-9\- ]+$');
String? validateHostName(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyHostNameRequiredValidation.localized;
  } else if (!hostNameRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidHostNameValidation.localized;
  }
  return null;
}

final serialNoRegex = RegExp(r'^[0-9\. ]+$');
String? validateSerialNo(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keySerialNumberRequiredValidation.localized;
  } else if (!serialNoRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidSerialNoValidation.localized;
  }
  return null;
}
String? validatePowerBoardVersion(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyPowerboardVersionRequiredValidation.localized;
  } else if (!serialNoRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidPowerBoardVersionValidation.localized;
  }
  return null;
}

String? validateNavigationVersion(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyNavigationVersionRequiredValidation.localized;
  } else if (!serialNoRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidNavigationVersionValidation.localized;
  }
  return null;
}

final packageNameRegex = RegExp(r'^[A-Za-z0-9_. ]+$');
String? validatePackageName(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyPackageIdRequiredValidation.localized;
  } else if (!packageNameRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidPackageIdValidation.localized;
  }
  return null;
}

final androidIdRegex = RegExp(r'^[A-Za-z0-9_. ]+$');
String? validateAndroidId(String? value){
  if (value == null || value.trim().isEmpty) {
    return LocaleKeys.keyAndroidIdRequiredValidation.localized;
  } else if (!androidIdRegex.hasMatch(value)) {
    return LocaleKeys.keyInvalidAndroidIdValidation.localized;
  }
  return null;
}

String? validatePurchasePrice(String? value,int finalPrice) {
  // if (value == null || value.trim().isEmpty) return null;
  //
  final parsedValue = int.tryParse(value??'');
  if (parsedValue == null || value=='') {
    return LocaleKeys.keyFinalPurchasePriceRequired.localized;
  }else if (parsedValue < 0 && parsedValue > finalPrice) {
    return LocaleKeys.keyFinalPurchasePriceLengthValidation.localized;
  }
  return null;
}

String? validateGSTNumber(String? value, String error) {
  final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$');

  if (value == null || value.trim().isEmpty || !gstRegex.hasMatch(value.trim())) {
    return error;
  } else {
    return null;
  }
}

String? validateChangePassword(String? value) {
  String removeWhiteSpace = value!.replaceAll(' ', '');

  bool hasUppercase = removeWhiteSpace.contains(RegExp(r'[A-Z]'));
  bool hasDigits = removeWhiteSpace.contains(RegExp(r'[0-9]'));
  bool hasLowercase = removeWhiteSpace.contains(RegExp(r'[a-z]'));
  bool hasSpecialCharacters = removeWhiteSpace.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  if (value.removeWhiteSpace.isEmpty) {
    return LocaleKeys.keyNewPasswordRequired.localized;
  } else if (value.removeWhiteSpace.length > 16 || value.removeWhiteSpace.length < 8) {
    return LocaleKeys.keyInvalidNewPasswordValidation.localized;
  } else if (!hasUppercase) {
    return LocaleKeys.keyContainUpper.localized;
  } else if (!hasLowercase) {
    return LocaleKeys.keyContainLower.localized;
  } else if (!hasDigits) {
    return LocaleKeys.keyContainNumeric.localized;
  } else if (!hasSpecialCharacters) {
    return LocaleKeys.keyContainSpecialCharacter.localized;
  } else {
    return null;
  }
}
