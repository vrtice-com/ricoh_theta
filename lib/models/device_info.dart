class DeviceInfo {
  final String model;
  final String firmwareVersion;
  final String serialNumber;

  DeviceInfo({
    required this.model,
    required this.firmwareVersion,
    required this.serialNumber,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      model: map['model'],
      firmwareVersion: map['firmwareVersion'],
      serialNumber: map['serialNumber'],
    );
  }
}
