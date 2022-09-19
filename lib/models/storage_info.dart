class StorageInfo {
  final num maxCapacity;
  final num freeSpaceInBytes;
  final num freeSpaceInImages;
  final num imageWidth;
  final num imageHeight;

  StorageInfo({
    required this.maxCapacity,
    required this.freeSpaceInBytes,
    required this.freeSpaceInImages,
    required this.imageWidth,
    required this.imageHeight,
  });

  factory StorageInfo.fromMap(Map<String, num> map) {
    return StorageInfo(
      maxCapacity: map['maxCapacity'] ?? -1,
      freeSpaceInBytes: map['freeSpaceInBytes'] ?? -1,
      freeSpaceInImages: map['freeSpaceInImages'] ?? -1,
      imageWidth: map['imageWidth'] ?? -1,
      imageHeight: map['imageHeight'] ?? -1,
    );
  }
}
