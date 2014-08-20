//
//  ChkApplicationOptional.h
//  8chk
//
//  Ver 5.3.2
//
//  Created by Tatsuya Uemura on 12/07/17.
//  Copyright 2012 8crops inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChkApplicationOptional : NSObject

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (void)applicationWillEnterForeground;

@end
