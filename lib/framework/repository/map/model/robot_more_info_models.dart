class SensorData {
  bool? isImuOk;
  bool? isOdomOk;
  bool? is3dCameraOk;
  bool? isLidarOk;

  SensorData({
    this.isImuOk,
    this.isOdomOk,
    this.is3dCameraOk,
    this.isLidarOk,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      isImuOk: !(json['isImuOk'] ?? true),
      isOdomOk: !(json['isOdomOk'] ?? true),
      is3dCameraOk: !(json['is3dCameraOk'] ?? true),
      isLidarOk: !(json['isLidarOk'] ?? true),
    );
  }

  factory SensorData.fromTimelineJson(Map<String, dynamic> json) {
    return SensorData(
      isImuOk: !(json['i'] == 1),
      isOdomOk: !(json['o'] == 1),
      is3dCameraOk: !(json['3'] == 1),
      isLidarOk: !(json['l'] == 1),
    );
  }

  /// Timeline list format: [imu, odom, camera3d, lidar] where 1 = OK, 0 = NOT OK
  factory SensorData.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 4) {
      return SensorData(
        isImuOk: false,
        isOdomOk: false,
        is3dCameraOk: false,
        isLidarOk: false,
      );
    }

    bool _isOk(dynamic v) => v == 1 || v == true || v?.toString() == '1';

    return SensorData(
      isImuOk: _isOk(list[0]),
      isOdomOk: _isOk(list[1]),
      is3dCameraOk: _isOk(list[2]),
      isLidarOk: _isOk(list[3]),
    );
  }
}

class VersionData {
  int id;
  String? navigationVersion;
  String? loaderVersion;
  String? powerboardVersion;
  String? powerboardFirmwareVersion;

  VersionData({
    this.id = 0,
    this.navigationVersion,
    this.loaderVersion,
    this.powerboardVersion,
    this.powerboardFirmwareVersion,
  });

  factory VersionData.fromJson(Map<String, dynamic> json) {
    return VersionData(
      navigationVersion: json['navigationVersion'],
      loaderVersion: json['loaderVersion'],
      powerboardVersion: json['powerboardVersion'],
      powerboardFirmwareVersion: json['powerboardFirmwareVersion'],
    );
  }

  factory VersionData.fromTimelineJson(Map<String, dynamic> json) {
    return VersionData(
      navigationVersion: json['nv'],
      loaderVersion: json['lv'],
      powerboardVersion: json['pv'],
      powerboardFirmwareVersion: json['pfv'],
    );
  }

  /// Timeline list format: [navigationVersion, loaderVersion, powerboardVersion, powerboardFirmwareVersion]
  factory VersionData.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 4) {
      return VersionData();
    }

    return VersionData(
      navigationVersion: list[0]?.toString(),
      loaderVersion: list[1]?.toString(),
      powerboardVersion: list[2]?.toString(),
      powerboardFirmwareVersion: list[3]?.toString(),
    );
  }
}

class SystemData {
  double? cpuPercent;
  double? memoryPercent;
  String? totalMemory;

  SystemData({
    this.cpuPercent,
    this.memoryPercent,
    this.totalMemory,
  });

  factory SystemData.fromJson(Map<String, dynamic> json) {
    return SystemData(
      cpuPercent: double.tryParse(json['cpu_percent']?.toString() ?? ''),
      memoryPercent: double.tryParse(json['memory_percent']?.toString() ?? ''),
      totalMemory: json['memory_total']?.toString(),
    );
  }

  /// Timeline list format: [cpuPercent, memoryPercent, totalMemory]
  List<dynamic> get toTimelineList => [cpuPercent, memoryPercent, totalMemory];

  /// Timeline list format: [cpuPercent, memoryPercent, totalMemory]
  factory SystemData.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 3) {
      return SystemData(cpuPercent: 0, memoryPercent: 0, totalMemory: '0');
    }
    return SystemData(
      cpuPercent: double.tryParse(list[0]?.toString() ?? '') ?? 0,
      memoryPercent: double.tryParse(list[1]?.toString() ?? '') ?? 0,
      totalMemory: list[2]?.toString(),
    );
  }

  factory SystemData.fromTimelineJson(Map<String, dynamic> json) {
    return SystemData(
      cpuPercent: double.tryParse(json['cp']?.toString() ?? ''),
      memoryPercent: double.tryParse(json['mp']?.toString() ?? ''),
      totalMemory: json['mt'],
    );
  }
}

