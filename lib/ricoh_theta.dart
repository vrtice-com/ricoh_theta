import 'dart:typed_data';

import 'package:ricoh_theta/models/device_info.dart';
import 'package:ricoh_theta/models/image_infoes.dart';
import 'package:ricoh_theta/models/picture_take_info.dart';
import 'package:ricoh_theta/models/ricoh_image.dart';
import 'package:ricoh_theta/models/storage_info.dart';

import 'ricoh_theta_platform_interface.dart';

class RicohTheta {
  /// If no ip address is provided, the default ip "192.168.1.1" is selected.
  /// This is required to setup before any other method.
  Future setTargetIp(String? ipAddress) async {
    return RicohThetaPlatform.instance.setTargetIp(ipAddress);
  }

  /// Disconnect from the device
  Future disconnect() async {
    return RicohThetaPlatform.instance.disconnect();
  }

  /// Start capture of live view
  Future startLiveView({num fps = 30}) async {
    return RicohThetaPlatform.instance.startLiveView(fps);
  }

  /// Remove an image from storage device.
  /// Return true if the image is removed successfully.
  Future<bool?> removeImageWithFileId(String fileId) {
    return RicohThetaPlatform.instance.removeImageWithFileId(fileId);
  }

  /// Get an image from storage device.
  Future<RicohImage?> getImage(String fileId, String path) async {
    return RicohThetaPlatform.instance.getImage(fileId, path);
  }

  /// Pause capture of live view
  Future pauseLiveView() async {
    return RicohThetaPlatform.instance.pauseLiveView();
  }

  /// Stop capture of live view
  Future stopLiveView() async {
    return RicohThetaPlatform.instance.stopLiveView();
  }

  /// Resume capture of live view
  Future resumeLiveView() async {
    return RicohThetaPlatform.instance.resumeLiveView();
  }

  /// Get battery level from device
  Future<num> batteryLevel() async {
    final battery = await RicohThetaPlatform.instance.batteryLevel();
    return (battery ?? 0) * 100;
  }

  /// Returns the current model information like model, firmware & serial number.
  Future<DeviceInfo?> getDeviceInfo() {
    return RicohThetaPlatform.instance.getDeviceInfo();
  }

  /// Returns information about the device storage.
  Future<StorageInfo?> getStorageInfo() {
    return RicohThetaPlatform.instance.getStorageInfo();
  }

  /// Update device session.
  /// Can be used to keep a session alive.
  Future update() {
    return RicohThetaPlatform.instance.update();
  }

  /// Returns information about the images stored on the device.
  Future<List<ImageInfoes>> getImageInfoes() {
    return RicohThetaPlatform.instance.getImageInfoes();
  }

  /// Take a picture & return a thumbnail path.
  Future<PictureTakeInfo?> takePicture(String path) async {
    return RicohThetaPlatform.instance.takePicture(path);
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
  Future adjustLiveViewFps(num fps) {
    return RicohThetaPlatform.instance.adjustLiveViewFps(fps);
  }
}
