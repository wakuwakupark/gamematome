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

- (NSDate*) returnUpdate
{
    
    //PHPファイルのURLを設定
    NSString *url = @"http://wakuwakupark.main.jp/gamematome/update.php";//ここにはそれぞれのPHPファイルのURLを指定して下さい
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
    myParser.delegate = self;
    
    //xml解析開始
    [myParser parse];
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat  = @"yyyy-MM-dd";
    
    return [formatter dateFromString:dateString];
}



// ②XMLの解析
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //解析中タグの初期化
    nowTagStr = @"";
    dateString=@"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //解析中タグに設定
    nowTagStr = [NSString stringWithString:elementName];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if([nowTagStr isEqualToString:@"lastupdate"])
        dateString = string;
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    
}


@end
