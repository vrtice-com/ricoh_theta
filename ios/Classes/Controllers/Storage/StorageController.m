//
//  StorageController.m
//  ricoh_theta
//
//  Created by Dimitri Dessus on 20/09/2022.
//

#import "StorageController.h"

@implementation StorageController

- (void)getStorageInfo {
  HttpStorageInfo *info = [_httpConnection getStorageInfo];
  
  if (!info) {
    _result([FlutterError errorWithCode:@"GET_STORAGE_ERROR" message:@"unable to get storage details" details:nil]);
  }
  
  _result(@{
    @"maxCapacity": @(info.max_capacity),
    @"freeSpaceInBytes": @(info.free_space_in_bytes),
    @"freeSpaceInImages": @(info.free_space_in_images),
    @"imageWidth": @(info.image_width),
    @"imageHeight": @(info.image_height),
  });
}

- (void)removeImageWithFileId:(NSString *) fileId {
  _result(@([_httpConnection deleteImage:fileId]));
}

- (void)getImageWithFileId:(NSString *)fileId andPath:(NSString *)path {
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  NSString *file = [NSString stringWithFormat:@"%@", fileId];
  NSURL *url = [NSURL URLWithString:file];
  
  request = [NSMutableURLRequest requestWithURL:url];
  _httpSession = [[HttpSession alloc] initWithRequest:request];
  
  [_httpSession getResizedImageObject:fileId
                              onStart:^(int64_t totalLength) {
  }
                              onWrite:^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    
    if (self->_downloadEventSink) {
      self->_downloadEventSink(@(progress));
    }
  }
                             onFinish:^(NSURL *location){
    NSData *data = [NSMutableData dataWithContentsOfURL:[NSURL URLWithString:fileId]];
    UIImage *image = [UIImage imageWithData:data];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *fileName = [NSString stringWithFormat:@"%@_ricoh_thetha_image.jpg", uuid];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    bool success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    if (!success) {
      self->_result([FlutterError errorWithCode:@"WRITE_FAILED" message:@"unable to write file" details:nil]);
      return;
    }
    
    self->_result(@{
      @"fileName": fileName,
      @"width": @(image.size.width),
      @"height": @(image.size.height),
      @"size": @([data length])
    });
  }];
}

- (void)getImageInfoes {
  NSArray *imageInfoes = [_httpConnection getImageInfoes];
  
  NSUInteger maxCount = MIN(imageInfoes.count, 30);
  NSMutableArray *resultImage = [NSMutableArray new];
  for (NSUInteger i = 0; i < maxCount; ++i) {
    HttpImageInfo *info = [imageInfoes objectAtIndex:i];
    
    [resultImage addObject:@{
      @"fileFormat":  [self formatTypeToString:info.file_format],
      @"fileSize": @(info.file_size),
      @"imagePixWidth": @((int)info.image_pix_width),
      @"imagePixHeight": @((int)info.image_pix_height),
      @"fileName": info.file_name,
      @"captureDate": @([info.capture_date timeIntervalSince1970]),
      @"fileId": info.file_id,
    }];
  }
  
  _result(resultImage);
}

- (NSString *)formatTypeToString:(NSInteger)formatType {
  switch(formatType) {
    case CODE_JPEG:
      return @"CODE_JPEG";
    case CODE_MPEG:
      return @"CODE_MPEG";
    default:
      return @"UNKNOWN";
  }
}

# pragma mark - Setters -

- (void)setHttpConnection:(HttpConnection * _Nonnull)httpConnection {
  _httpConnection = httpConnection;
}

- (void)setResult:(FlutterResult _Nonnull)result {
  _result = result;
}

- (void)setDownloadEventSink:(FlutterEventSink)downloadEventSink {
  _downloadEventSink = downloadEventSink;
}

@end
