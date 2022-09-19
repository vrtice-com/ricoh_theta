#import "RicohThetaPlugin.h"
#import "HttpConnection.h"
#import "PictureController.h"
#import "StorageController.h"
#import "Constants.h"

FlutterEventSink livePreviewStreamEventSink;
FlutterEventSink downloadStreamEventSink;

PictureController *pictureController;
HttpConnection *httpConnection;
StorageController *storageController;

@implementation RicohThetaPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"ricoh_theta"
                                   binaryMessenger:[registrar messenger]];
  
  LivePreviewStreamHandler *livePreviewStreamHandler =
  [[LivePreviewStreamHandler alloc] init];
  FlutterEventChannel *livePreviewChannel = [FlutterEventChannel eventChannelWithName:@"ricoh_theta/preview"
                                                                      binaryMessenger:[registrar messenger]];
  [livePreviewChannel setStreamHandler:livePreviewStreamHandler];
  
  DownloadStreamHandler *downloadStreamHandler =
  [[DownloadStreamHandler alloc] init];
  FlutterEventChannel *downloadChannel = [FlutterEventChannel eventChannelWithName:@"ricoh_theta/download"
                                                                   binaryMessenger:[registrar messenger]];
  [downloadChannel setStreamHandler:downloadStreamHandler];
  
  RicohThetaPlugin *instance = [[RicohThetaPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  
  httpConnection = [[HttpConnection alloc] init];
  pictureController = [[PictureController alloc] init];
  storageController = [[StorageController alloc] init];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  [self bindResultToControllers:result];
  
  if ([@"setTargetIp" isEqualToString:call.method]) {
    [self _handleSetTargetIp:call result:result];
  } else if ([@"disconnect" isEqualToString:call.method]) {
    [self _handleDisconnect:call result:result];
  } else if ([@"startLiveView" isEqualToString:call.method]) {
    [self _handleStartLiveView:call result:result];
  } else if ([@"resumeLiveView" isEqualToString:call.method]) {
    [self _handleResumeLiveView:call result:result];
  } else if ([@"pauseLiveView" isEqualToString:call.method]) {
    [self _handlePauseLiveView:call result:result];
  } else if ([@"removeImageWithFileId" isEqualToString:call.method]) {
    [self _handleRemoveImageWithFileId:call result:result];
  } else if ([@"stopLiveView" isEqualToString:call.method]) {
    [self _handleStopLiveView:call result:result];
  } else if ([@"adjustLiveViewFps" isEqualToString:call.method]) {
    [self _handleAdjustLiveViewFps:call result:result];
  } else if ([@"batteryLevel" isEqualToString:call.method]) {
    [self _handleBatteryLevel:call result:result];
  } else if ([@"getStorageInfo" isEqualToString:call.method]) {
    [self _handleStorageInfo:call result:result];
  } else if ([@"getImage" isEqualToString:call.method]) {
    [self _handleGetImageWithFileId:call result:result];
  } else if ([@"getImageInfoes" isEqualToString:call.method]) {
    [self _handleGetImageInfoes:call result:result];
  } else if ([@"getDeviceInfo" isEqualToString:call.method]) {
    [self _handleDeviceInfo:call result:result];
  } else if ([@"takePicture" isEqualToString:call.method]) {
    [self _handleTakePicture:call result:result];
  } else if ([@"update" isEqualToString:call.method]) {
    [self _handleUpdate:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)_handleUpdate:(FlutterMethodCall*)call result:(FlutterResult)result {
  [httpConnection update];
  result(nil);
}

- (void)_handleBatteryLevel:(FlutterMethodCall*)call result:(FlutterResult)result {
  [httpConnection getBatteryLevel:^(const NSNumber *battery) {
    if (!battery) {
      result([FlutterError errorWithCode:@"BATTERY_ERROR" message:@"unable to retrieve battery level" details:nil]);
      return;
    }
    
    result(battery);
  }];
}

- (void)_handleDisconnect:(FlutterMethodCall*)call result:(FlutterResult)result {
  [httpConnection close:^{
    result(nil);
  }];
}

- (void)_handleAdjustLiveViewFps:(FlutterMethodCall*)call result:(FlutterResult)result {
  float fps = [call.arguments[@"fps"] floatValue];
  
  if (!fps) {
    result([FlutterError errorWithCode:@"WRONG_FPS" message:@"fps value invalid must not be null" details:nil]);
  }
  
  [pictureController adjustLiveViewFps:fps];
}

- (void)_handleRemoveImageWithFileId:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *fileId = call.arguments[@"fileId"];
  
  if (!fileId) {
    result([FlutterError errorWithCode:@"MISSING_FILE_ID" message:@"file id need to be specified" details:nil]);
  }
  
  [storageController removeImageWithFileId:fileId];
}

- (void)_handleGetImageWithFileId:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *fileId = call.arguments[@"fileId"];
  NSString *path = call.arguments[@"path"];
  
  if (!fileId) {
    result([FlutterError errorWithCode:@"MISSING_FILE_ID" message:@"file id need to be specified" details:nil]);
  }
  
  if (!path) {
    result([FlutterError errorWithCode:@"MISSING_PATH" message:@"path need to be specified" details:nil]);
  }
  
  [storageController getImageWithFileId:fileId andPath:path];
}

- (void)_handleStartLiveView:(FlutterMethodCall*)call result:(FlutterResult)result {
  float fps = [call.arguments[@"fps"] floatValue];
  
  [pictureController startLiveView:fps];
}

- (void)_handleGetImageInfoes:(FlutterMethodCall*)call result:(FlutterResult)result {
  [storageController getImageInfoes];
}

- (void)_handleResumeLiveView:(FlutterMethodCall*)call result:(FlutterResult)result {
  [pictureController resumeLiveView];
}

- (void)_handlePauseLiveView:(FlutterMethodCall*)call result:(FlutterResult)result {
  [pictureController pauseLiveView];
}

- (void)_handleStopLiveView:(FlutterMethodCall*)call result:(FlutterResult)result {
  [pictureController stopLiveView];
}

- (void)_handleTakePicture:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *path = call.arguments[@"path"];
  
  if (!path) {
    result([FlutterError errorWithCode:@"MISSING_PATH" message:@"path need to be specified" details:nil]);
  }
  
  [pictureController takePictureWithPath:path];
}

