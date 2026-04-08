class DeviceStateEvent {
  String? totalRamMB;
  String? availRamMB;
  String? usedRamMB;
  String? appRamMB;
  String? totalStorageMB;
  String? availableStorageMB;
  String? usedStorageMB;
  String? appStorageMB;

  DeviceStateEvent({
    required this.totalRamMB,
    required this.availRamMB,
    required this.usedRamMB,
    required this.appRamMB,
    required this.totalStorageMB,
    required this.availableStorageMB,
    required this.usedStorageMB,
    required this.appStorageMB,
  });

  /// Timeline list format:
  /// [totalRamMB, availRamMB, usedRamMB, appRamMB, totalStorageMB, availableStorageMB, usedStorageMB, appStorageMB]
  List<dynamic> get toTimelineList => [
    totalRamMB,
    availRamMB,
    usedRamMB,
    appRamMB,
    totalStorageMB,
    availableStorageMB,
    usedStorageMB,
    appStorageMB,
  ];

  factory DeviceStateEvent.fromJson(Map<String, dynamic> json) {
    return DeviceStateEvent(
      totalRamMB: (json['totalRamMB'])?.toString(),
      availRamMB: (json['availRamMB'])?.toString(),
      usedRamMB: (json['usedRamMB'])?.toString(),
      appRamMB: (json['appRamMB'])?.toString(),
      totalStorageMB: (json['totalStorageMB'])?.toString(),
      availableStorageMB: (json['availableStorageMB'])?.toString(),
      usedStorageMB: (json['usedStorageMB'])?.toString(),
      appStorageMB: (json['appStorageMB'])?.toString(),
    );
  }

  factory DeviceStateEvent.fromTimelineJson(Map<String, dynamic> json) {
    return DeviceStateEvent(
      totalRamMB: (json['tr']),
      availRamMB: (json['avr']),
      usedRamMB: (json['ur']),
      appRamMB: (json['ar']),
      totalStorageMB: (json['ts']),
      availableStorageMB: (json['avs']),
      usedStorageMB: (json['us']),
      appStorageMB: (json['as']),
    );
  }

  /// Timeline list format:
  /// [totalRamMB, availRamMB, usedRamMB, appRamMB, totalStorageMB, availableStorageMB, usedStorageMB, appStorageMB]
  factory DeviceStateEvent.fromTimelineList(List<dynamic>? list) {
    if (list == null || list.length < 8) {
      return DeviceStateEvent(
        totalRamMB: null,
        availRamMB: null,
        usedRamMB: null,
        appRamMB: null,
        totalStorageMB: null,
        availableStorageMB: null,
        usedStorageMB: null,
        appStorageMB: null,
      );
    }

    return DeviceStateEvent(
      totalRamMB: list[0]?.toString(),
      availRamMB: list[1]?.toString(),
      usedRamMB: list[2]?.toString(),
      appRamMB: list[3]?.toString(),
      totalStorageMB: list[4]?.toString(),
      availableStorageMB: list[5]?.toString(),
      usedStorageMB: list[6]?.toString(),
      appStorageMB: list[7]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRamMB': totalRamMB,
      'availRamMB': availRamMB,
      'usedRamMB': usedRamMB,
      'appRamMB': appRamMB,
      'totalStorageMB': totalStorageMB,
      'availableStorageMB': availableStorageMB,
      'usedStorageMB': usedStorageMB,
      'appStorageMB': appStorageMB,
    };
  }
}