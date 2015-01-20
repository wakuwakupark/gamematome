//
//  GetAffURL.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/23.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Affs;


@interface GetAffURL : NSObject<NSXMLParserDelegate>
{
    NSString* nowTagStr;
    NSString *txtBuffer;
    
    Affs* nowAff;
    NSMutableDictionary* testDic;
    NSMutableArray* affsArray;
}


- (id) init;
- (NSArray*) getAffs;

@end
