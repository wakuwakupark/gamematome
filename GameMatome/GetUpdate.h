//
//  GetUpdate.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/14.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetUpdate : NSObject<NSXMLParserDelegate>
{
    //xml解析で使用
    NSString *nowTagStr;
    NSString *txtBuffer;
    
    //
    NSString* dateString;
}

- (id)init;
- (NSDate*) returnUpdate;

@end