class SpeedData {
  double? linearSpeed;
  double? angularSpeed;

  SpeedData({
    this.linearSpeed,
    this.angularSpeed,
  });

  factory SpeedData.fromJson(Map<String, dynamic> json) {
    return SpeedData(
      linearSpeed: double.tryParse(json['vx']?.toString() ?? ''),
      angularSpeed: double.tryParse(json['vth']?.toString() ?? ''),
    );
  }

  factory SpeedData.fromTimelineJson(Map<String, dynamic> json) {
    return SpeedData(
      linearSpeed: double.tryParse(json['l']?.toString() ?? ''),
      angularSpeed: double.tryParse(json['a']?.toString() ?? ''),
    );
  }

  /// Timeline list format: [linearSpeed, angularSpeed]
  List<dynamic> get toTimelineList => [linearSpeed, angularSpeed];

  /// Timeline list format: [linearSpeed, angularSpeed]
  factory SpeedData.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 2) {
      return SpeedData(linearSpeed: 0, angularSpeed: 0);
    }

    return SpeedData(
      linearSpeed: double.tryParse(list[0]?.toString() ?? '') ?? 0,
      angularSpeed: double.tryParse(list[1]?.toString() ?? '') ?? 0,
    );
  }
}

class SessionData {
  /// Timeline list format (by index):
  /// [
  ///  0 hostname,
  ///  1 androidId,
  ///  2 apkVersion,
  ///  3 hostIpAddress,
  ///  4 hostWifiName,
  ///  5 androidIpAddress,
  ///  6 androidWifiName,
  ///  7 systemVolume,
  ///  8 cruiseSpeed,
  ///  9 navigationSpeed,
  /// 10 navigationWaitingTime,
  /// 11 imageSliderTime,
  /// 12 robotStopWaitingTime,
  /// 13 totalStorage,
  /// 14 availableStorage,
  /// 15 usedStorage,
  /// 16 isEmergencyPressed,
  /// 17 hideNavBar,
  /// 18 hideStatusBar,
  /// 19 slideShowNavBar,
  /// 20 slideShowNotificationBar
  /// ]
  factory SessionData.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 21) {
      return SessionData();
    }

    return SessionData(
      hostname: list[0]?.toString(),
      androidId: list[1]?.toString(),
      apkVersion: list[2]?.toString(),
      hostIpAddress: list[3]?.toString(),
      hostWifiName: list[4]?.toString(),
      androidIpAddress: list[5]?.toString(),
      androidWifiName: list[6]?.toString(),
      systemVolume: double.tryParse(list[7]?.toString() ?? '') ?? 0,
      cruiseSpeed: double.tryParse(list[8]?.toString() ?? '') ?? 0,
      navigationSpeed: double.tryParse(list[9]?.toString() ?? '') ?? 0,
      navigationWaitingTime: int.tryParse(list[10]?.toString() ?? '') ?? 0,
      imageSliderTime: int.tryParse(list[11]?.toString() ?? '') ?? 0,
      robotStopWaitingTime: int.tryParse(list[12]?.toString() ?? '') ?? 0,
      totalStorage: double.tryParse(list[13]?.toString() ?? '') ?? 0,
      availableStorage: double.tryParse(list[14]?.toString() ?? '') ?? 0,
      usedStorage: double.tryParse(list[15]?.toString() ?? '') ?? 0,
      isEmergencyPressed: list[16] == true,
      hideNavBar: list[17] == true,
      hideStatusBar: list[18] == true,
      slideShowNavBar: list[19] == true,
      slideShowNotificationBar: list[20] == true,
    );
  }

  String? hostname;
  String? androidId;
  String? apkVersion;
  String? hostIpAddress;
  String? hostWifiName;
  String? androidIpAddress;
  String? androidWifiName;
  double? systemVolume;
  double? cruiseSpeed;
  double? navigationSpeed;
  int? navigationWaitingTime;
  int? imageSliderTime;
  int? robotStopWaitingTime;
  double? totalStorage;
  double? availableStorage;
  double? usedStorage;
  bool hideNavBar;
  bool hideStatusBar;
  bool slideShowNavBar;
  bool slideShowNotificationBar;
  bool isEmergencyPressed;

  SessionData({
    this.hostname,
    this.androidId,
    this.apkVersion,
    this.hostIpAddress,
    this.hostWifiName,
    this.androidIpAddress,
    this.androidWifiName,
    this.systemVolume = 0.1,
    this.cruiseSpeed = 0.3,
    this.navigationSpeed = 0.3,
    this.navigationWaitingTime = 15,
    this.robotStopWaitingTime = 15,
    this.imageSliderTime = 5,
    this.totalStorage = 0,
    this.availableStorage = 0,
    this.usedStorage = 0,
    this.hideNavBar = true,
    this.hideStatusBar = true,
    this.slideShowNavBar = true,
    this.slideShowNotificationBar = true,
    this.isEmergencyPressed = true,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      hostname: json['hostname'],
      androidId: json['androidId'],
      apkVersion: json['apkVersion'],
      hostIpAddress: json['hostIpAddress'],
      hostWifiName: json['hostWifiName'],
      androidIpAddress: json['androidIpAddress'],
      androidWifiName: json['androidWifiName'],
      hideNavBar: json['hideNavBar'],
      hideStatusBar: json['hideStatusBar'],
      slideShowNavBar: json['slideShowNavBar'],
      slideShowNotificationBar: json['slideShowNotificationBar'],
      isEmergencyPressed: json['isEmergencyPressed'],
      systemVolume: double.parse(json['systemVolume']?.toString() ?? '0'),
      cruiseSpeed: json['cruiseSpeed'],
      navigationSpeed: json['navigationSpeed'],
      navigationWaitingTime: json['navigationWaitingTime'],
      robotStopWaitingTime: json['robotStopWaitingTime'],
      imageSliderTime: json['imageSliderTime'],
      totalStorage: double.parse(json['totalStorage']?.toString() ?? '0'),
      availableStorage: double.parse(json['availableStorage']?.toString() ?? '0'),
      usedStorage: double.parse(json['usedStorage']?.toString() ?? '0'),
    );
  }

  factory SessionData.fromTimelineJson(Map<String, dynamic> json) {
    return SessionData(
      hostname: json['hn'],
      androidId: json['aid'],
      apkVersion: json['av'],
      hostIpAddress: json['hip'],
      hostWifiName: json['hwn'],
      androidIpAddress: json['aip'],
      androidWifiName: json['awn'],
      hideNavBar: json['hnb'],
      hideStatusBar: json['hsb'],
      slideShowNavBar: json['snb'],
      slideShowNotificationBar: json['snob'],
      isEmergencyPressed: json['e'],
      systemVolume: json['sv'],
      cruiseSpeed: json['cs'],
      navigationSpeed: json['ns'],
      navigationWaitingTime: json['nwt'],
      robotStopWaitingTime: json['rst'],
      imageSliderTime: json['ist'],
      totalStorage: double.parse(json['ts']?.toString() ?? '0'),
      availableStorage: double.parse(json['as']?.toString() ?? '0'),
      usedStorage: double.parse(json['us']?.toString() ?? '0'),
    );
  }
}

