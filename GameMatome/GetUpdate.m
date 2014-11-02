//
//  GetUpdate.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/14.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "GetUpdate.h"

@implementation GetUpdate

- (id)init
{
    self = [super init];
    
    return self;
}

- (NSString*) returnUpdate
{
    
    //PHPファイルのURLを設定
    NSString *url = @"http://localhost/update.php";
    //NSString *url = @"http://wakuwakupark.main.jp/gamematome/update.php";
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSString *str = [[NSString alloc] initWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:NULL];
    
    return str;
}




@end
