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

#define ADD_COUNT 3

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
    //NSString *url = @"http://localhost/getAffs.php";
    NSString *url = @"http://wakuwakupark.main.jp/gamematome_2/getAffs.php";
    //NSString *url = @"http://wakuwakupark.main.jp/gamematome_2/getAffsUsingFam.php";
    
    //NSString *url = @"http://fam-ad.com/rss/p/index.rdf?_site=1637&_loc=1854";
    
    //URLを指定してXMLパーサーを作成
    NSURL *myURL = [NSURL URLWithString:url];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
    myParser.delegate = self;
    
    //xml解析開始
    [myParser parse];
    
    //[[ForUseCoreData getManagedObjectContext]save:NULL];
    
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
        //nowAff = [[Affs alloc]init];
        [affsArray addObject:nowAff];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if(nowAff == NULL)
        return;
    
   if([string isEqualToString:@"\n"])
       return;
//    
//    if([nowTagStr isEqualToString:@"title"]){
//        NSString* recent = [nowAff title];
//        if(recent == NULL){
//            //[nowAff setValue:string forKey:nowTagStr];
//            [nowAff setTitle:string];
//            NSString* gameTitle = [[(NSString *)[[string componentsSeparatedByString:@"【"] objectAtIndex:1] componentsSeparatedByString:@"】"] objectAtIndex:0];
//            [nowAff setSiteName:[NSString stringWithFormat:@"【%@】まとめ速報",gameTitle]];
//        }else{
//            //[nowAff setValue:[recent stringByAppendingString:string] forKey:nowTagStr];
//            NSString* buffer = [recent stringByAppendingString:string];
//            [nowAff setTitle:buffer];
//            
//        }
//    }else if([nowTagStr isEqualToString:@"link"]){
//        NSString* recent = [nowAff url];
//        if(recent == NULL){
//            //[nowAff setValue:string forKey:@"url"];
//            [nowAff setUrl:string];
//        }else{
//            //[nowAff setValue:[recent stringByAppendingString:string] forKey:nowTagStr];
//            NSString* buffer = [recent stringByAppendingString:string];
//            [nowAff setUrl:buffer];
//        }
//    }
    
    
    if([nowAff valueForKey:nowTagStr] == NULL){
        [nowAff setValue:string forKey:nowTagStr];
    }else{
        NSString* buffer =[nowAff valueForKey:nowTagStr];
        [nowAff setValue:[buffer stringByAppendingString:string] forKey:nowTagStr];
    }
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}


@end
