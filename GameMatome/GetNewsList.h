//
//  GetNewsList.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/11/02.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class News;

@interface GetNewsList : NSObject<NSXMLParserDelegate>
{
    //xml解析で使用
    NSString *nowTagStr;
    NSString *txtBuffer;
    
    //ニュースを格納する辞書
    
    //解析中のデータ
    News* nowNews;
}


- (id)init;
- (void) returnNewsList:(NSArray*) sitesArray;

@end
