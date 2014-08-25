//
//  GetAffURL.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/23.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "GetAffURL.h"
#import "ForUseCoreData.h"
#import "Affs.h"

@implementation GetAffURL


- (id)init
{
    self = [super init];
    return self;
}

- (NSArray *)getAffs
{
    affsArray = [NSMutableArray array];
    
    //return affsArray;
    
    
    //ローカルDBから削除
    [ForUseCoreData deleteObjectsFromTable:@"Affs"];
    
    //PHPファイルのURLを設定
    NSString *url = @"http://wakuwakupark.main.jp/gamematome/getAffs.php";
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
    myParser.delegate = self;
    
    //xml解析開始
    [myParser parse];
    
    [[ForUseCoreData getManagedObjectContext]save:NULL];
    
    return affsArray;
}

// ②XMLの解析
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //解析中タグの初期化
    nowTagStr = @"";
    nowAff = NULL;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //解析中タグに設定
    nowTagStr = [NSString stringWithString:elementName];
    
    if ([elementName isEqualToString:@"item"]) {
    
        //テキストバッファの初期化
        nowAff = [NSEntityDescription insertNewObjectForEntityForName:@"Affs" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
        [affsArray addObject:nowAff];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [nowAff setValue:string forKey:nowTagStr];
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}


@end
