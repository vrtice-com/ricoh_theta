import 'dart:typed_data';

import 'package:ricoh_theta/models/device_info.dart';
import 'package:ricoh_theta/models/image_infoes.dart';
import 'package:ricoh_theta/models/picture_take_info.dart';
import 'package:ricoh_theta/models/ricoh_image.dart';
import 'package:ricoh_theta/models/storage_info.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'ricoh_theta_platform_interface.dart';

class RicohTheta {
  Future<void> _forceWifi(Function function) async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    await function();
    await WiFiForIoTPlugin.forceWifiUsage(false);
  }

  Future<bool> isConnectedToTheta() async {
    final ssid = await WiFiForIoTPlugin.getSSID();
    if (ssid == null) {
      return false;
    }

    return ssid.toLowerCase().contains("theta");
  }

  /// If no ip address is provided, the default ip "192.168.1.1" is selected.
  /// This is required to setup before any other method.
  Future setTargetIp(String? ipAddress) async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.setTargetIp(ipAddress),
    );
  }

  /// Disconnect from the device
  Future disconnect() async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.disconnect(),
    );
  }

  /// Start capture of live view
  Future startLiveView({int fps = 30}) async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.startLiveView(fps),
    );
  }

  /// Remove an image from storage device.
  /// Return true if the image is removed successfully.
  Future<bool?> removeImageWithFileId(String fileId) async {
    bool? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.removeImageWithFileId(fileId);
    });
    return result;
  }

  /// Get an image from storage device.
  Future<RicohImage?> getImage(String fileId, String path) async {
    RicohImage? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.getImage(fileId, path);
    });
    return result;
  }

  /// Pause capture of live view
  Future pauseLiveView() async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.pauseLiveView(),
    );
  }

  /// Stop capture of live view
  Future stopLiveView() async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.stopLiveView(),
    );
  }

  /// Resume capture of live view
  Future resumeLiveView() async {
    return _forceWifi(
      () => RicohThetaPlatform.instance.resumeLiveView(),
    );
  }

  /// Get battery level from device
  Future<num> batteryLevel() async {
    num? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.batteryLevel();
    });
    return ((result ?? 0) * 100).floor();
  }

  /// Returns the current model information like model, firmware & serial number.
  Future<DeviceInfo?> getDeviceInfo() async {
    DeviceInfo? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.getDeviceInfo();
    });
    return result;
  }

  /// Returns information about the device storage.
  Future<StorageInfo?> getStorageInfo() async {
    StorageInfo? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.getStorageInfo();
    });
    return result;
  }

  /// Update device session.
  /// Can be used to keep a session alive.
  Future update() {
    return _forceWifi(
      () => RicohThetaPlatform.instance.update(),
    );
  }

  /// Returns information about the images stored on the device.
  Future<List<ImageInfoes>> getImageInfoes() async {
    late List<ImageInfoes> result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.getImageInfoes();
    });
    return result;
  }

  /// Take a picture & return a thumbnail path.
  Future<PictureTakeInfo?> takePicture(String path) async {
    PictureTakeInfo? result;
    await _forceWifi(() async {
      result = await RicohThetaPlatform.instance.takePicture(path);
    });
    return result;
  }

  /// Listen for live preview images coming from device.
  /// Don't forget to call [startLiveView] to start streaming.
  Stream<Uint8List>? listenCameraImages() {
    return RicohThetaPlatform.instance.listenCameraImages();
  }

  /// Listen for download progress of images.
  /// This stream is triggered when [getImage] is called.
  Stream<num>? listenDownloadProgress() {
    return RicohThetaPlatform.instance.listenDownloadProgress();
  }

  /// Adjust fraps per seconds for image preview.
  /// This is the number of frame emitted every seconds
  /// - 1 signifies 1 frame per second
  /// - 40 signifies 40 frames per second
  /// [...]
  /// - 0 signifies unlimited frames
  Future adjustLiveViewFps(int fps) {
    return _forceWifi(
      () => RicohThetaPlatform.instance.adjustLiveViewFps(fps),
    );
  }
}
