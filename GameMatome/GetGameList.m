//
//  GetGameList.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/14.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "GetGameList.h"

@implementation GetGameList

- (id)init
{
    self = [super init];
    
    return self;
}

- (NSDictionary *)returnGameArray
{
    //ユーザ名格納配列　初期化
    userArr = [NSMutableDictionary dictionary];
    
    
    //PHPファイルのURLを設定
    NSString *url = @"http://localhost/gameList.php";
    //NSString *url = @"http://wakuwakupark.main.jp/gamematome/gameList.php";
    
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

    if ([elementName isEqualToString:@"id"]) {
        
        //テキストバッファの初期化
        nowDic = [NSMutableDictionary dictionary];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    [nowDic setObject:string forKey:nowTagStr];
    
    if ([nowTagStr isEqualToString:@"id"]) {
        
        //テキストバッファの初期化
        [userArr setObject:nowDic forKey:string];
    }
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    

}


@end