- (void)_handleStorageInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  [storageController getStorageInfo];
}

- (void)_handleSetTargetIp:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *ipAddress = call.arguments[@"ipAddress"];
  
  if (!ipAddress) {
    result([FlutterError errorWithCode:@"MISSING_IP_ADDRESS" message:@"ip address need to be specified" details:nil]);
  }
  
  [httpConnection setTargetIp:ipAddress];
  [self bindHttpConnectionToControllers];
  result(nil);
}

- (void)bindResultToControllers:(FlutterResult)result {
  [pictureController setResult:result];
  [storageController setResult:result];
}

- (void)bindHttpConnectionToControllers {
  [pictureController setHttpConnection:httpConnection];
  [storageController setHttpConnection:httpConnection];
}

- (void)_handleDeviceInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  [httpConnection getDeviceInfo:^(const HttpDeviceInfo *info) {
    if (!info) {
      result([FlutterError errorWithCode:@"INFO_ERROR" message:@"unable to retrieve device info" details:nil]);
      return;
    }
    
    result(@{
      @"model": info.model,
      @"firmwareVersion": info.firmware_version,
      @"serialNumber": info.serial_number
    });
  }];
}

@end


@implementation LivePreviewStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  livePreviewStreamEventSink = eventSink;
  [pictureController setLivePreviewEventSink:eventSink];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  livePreviewStreamEventSink = nil;
  [pictureController setLivePreviewEventSink:livePreviewStreamEventSink];
  return nil;
}
@end

@implementation DownloadStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  downloadStreamEventSink = eventSink;
  [storageController setDownloadEventSink:eventSink];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  downloadStreamEventSink = nil;
  [storageController setDownloadEventSink:downloadStreamEventSink];
  return nil;
}
@end
