//
//  Parser.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/15.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class News;
@class Site;

@interface Parser : NSObject<NSXMLParserDelegate>
{
    NSString* _elementName;
    NSXMLParser *_parser;
    
    int version;
    int checkingMode;
    int rssSiteNumber;
    
    News* checkingNews;
    Site* readingSite;
    
    //パース用データバッファ
    NSString* titleBuffer;
    NSString* contentURLBuffer;
    NSDate* dateBuffer;
    NSData* imgBuffer;
    
}

- (id) init;
- (void) doParseWithSite:(Site*)site;

@end
