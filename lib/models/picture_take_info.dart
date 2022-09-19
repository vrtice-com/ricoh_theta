class PictureTakeInfo {
  String fileName;
  String fileId;

  PictureTakeInfo({
    required this.fileName,
    required this.fileId,
  });

  factory PictureTakeInfo.fromMap(Map<String, dynamic> map) {
    return PictureTakeInfo(
      fileName: map['fileName'],
      fileId: map['fileId'],
    );
  }
}
