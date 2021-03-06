//
//  AppDelegate.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "AppDelegate.h"
#import "ChkApplicationOptional.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"" forKey:@"myituneURL"];
    
    //PHPファイルのURLを設定
    NSString *url = @"http://wakuwakupark.main.jp/gamematome/getURL.php";
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSString *str = [[NSString alloc] initWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:NULL];
    
    if([str isEqualToString:@"test"]){
        [ud setObject:@"1" forKey:@"on"];
        [ud setObject:@"1" forKey:@"test"];
    }else{
        [ud setObject:@"0" forKey:@"test"];
    }
    
    [ud setObject:str forKey:@"myituneURL"];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

    
    [ChkApplicationOptional applicationDidEnterBackground:application];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

    
    [ChkApplicationOptional applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
