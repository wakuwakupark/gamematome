//
//  ChkController.h
//  8chk
//
//  Ver 5.3.2
//
//  Created by Tatsuya Uemura on 11/09/02.
//  Copyright 2011 8crops inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ChkConfig.h"
#import "ChkRecordData.h"

enum {
    ChkReachableViaWiFi    = 1,    // Wi-Fi
    ChkReachableViaWWAN    = 2     // 3G
}; typedef NSUInteger ChkReachableViaType;

enum {
    ChkPropertiyFileDefault     = -1, // 8chk.plist
    ChkPropertiyFileOptional1   = 0,  // 8chk_optional.plist
    ChkPropertiyFileOptional2   = 1,  // 8chk_optional1.plist
    ChkPropertiyFileOptional3   = 2,  // 8chk_optional2.plist
    ChkPropertiyFileOptional4   = 3,  // 8chk_optional3.plist
    ChkPropertiyFileOptional5   = 4,  // 8chk_optional4.plist
}; typedef NSUInteger ChkPropertiyFileType;

@interface ChkController : NSObject {
}

@property (nonatomic,readonly) NSInteger        nextPageNumber;
@property (nonatomic,readonly) NSMutableArray   *dataList;
@property (nonatomic,readonly) BOOL             hasNextData;
@property (nonatomic,retain) ChkConfig          *chkConfig;

- (id) initWithDelegate:(id)callback;
- (id) initWithConfigDelegate:(ChkConfig *)config callback:(id)callback;

- (id) initWithDelegateOptional:(id)callback;
- (id) initWithConfigDelegateOptional:(ChkConfig *)config callback:(id)callback;

- (id) initWithDelegateOptionals:(ChkPropertiyFileType)type callback:(id)callback;
- (id) initWithConfigDelegateOptionals:(ChkPropertiyFileType)type config:(ChkConfig *)config callback:(id)callback;

- (void) requestDataList;
- (void) resetDataList;
- (UIImage *) getImage:(NSString *)url;
- (NSString *) getLocalizedString:(NSString *)key;
- (void) sendImpression:(ChkRecordData *)data;
- (NSString *) getRecwr;
- (NSString *) getRecwrPlus;
- (NSString *) getIDFA;

- (BOOL) openLink:(NSURLRequest *)request;

- (ChkRecordData*) getRecordData:(NSString*)appStoreId;
- (ChkRecordData*) getRecordDataFromiTunesUrl:(NSString*)iTunesUrl;

- (void) clearDelegate;

- (void) sendWallImpression;
+ (NSString*) version;

@end
