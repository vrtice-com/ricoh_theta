import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ricoh_theta/models/device_info.dart';
import 'package:ricoh_theta/models/image_infoes.dart';
import 'package:ricoh_theta/models/picture_take_info.dart';
import 'package:ricoh_theta/models/ricoh_image.dart';
import 'package:ricoh_theta/models/storage_info.dart';
import 'package:ricoh_theta/ricoh_theta.dart';
import 'package:ricoh_theta/ricoh_theta_platform_interface.dart';
import 'package:ricoh_theta/ricoh_theta_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final StreamController<Uint8List> _livePreviewController =
    StreamController.broadcast();
final StreamController<num> _downloadController = StreamController.broadcast();

class MockRicohThetaPlatform
    with MockPlatformInterfaceMixin
    implements RicohThetaPlatform {
  @override
  Future setTargetIp(String? ipAddress) => Future.value();

  @override
  Future<DeviceInfo?> getDeviceInfo() => Future.value(
        DeviceInfo(
          model: 'Tetha Model S',
          firmwareVersion: '10.0.0',
          serialNumber: 'ABC123',
        ),
      );

  @override
  Future disconnect() => Future.value();

  @override
  Future<num?> batteryLevel() => Future.value(0.32);

  @override
  Future<StorageInfo?> getStorageInfo() => Future.value(
        StorageInfo(
          freeSpaceInBytes: 123,
          freeSpaceInImages: 32,
          imageHeight: 1920,
          imageWidth: 1080,
          maxCapacity: 1000,
        ),
      );

  @override
  Future<List<ImageInfoes>> getImageInfoes() {
    return Future.value([
      ImageInfoes(
        captureDate: DateTime(2020, 1, 1),
        fileFormat: FileFormat.CODE_JPEG,
        fileId: 'FILE1',
        fileName: 'image1.jpg',
        fileSize: 2003,
        imagePixHeight: 1920,
        imagePixWidth: 1080,
      ),
      ImageInfoes(
        captureDate: DateTime(2022, 2, 1),
        fileFormat: FileFormat.CODE_MPEG,
        fileId: 'FILE2',
        fileName: 'image2.mp4',
        fileSize: 2004,
        imagePixHeight: 1922,
        imagePixWidth: 1082,
      )
    ]);
  }

  @override
  Future adjustLiveViewFps(num fps) => Future.value();

  @override
  Stream<Uint8List>? listenCameraImages() => _livePreviewController.stream;

  @override
  Future pauseLiveView() => Future.value();

  @override
  Future resumeLiveView() => Future.value();

  @override
  Future startLiveView(num fps) => Future.value();

  @override
  Future stopLiveView() => Future.value();

  @override
  Future<bool?> removeImageWithFileId(String fileId) => Future.value(true);

  @override
  Future<RicohImage?> getImage(String fileId, String path) => Future.value(
        RicohImage(
          fileName: 'image.jpg',
          height: 1080,
          width: 1920,
          size: 2003,
        ),
      );

  @override
  Stream<num>? listenDownloadProgress() => _downloadController.stream;

  @override
  Future update() => Future.value();

  @override
  Future<PictureTakeInfo?> takePicture(String path) {
    return Future.value(
      PictureTakeInfo(
        fileName: '/tmp/image.jpg',
        fileId: '1234567890',
      ),
    );
  }
}

void main() {
  final RicohThetaPlatform initialPlatform = RicohThetaPlatform.instance;
  RicohTheta ricohThetaPlugin = RicohTheta();
  MockRicohThetaPlatform fakePlatform = MockRicohThetaPlatform();
  RicohThetaPlatform.instance = fakePlatform;

  test('$MethodChannelRicohTheta is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRicohTheta>());
  });

  test('getDeviceInfo', () async {
    final model = await ricohThetaPlugin.getDeviceInfo();
    expect(model?.model, 'Tetha Model S');
    expect(model?.firmwareVersion, '10.0.0');
    expect(model?.serialNumber, 'ABC123');
  });

  test('disconnect', () async {
    expect(await ricohThetaPlugin.disconnect(), null);
  });

  test('setTargetIp', () async {
    expect(await ricohThetaPlugin.setTargetIp('192.168.1.2'), null);
  });

  test('takePicture', () async {
    final info = await ricohThetaPlugin.takePicture('/tmp/image.jpg');

    expect(info!.fileId, '1234567890');
    expect(info.fileName, '/tmp/image.jpg');
  });

  test('batteryLevel', () async {
    expect(await ricohThetaPlugin.batteryLevel(), 32.0);
  });

  test('getImageInfoes', () async {
    final list = await ricohThetaPlugin.getImageInfoes();
    expect(list.length, 2);

    expect(list.first.fileFormat, FileFormat.CODE_JPEG);
    expect(list.first.fileId, 'FILE1');
    expect(list.first.fileName, 'image1.jpg');
    expect(list.first.fileSize, 2003);
    expect(list.first.imagePixHeight, 1920);
    expect(list.first.imagePixWidth, 1080);

    expect(list.last.fileFormat, FileFormat.CODE_MPEG);
    expect(list.last.fileId, 'FILE2');
  });

  test('adjustLiveViewFps', () async {
    expect(await ricohThetaPlugin.adjustLiveViewFps(12), null);
  });

  test('pauseLiveView', () async {
    expect(await ricohThetaPlugin.pauseLiveView(), null);
  });

  test('resumeLiveView', () async {
    expect(await ricohThetaPlugin.resumeLiveView(), null);
  });

  test('startLiveView', () async {
    expect(await ricohThetaPlugin.startLiveView(fps: 23), null);
  });

  test('stopLiveView', () async {
    expect(await ricohThetaPlugin.stopLiveView(), null);
  });

  test('removeImageWithFileId', () async {
    expect(await ricohThetaPlugin.removeImageWithFileId('file1'), true);
  });

  test('getImage', () async {
    expect(await ricohThetaPlugin.getImage('FILE_ID1', 'path'), isNotNull);
  });

  test('update', () async {
    expect(await ricohThetaPlugin.update(), null);
  });
}
