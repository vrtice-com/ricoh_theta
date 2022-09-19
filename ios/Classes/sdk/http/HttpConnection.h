/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "HttpDeviceInfo.h"
#import "HttpImageInfo.h"
#import "HttpStorageInfo.h"
#import "HttpSession.h"

@interface HttpConnection : NSObject

@property (readonly) NSString* sessionId;

- (void)setTargetIp:(NSString* const)server;

- (BOOL)connected;


- (void)update;

- (void)close:(void(^ const)())block;

- (void)getDeviceInfo:(void(^const )(const HttpDeviceInfo* const info))block;

- (NSArray*)getImageInfoes;

- (NSData*)getThumb:(NSString*)fileId;

- (HttpStorageInfo*)getStorageInfo;

- (void)getBatteryLevel:(void(^const )(const NSNumber* const battery))block;

- (void)setImageFormat:(NSUInteger)width height:(NSUInteger)height;

- (void)startLiveView:(void(^ const)(NSData *frameData))block andFps:(float)fps;

- (void)stopLiveView;

- (void)adjustLiveViewFps:(float)fps;

- (void)pauseLiveView;

- (void)resumeLiveView;

- (HttpImageInfo*)takePicture;

- (BOOL)deleteImage:(NSString *)fileId;

- (NSMutableURLRequest*)createExecuteRequest;

@end
