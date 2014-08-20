//
//  ChkInterstitial.h
//  8chk
//
//  Ver 5.3.2
//
//  Created by Tatsuya Uemura on 2013/09/17.
//  Copyright 2013 8crops inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ChkInterstitialDelegate.h"
#import "ChkController.h"

@interface ChkInterstitial : NSObject{
}

@property (nonatomic, assign) id<ChkInterstitialDelegate>   delegate;

// Extra configuration settings
// image cache max cost( minimum is 32MB, default is 32MB )
@property NSUInteger imageCacheMaxCost;
// data request interval( minimum is 20s, default is 120s )
@property NSUInteger dataRequestInterval;
// background color( default darkGrayColor alpha 0.8 )
@property (nonatomic,retain) UIColor        *backgroundColor;
// should show interstitial in the foreground session ( default to NO )
@property (nonatomic) BOOL showInterstitialInForegroundSession;

+ (ChkInterstitial *)sharedChkInterstitial;
+ (ChkInterstitial *)sharedChkInterstitial:(ChkPropertiyFileType)type;

- (void)setConfig:(ChkConfig*)config;

- (void)startSession;
- (void)stopSession;

- (void)showInterstitial;
- (void)showInterstitial:(NSString *)tag;

@end
