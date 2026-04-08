import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:chassis_timeline_viewer/framework/dependency_injection/inject.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart';
import 'package:chassis_timeline_viewer/ui/routing/stack.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';

const String keyRoleType = 'keyRoleType';
const String keyEntityUuid = 'keyEntityUuid';
const String keyUserUuid = 'keyUserUuid';
const String keyClientUuid = 'keyClientUuid';
const String keyEntityType = 'keyEntityType';
const String keyRoleUuid = 'keyRoleUuid';
const String keyEmail = 'keyEmail';
const String keyContactNumber = 'keyContactNumber';
const String keyAppOtpSeconds = 'keyAppOtpSeconds';
const String keyAppLanguageUuid = 'keyAppLanguageUuid';
const String keyUserType = 'keyUserType';
const String keyAppLanguage = 'keyAppLanguage';
const String keyTextDirection = 'keyTextDirection';
const String keyFCMToken = 'keyFCMToken';
const String keyDeviceId = 'keyDeviceId';
const String keyCurrency = 'keyCurrency';
const String keyPermissions = 'keyPermissions';

class Session {
  Session._();

  static Session session = Session._();

  static var sessionBox = Hive.box(AppConstants.userBoxName);

  static String get fcmToken => sessionBox.get(keyFCMToken) ?? '';

  static String get deviceId => sessionBox.get(keyDeviceId) ?? '';

  static set fcmToken(String? fcmToken) => saveLocalData(keyFCMToken, fcmToken);

  static set deviceId(String? deviceId) => saveLocalData(keyDeviceId, deviceId);

  static String getAppLanguage() => (sessionBox.get(keyAppLanguage) ?? '');

  static String keyAesIv = 'keyAesIv';

  static String get aesIv => sessionBox.get(keyAesIv) ?? '';

  static set aesIv(String aesIv) => saveLocalData(keyAesIv, aesIv);

  static String keyAesKey = 'keyAesKey';

  static String get aesKey => sessionBox.get(keyAesKey) ?? '';

  static set aesKey(String aesKey) => saveLocalData(keyAesKey, aesKey);

  static String keyIsRtL = 'keyIsRtL';

  static bool get isRTL => sessionBox.get(keyIsRtL) ?? false;

  static set isRTL(bool isRTL) => saveLocalData(keyIsRtL, isRTL);

  static List<String> getCacheData(String key) => ((jsonDecode(sessionBox.get(key) ?? jsonEncode([]))) as List).map((e) => e.toString()).toList();

  static setCacheData(String key, List<String> cacheData) => saveLocalData(key, jsonEncode(cacheData));

  static String getUserType() => (sessionBox.get(keyUserType) ?? '');

  static set userType(String userType) => (saveLocalData(keyUserType, userType));

  static String getRoleType() => (sessionBox.get(keyRoleType) ?? '');

  static set roleType(String roleType) => (saveLocalData(keyRoleType, roleType));

  static String getRoleUuid() => (sessionBox.get(keyRoleUuid) ?? '');

  static set roleUuid(String roleUuid) => (saveLocalData(keyRoleUuid, roleUuid));

  static String get userUuid => (sessionBox.get(keyUserUuid) ?? '');

  static set userUuid(String userUuid) => (saveLocalData(keyUserUuid, userUuid));

  static String getClientUuid() => (sessionBox.get(keyClientUuid) ?? '');

  static set clientUuid(String clientUuid) => (saveLocalData(keyClientUuid, clientUuid));

  static String get contactNumber => (sessionBox.get(keyContactNumber) ?? '');

  static set contactNumber(String contactNumber) => (saveLocalData(keyContactNumber, contactNumber));

  static String get email => (sessionBox.get(keyEmail) ?? '');

  static set email(String email) => (saveLocalData(keyEmail, email));

  static String keyCurrentEnvironment = 'keyCurrentEnvironment';

  static String get currentEnvironment => sessionBox.get(keyCurrentEnvironment) ?? Env.kodyrobots;

  static set currentEnvironment(String env) => saveLocalData(keyCurrentEnvironment, env);