class SimEvent {
  String? carrierName;
  String? number;

  SimEvent({required this.carrierName, required this.number});

  factory SimEvent.fromJson(Map<String, dynamic> json) {
    return SimEvent(
      carrierName: json['c']?.toString() ?? '-',
      number: json['m']?.toString() ?? '-',
    );
  }
}

class NavModeEvent {
  String? mode;
  String? point;

  NavModeEvent({required this.mode, required this.point});

  factory NavModeEvent.fromJson(Map<String, dynamic> json) {
    return NavModeEvent(
      mode: json['m']?.toString() ?? '',
      point: json['p']?.toString() ?? '',
    );
  }
}

class NetworkEvent {
  String upload;
  String download;

  NetworkEvent({
    required this.upload,
    required this.download,
  });

  factory NetworkEvent.fromJson(Map<String, dynamic> json) {
    return NetworkEvent(
      upload: json['upload']?.toString() ?? '0',
      download: json['download']?.toString() ?? '0',
    );
  }

  factory NetworkEvent.fromTimelineJson(Map<String, dynamic> json) {
    return NetworkEvent(
      upload: json['u']?.toString() ?? '0',
      download: json['d']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload': upload,
      'download': download,
    };
  }

  /// Timeline list format: [upload, download]
  factory NetworkEvent.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 2) {
      return NetworkEvent(upload: '0', download: '0');
    }

    return NetworkEvent(
      upload: list[0]?.toString() ?? '0',
      download: list[1]?.toString() ?? '0',
    );
  }
}
