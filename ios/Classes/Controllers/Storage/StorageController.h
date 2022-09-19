//
//  StorageController.h
//  ricoh_theta
//
//  Created by Dimitri Dessus on 20/09/2022.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "HttpConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface StorageController : NSObject

@property(readonly, nonatomic) FlutterResult result;
@property(readonly, nonatomic) HttpConnection *httpConnection;
@property(readonly, nonatomic) HttpSession *httpSession;
@property(nonatomic) FlutterEventSink downloadEventSink;

- (void)getStorageInfo;
- (void)getImageInfoes;
- (void)removeImageWithFileId:(NSString *)fileId;
- (void)getImageWithFileId:(NSString *)fileId andPath:(NSString *)path;
- (void)setResult:(FlutterResult _Nonnull)result;
- (void)setHttpConnection:(HttpConnection * _Nonnull)httpConnection;
- (void)setDownloadEventSink:(FlutterEventSink)downloadEventSink;

@end

NS_ASSUME_NONNULL_END