  static String get entityUuid {
    if (sessionBox.get(keyEntityType) is String) {
      sessionBox.put(keyEntityType, null);
    }
    final String env = currentEnvironment;
    if (sessionBox.get(keyEntityUuid) is String) {
      sessionBox.put(keyEntityUuid, null);
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(sessionBox.get(keyEntityUuid) ?? {});

    return map[env] ?? '';
  }

  static set entityUuid(String? value) {
    if (sessionBox.get(keyEntityUuid) is String) {
      sessionBox.put(keyEntityUuid, null);
    }
    final String env = currentEnvironment;

    final Map<String, dynamic> map = Map<String, dynamic>.from(sessionBox.get(keyEntityUuid) ?? {});

    if (value == null || value.isEmpty) {
      map.remove(env);
    } else {
      map[env] = value;
    }

    saveLocalData(keyEntityUuid, map);
  }

  static String get entityType {
    if (sessionBox.get(keyEntityType) is String) {
      sessionBox.put(keyEntityType, null);
    }
    final String env = currentEnvironment;

    if (sessionBox.get(keyEntityType) is String) {
      sessionBox.put(keyEntityType, null);
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(sessionBox.get(keyEntityType) ?? {});

    return map[env] ?? '';
  }

  static set entityType(String? value) {
    if (sessionBox.get(keyEntityType) is String) {
      sessionBox.put(keyEntityType, null);
    }
    final String env = currentEnvironment;

    final Map<String, dynamic> map = Map<String, dynamic>.from(sessionBox.get(keyEntityType) ?? {});

    if (value == null || value.isEmpty) {
      map.remove(env);
    } else {
      map[env] = value;
    }

    saveLocalData(keyEntityType, map);
  }

  static String keyUserAccessToken = 'keyUserAuthToken';

  static String get userAccessToken {
    final String env = currentEnvironment;
    if (sessionBox.get(keyUserAccessToken) is String) {
      sessionBox.put(keyUserAccessToken, null);
    }
    final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(sessionBox.get(keyUserAccessToken) ?? {});

    return tokenMap[env] ?? '';
  }

  static set userAccessToken(String? token) {
    final String env = currentEnvironment;

    final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(sessionBox.get(keyUserAccessToken) ?? {});

    if (token == null || token.isEmpty) {
      tokenMap.remove(env);
    } else {
      tokenMap[env] = token;
    }

    saveLocalData(keyUserAccessToken, tokenMap);
  }

  static String keyRefreshToken = 'keyRefreshToken';

  static String get refreshToken {
    final String env = currentEnvironment;
    if (sessionBox.get(keyRefreshToken) is String) {
      sessionBox.put(keyRefreshToken, null);
    }
    final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(sessionBox.get(keyRefreshToken) ?? {});

    return tokenMap[env] ?? '';
  }

  static set refreshToken(String? token) {
    final String env = currentEnvironment;

    final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(sessionBox.get(keyRefreshToken) ?? {});

    if (token == null || token.isEmpty) {
      tokenMap.remove(env);
    } else {
      tokenMap[env] = token;
    }

    saveLocalData(keyRefreshToken, tokenMap);
  }

  static String keyLanguageModel = 'keyLanguageModel';

  static set languageModel(String languageRes) => saveLocalData(keyLanguageModel, languageRes);

  static String get languageModel => (sessionBox.get(keyLanguageModel) ?? '');

  static set appCurrency(String currency) => saveLocalData(keyCurrency, currency);

  static String get appCurrency => (sessionBox.get(keyCurrency) ?? AppConstants.currency);

  static void saveLocalData(String key, dynamic value) {
    sessionBox.put(key, value);
  }

  static String getPermissionFromHive() => (sessionBox.get(keyPermissions));

  static const String keyStoreMappingResultHelper = 'keyStoreMappingResultHelper';

  /// Builds the Hive key used to cache a store-mapping result.
  static String _storeMappingKey(String destinationUuid, String floorUuid) => '$keyStoreMappingResultHelper\_${destinationUuid}\_${floorUuid}';

  /// Default structure when nothing is cached yet.
  static Map<String, dynamic> _defaultStoreMappingResult() => <String, dynamic>{
    'synced_time': '',
    'data': {},
  };

  static Map<String, dynamic>? getStoreMappingResult(String destinationUuid, String floorUuid) {
    final String key = _storeMappingKey(destinationUuid, floorUuid);
    final dynamic raw = sessionBox.get(key);
    if (raw == null) return null;

    try {
      final Map<String, dynamic> map = raw is String ? Map<String, dynamic>.from(jsonDecode(raw) as Map) : Map<String, dynamic>.from(raw as Map);

      final String syncedTime = (map['synced_time'] ?? '').toString();

      final Map<String, String> data = <String, String>{};
      if (map['data'] is Map) {
        (map['data'] as Map).forEach((key, value) {
          data[key.toString()] = (value ?? '').toString();
        });
      }

      return <String, dynamic>{
        'synced_time': syncedTime,
        'data': data,
      };
    } catch (_) {
      return _defaultStoreMappingResult();
    }
  }

  static void setStoreMappingResult(String destinationUuid, String floorUuid, Map<String, dynamic> locationMapper) {
    final String key = _storeMappingKey(destinationUuid, floorUuid);

    final String syncedTime = (locationMapper['synced_time'] ?? '').toString();

    final Map<String, dynamic> data = <String, dynamic>{};
    if (locationMapper['data'] is Map) {
      (locationMapper['data'] as Map).forEach((k, v) {
        if (v is Map) {
          v = jsonEncode(v);
        }
        data[k.toString()] = v;
      });
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'synced_time': syncedTime,
      'data': data,
    };

    saveLocalData(key, jsonEncode(payload));
  }

  ///Session Logout
  static Future sessionLogout(WidgetRef ref, BuildContext context) async {
    String appLanguageUUid = getAppLanguage();

    // if (Session.deviceId.isNotEmpty) {
    //   await ref.read(loginController).logoutApi(context).then(
    //     (value) async {
    //       if (value.success?.status == ApiEndPoints.apiStatus_200) {
    //         await Session.sessionBox.clear().then((value) {
    //           Session.saveLocalData(keyAppLanguage, appLanguageUUid);
    //           ref.read(navigationStackController).pushAndRemoveAll(const NavigationStackItem.login());
    //         });
    //       }
    //     },
    //   );
    // } else {
    //   await Session.sessionBox.clear().then((value) {
    //     Session.saveLocalData(keyAppLanguage, appLanguageUUid);
    //
    //     ref.read(navigationStackController).pushAndRemoveAll(const NavigationStackItem.login());
    //   });
    // }
  }
}
