package com.apparence.ricoh_theta;

import android.os.StrictMode;

import androidx.annotation.NonNull;

import com.apparence.ricoh_theta.task.BatteryTask;
import com.apparence.ricoh_theta.task.DeviceInfoTask;
import com.apparence.ricoh_theta.task.StorageInfoTask;
import com.theta360.sdk.v2.network.HttpConnector;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** RicohThetaPlugin */
public class RicohThetaPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private HttpConnector camera;

  // Event channel
  private EventChannel livePreviewChannel;
  private EventChannel downloadChannel;

  // Controllers
  private PictureController pictureController = new PictureController();
  private StorageController storageController = new StorageController();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ricoh_theta");
    channel.setMethodCallHandler(this);

    livePreviewChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "ricoh_theta/preview");
    downloadChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "ricoh_theta/download");

    livePreviewChannel.setStreamHandler(pictureController);
    downloadChannel.setStreamHandler(storageController);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    // FIXME: Don't know if it's a good practice to disable this ?
    StrictMode.ThreadPolicy policy =
            new StrictMode.ThreadPolicy.Builder().permitAll().build();
    StrictMode.setThreadPolicy(policy);

    _bindResultToControllers(result);

    if (call.method.equals("setTargetIp")) {
      _handleSetTargetIp(call, result);
    } else if (call.method.equals("getDeviceInfo")) {
      _handleDeviceInfo(call, result);
    } else if (call.method.equals("takePicture")) {
      _handleTakePicture(call, result);
    } else if (call.method.equals("disconnect")) {
      _handleDisconnect(call, result);
    } else if (call.method.equals("startLiveView")) {
      _handleStartLiveView(call, result);
    } else if (call.method.equals("removeImageWithFileId")) {
      _handleRemoveImageWithFileId(call, result);
    } else if (call.method.equals("getImage")) {
      _handleGetImage(call, result);
    } else if (call.method.equals("pauseLiveView")) {
      _handlePauseLiveView(call, result);
    } else if (call.method.equals("stopLiveView")) {
      _handleStopLiveView(call, result);
    } else if (call.method.equals("resumeLiveView")) {
      _handleResumeLiveView(call, result);
    } else if (call.method.equals("batteryLevel")) {
      _handleBatteryLevel(call, result);
    } else if (call.method.equals("getStorageInfo")) {
      _handleStorageInfo(call, result);
    } else if (call.method.equals("update")) {
      _handleUpdate(call, result);
    } else if (call.method.equals("getImageInfoes")) {
      _handleGetImageInfoes(call, result);
    } else if (call.method.equals("adjustLiveViewFps")) {
      _handleAdjustLiveViewFps(call, result);
    } else {
      result.notImplemented();
      return;
    }
  }

  private void _bindResultToControllers(Result result) {
    pictureController.setResult(result);
    storageController.setResult(result);
  }

  private void _handleRemoveImageWithFileId(MethodCall call, Result result) {
    String fileId = call.argument("fileId");

    if (fileId == null) {
      result.error("MISSING_FILE_ID", "file id need to be specified", "");
      return;
    }

    storageController.removeImageWithFileId(fileId);
  }

  private void _handleGetImage(MethodCall call, Result result) {
    String fileId = call.argument("fileId");
    String path = call.argument("path");

    if (fileId == null) {
      result.error("MISSING_FILE_ID", "file id need to be specified", "");
      return;
    }

    if (path == null) {
      result.error("MISSING_PATH", "path need to be specified", "");
      return;
    }

    storageController.getImageWithFileId(fileId, path);
  }

  private void _handleAdjustLiveViewFps(MethodCall call, Result result) {
    final Integer fps = call.argument("fps");

    if (fps == null) {
      result.error("MISSING_FPS", "fps need to be specified", "");
      return;
    } else {
      pictureController.setCurrentFps(fps);
      // FIXME: Improve this to not restart the preview, this is too heavy !
      pictureController.resumeLiveView();
    }
  }

  private void _handleGetImageInfoes(MethodCall call, Result result) {
    storageController.getImageInfoes();
  }

  private void _handleUpdate(MethodCall call, Result result) {
    // TODO
  }

  private void _handleResumeLiveView(MethodCall call, Result result) {
    pictureController.resumeLiveView();
  }

  private void _handleStopLiveView(MethodCall call, Result result) {
    pictureController.stopLiveView();
  }

  private void _handlePauseLiveView(MethodCall call, Result result) {
    // TODO
  }

  private void _handleStartLiveView(MethodCall call, Result result) {
    final Integer fps = call.argument("fps");

    if (fps == null) {
      result.error("MISSING_FPS", "fps need to be specified", "");
      return;
    } else {
      pictureController.startLiveView(fps);
    }

  }

  private void _handleDisconnect(MethodCall call, Result result) {
    // TODO
  }

  private void _handleTakePicture(MethodCall call, MethodChannel.Result result) {
    final String path = call.argument("path");

    pictureController.takePicture(path, result);
  }

  private void _handleStorageInfo(MethodCall call, Result result) {
    final StorageInfoTask storageInfoTask = new StorageInfoTask(camera, result);
    storageInfoTask.execute();
  }

  private void _handleBatteryLevel(MethodCall call, Result result) {
    final BatteryTask batteryTask = new BatteryTask(camera, result);
    batteryTask.execute();
  }

  private void _handleSetTargetIp(MethodCall call, Result result) {
    String ipAddress = call.argument("ipAddress");

    if (ipAddress == null) {
      result.error("MISSING_IP_ADDRESS", "ip address need to be specified", "");
      return;
    }

    camera = new HttpConnector(ipAddress);

    pictureController.setCamera(camera);
    storageController.setCamera(camera);

    result.success(null);
    return;
  }

  private void _handleDeviceInfo(MethodCall call, Result result) {
      final DeviceInfoTask deviceInfoTask = new DeviceInfoTask(camera, result);
      deviceInfoTask.execute();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
