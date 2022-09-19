//
//  PictureController.m
//  ricoh_theta
//
//  Created by Dimitri Dessus on 19/09/2022.
//

#import "PictureController.h"

@implementation PictureController

- (id)init {
  if ( self = [super init] ) {
    _frameCount = 0;
  }
  return self;
}

- (void)takePictureWithPath:(NSString *)path {
  HttpImageInfo *info = [_httpConnection takePicture];
  
  if (!info) {
    _result([FlutterError errorWithCode:@"PICTURE_TAKE_ERROR" message:@"unable to take picture" details:nil]);
  }
  
  NSData *thumbData = [_httpConnection getThumb:info.file_id];
  UIImage *image = [UIImage imageWithData:thumbData];
  
  NSString *uuid = [[NSUUID UUID] UUIDString];
  NSString *fileName = [NSString stringWithFormat:@"%@_ricoh_thetha_preview.jpg", uuid];
  NSString *filePath = [path stringByAppendingPathComponent:fileName];
  bool success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
  if (!success) {
    _result([FlutterError errorWithCode:@"WRITE_FAILED" message:@"unable to write file" details:nil]);
    return;
  }

  _result(@{
    @"fileName": fileName,
    @"fileId": info.file_id,
  });
}

- (void)adjustLiveViewFps:(float)fps {
  [_httpConnection adjustLiveViewFps:fps];
}

- (void)startLiveView:(float)fps {
  [_httpConnection startLiveView:^(NSData *frameData) {
    if (self->_livePreviewEventSink) {
      self->_livePreviewEventSink(frameData);
    }
  } andFps:fps];
}

- (void)resumeLiveView {
  [_httpConnection resumeLiveView];
}

- (void)pauseLiveView {
  [_httpConnection pauseLiveView];
}

- (void)stopLiveView {
  [_httpConnection stopLiveView];
}

# pragma mark - Setters -

- (void)setHttpConnection:(HttpConnection * _Nonnull)httpConnection {
  _httpConnection = httpConnection;
}

- (void)setResult:(FlutterResult _Nonnull)result {
  _result = result;
}

- (void)setLivePreviewEventSink:(FlutterEventSink)livePreviewEventSink {
  _livePreviewEventSink = livePreviewEventSink;
}

@end
