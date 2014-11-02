//
//  GetNewsList.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/11/02.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "GetNewsList.h"
#import "News.h"
#import "Site.h"
#import "ForUseCoreData.h"

@implementation GetNewsList

- (id)init
{
    self = [super init];
    if(self){
    }
    return self;
}

//news形の配列として返す
- (void) returnNewsList:(NSArray*) sitesArray
{
    //newsDic = [NSMutableDictionary dictionary];
    
    //URLを指定してXMLパーサーを作成
    NSURL *url = [[NSURL alloc]initWithString:@"http://localhost/newsList.php"];
    //NSURL *url = [[NSURL alloc]initWithString:@"http://wakuwakupark.main.jp/gamematome/getNewsList.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    // MethodにPOSTを指定する。
    request.HTTPMethod = @"POST";
    
    //bodyStringを生成
    
    NSMutableString* body = [NSMutableString string];
    [body appendString:@"keys="];
    
    for(Site* site in sitesArray){
        if([site.unuse intValue] == 1){
            continue;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ"];
        NSString *dateStr = [formatter stringFromDate:[site lastUpdated]];
        
        if([body length] >= 10){
            [body appendString:@" OR "];
        }
        
        if(dateStr == NULL){
        //if(false){
            [body appendFormat:@"(siteId = %d)",[site.siteId intValue]];
        }else{
            [body appendFormat:@"(siteId = %d AND date >= \"%@\" )",[site.siteId intValue],dateStr];
        }
    }
    
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    //XML形式のデータを取得
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSXMLParser *myParser = [[NSXMLParser alloc]initWithData:returnData];

    myParser.delegate = self;
    
    //xml解析開始
    [myParser parse];
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];
    
    return;
}


// ②XMLの解析
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //解析中タグの初期化
    nowTagStr = @"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //解析中タグに設定
    nowTagStr = [NSString stringWithString:elementName];
    
    if ([nowTagStr isEqualToString:@"news"]) {
        //バッファの初期化
        nowNews = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([nowTagStr isEqualToString:@"newsId"]) {
        [nowNews setValue:[NSNumber numberWithInt:[string intValue]] forKey:nowTagStr];
        
    }else if([nowTagStr isEqualToString:@"title"]
             || [nowTagStr isEqualToString:@"contentURL"]){
        NSString* buffer = [nowNews valueForKey:nowTagStr];
        if(buffer != Nil)
            [nowNews setValue: [buffer stringByAppendingString:string] forKey:nowTagStr];
        else
            [nowNews setValue:string forKey:nowTagStr];
        
    }else if([nowTagStr isEqualToString:@"date"]){
        //ストリングをdate形に変換
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ"];
        [nowNews setDate:[dateFormatter dateFromString:string]];
        
    }else if ([nowTagStr isEqualToString:@"siteId"]){
        
        NSString* condition = [NSString stringWithFormat:@"siteId=%@",string];
        NSArray* arr =[ForUseCoreData getEntityDataEntityNameWithEntityName:@"Site" condition:condition];
        
        if([arr count] == 0){
            exit(0);
        }
        
        Site* parentSite = [arr objectAtIndex:0];
        [parentSite.news addObject:nowNews];
        [nowNews setSite:parentSite];
    }
}

- (void)parser:(NSXMLParser *) parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    
}



@end
