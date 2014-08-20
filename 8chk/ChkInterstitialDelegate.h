//
//  ChkInterstitialDelegate.h
//  8chk
//
//  Ver 5.3.2
//
//  Created by Tatsuya Uemura on 2013/09/17.
//  Copyright 2013 8crops inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChkInterstitialDelegate <NSObject>

@optional
- (void) chkViewDidClickInterstitial:(NSString *)tag;
- (void) chkView:(UIView *)chkView willAppearInterstitial:(NSString *)tag;
- (void) chkView:(UIView *)chkView didCloseInterstitial:(NSString *)tag;
- (void) chkViewDidDisappearInterstitial:(NSString *)tag;
- (void) chkViewDidFailToLoadInterstitial:(NSString *)tag;

@end
