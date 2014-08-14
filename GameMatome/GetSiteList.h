//
//  GetSiteList.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/14.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetSiteList : NSObject<NSXMLParserDelegate>
{
    //xml解析で使用
    NSString *nowTagStr;
    NSString *txtBuffer;
    
    //ユーザ名を格納する配列
    NSMutableDictionary *userArr;
    
    //
    NSMutableDictionary* nowDic;
}

- (id)init;
- (NSDictionary*) returnSiteArray;


@end
