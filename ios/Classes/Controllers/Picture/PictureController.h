//
//  PictureController.h
//  ricoh_theta
//
//  Created by Dimitri Dessus on 19/09/2022.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "HttpConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface PictureController : NSObject

@property(readonly, nonatomic) FlutterResult result;
@property(readonly, nonatomic) HttpConnection *httpConnection;
@property(nonatomic) FlutterEventSink livePreviewEventSink;
@property(nonatomic) int frameCount;

- (void)takePictureWithPath:(NSString *)path;
- (void)startLiveView:(float)fps;
- (void)resumeLiveView;
- (void)pauseLiveView;
- (void)stopLiveView;
- (void)adjustLiveViewFps:(float)fps;
- (void)setResult:(FlutterResult _Nonnull)result;
- (void)setLivePreviewEventSink:(FlutterEventSink)imageStreamEventSink;
- (void)setHttpConnection:(HttpConnection * _Nonnull)httpConnection;

@end

NS_ASSUME_NONNULL_END
