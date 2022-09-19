import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricoh_theta/models/image_infoes.dart';
import 'package:ricoh_theta/ricoh_theta_method_channel.dart';

void main() {
  MethodChannelRicohTheta platform = MethodChannelRicohTheta();
  const MethodChannel channel = MethodChannel('ricoh_theta');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'batteryLevel') {
        return 32.3;
      } else if (methodCall.method == 'getDeviceInfo') {
        return {
          'model': 'Tetha Model S',
          'firmwareVersion': '10.0.0',
          'serialNumber': 'ABC123',
        };
      } else if (methodCall.method == 'disconnect') {
        return null;
      } else if (methodCall.method == 'setTargetIp') {
        return null;
      } else if (methodCall.method == 'takePicture') {
        return {
          'fileId': '1234567890',
          'path': '/tmp/image.jpg'
        };
      } else if (methodCall.method == 'getImageInfoes') {
        return [
          {
            'fileFormat': 'CODE_JPEG',
            'fileSize': 2003,
            'imagePixWidth': 1920,
            'imagePixHeight': 1080,
            'fileName': 'image1.jpg',
            'fileId': 'FILE1',
            'captureDate': 233434343.0,
          }
        ];
      } else if (methodCall.method == 'adjustLiveViewFps') {
        return null;
      } else if (methodCall.method == 'pauseLiveView') {
        return null;
      } else if (methodCall.method == 'resumeLiveView') {
        return null;
      } else if (methodCall.method == 'startLiveView') {
        return null;
      } else if (methodCall.method == 'stopLiveView') {
        return null;
      } else if (methodCall.method == 'update') {
        return null;
      } else if (methodCall.method == 'removeImageWithFileId') {
        return true;
      } else if (methodCall.method == 'getImage') {
        return {
          'fileId': '1234567890',
          'path': '/tmp/image.jpg',
          'height': 1080.0,
          'width': 1920.0,
          'size': 2003,
        };
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('batteryLevel', () async {
    expect(await platform.batteryLevel(), 32.3);
  });

  test('getDeviceInfo', () async {
    final model = await platform.getDeviceInfo();
    expect(model?.model, 'Tetha Model S');
    expect(model?.firmwareVersion, '10.0.0');
    expect(model?.serialNumber, 'ABC123');
  });

  test('disconnect', () async {
    expect(await platform.disconnect(), null);
  });

  test('setTargetIp', () async {
    expect(await platform.setTargetIp('192.168.1.2'), null);
  });

  test('takePicture', () async {
    final info = await platform.takePicture('path');
    expect(info!.fileId, '1234567890');
    expect(info.fileName, '/tmp/image.jpg');
  });

  test('getImageInfoes', () async {
    final list = await platform.getImageInfoes();
    expect(list.length, 1);

    expect(list.first.fileFormat, FileFormat.CODE_JPEG);
    expect(list.first.fileId, 'FILE1');
    expect(list.first.fileName, 'image1.jpg');
    expect(list.first.fileSize, 2003);
    expect(list.first.imagePixHeight, 1080);
    expect(list.first.imagePixWidth, 1920);
  });

  test('adjustLiveViewFps', () async {
    expect(await platform.adjustLiveViewFps(12), null);
  });

  test('pauseLiveView', () async {
    expect(await platform.pauseLiveView(), null);
  });

  test('resumeLiveView', () async {
    expect(await platform.resumeLiveView(), null);
  });

  test('startLiveView', () async {
    expect(await platform.startLiveView(23), null);
  });

  test('stopLiveView', () async {
    expect(await platform.stopLiveView(), null);
  });

  test('removeImageWithFileId', () async {
    expect(await platform.removeImageWithFileId('file1'), true);
  });

  test('getImage', () async {
    expect(await platform.getImage('FILE_ID1', 'path'), isNotNull);
  });

  test('update', () async {
    expect(await platform.update(), null);
  });
}
