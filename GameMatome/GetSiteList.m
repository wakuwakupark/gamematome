//
//  GetSiteList.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/14.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "GetSiteList.h"

@implementation GetSiteList

- (id)init
{
    self = [super init];
    
    return self;
}

- (NSDictionary *)returnSiteArray
{
    //ユーザ名格納配列　初期化
    userArr = [NSMutableDictionary dictionary];
    
    
    //PHPファイルのURLを設定
    //NSString *url = @"http://wakuwakupark.main.jp/gamematome/siteList.php";
    NSString *url = @"http://localhost/siteList.php";
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
    myParser.delegate = self;
    
    //xml解析開始
    [myParser parse];
    
    return userArr;
}



// ②XMLの解析
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //解析中タグの初期化
    nowTagStr = @"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //解析中タグに設定
    nowTagStr = [NSString stringWithString:elementName];
    
    if ([elementName isEqualToString:@"site_id"]) {
        
        //テキストバッファの初期化
        nowDic = [NSMutableDictionary dictionary];
        NSString* key = [NSString stringWithFormat:@"%d",(int)[userArr count]];
        [userArr setObject:nowDic forKey:key];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    [nowDic setObject:string forKey:nowTagStr];
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    
}


@end
