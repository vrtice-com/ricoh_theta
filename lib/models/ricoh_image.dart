import 'dart:io';

class RicohImage {
  final String fileName;
  final double width;
  final double height;
  final int size;
  RicohImage({
    required this.fileName,
    required this.width,
    required this.height,
    required this.size,
  });

  factory RicohImage.fromMap(Map<String, dynamic> map, String path) {
    return RicohImage(
      fileName: map['fileName'],
      width: map['width'],
      height: map['height'],
      size: map['size'],
    );
  }
}
