//
//  Parser.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/15.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "Parser.h"
#import "News.h"
#import "Site.h"
#import "ForUseCoreData.h"

@implementation Parser

- (id) init
{
    self = [super init];
    return self;
}

- (void)doParseWithSite:(Site*)site
{
    rssSiteNumber = 0;
    readingSite = site;
    NSString* feed = [site rssURL];
    
    NSURL *url = [NSURL URLWithString:feed];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    version = -1;
    _parser = [[NSXMLParser alloc] initWithData:data];
    _parser.delegate = self;
    
    titleBuffer = NULL;
    contentURLBuffer = NULL;
    dateBuffer = NULL;
    imgBuffer = NULL;
    
    [_parser parse];
}


#pragma mark XMLParserDelegate
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    _elementName = elementName;
    
    if ([_elementName isEqualToString:@"rdf:RDF"]) {
        //rss 1.0
        version = 1;
    }else if ([_elementName isEqualToString:@"rss"]){
        //rss 2.0
        version = 2;
    }
    
    if(version == -1)
        return;
    
    switch (version) {
        case 1:
            //サイトデータ作成mode
            if ([_elementName isEqualToString:@"channel"]){
                checkingMode = 1;
                //nowItem = NULL;
                checkingNews = NULL;
            }
            
            //itemデータ作成mode
            else if ([_elementName isEqualToString:@"item"]){
                
                checkingMode = 2;
                
            }
            
            break;
        case 2:
            if ([_elementName isEqualToString:@"channel"]){
                checkingMode = 1;
                checkingNews = NULL;
                
            }else if ([_elementName isEqualToString:@"item"]){
                
                checkingMode = 2;
                
            }
            
            break;
        default:
            checkingMode = 0;
            break;
    }
    
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    if(version == -1)
        return;
    
    if([string hasPrefix:@"\n"])
        return;
    
    switch (version) {
        case 1:
            switch (checkingMode) {
                case 0:
                    break;
                case 1:
                    if ([_elementName isEqualToString:@"title"]){
                        
                        //RSSデータからサイトのタイトルを取得
                        //if([[readingSite name]isEqualToString:@"NoName"])
                        [readingSite setName:string];
                        
                    }
                    break;
                case 2:
                    if ([_elementName isEqualToString:@"title"]){
                        //nowItem.title = [NSString stringWithString:string];
                        
                        //ニュースのタイトルを取得
                        titleBuffer = string;
                        
                        
                    }else if ([_elementName isEqualToString:@"link"]){
                        
                        //コンテンツのURLを取得
                        contentURLBuffer = string;
                        
                    }else if([_elementName isEqualToString:@"dc:date"]){
                        
                        //更新時間を取得
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ"];
                        dateBuffer = [dateFormatter dateFromString:string];
                        
                        
                    }else if([_elementName isEqualToString:@"content:encoded"]|| [_elementName isEqualToString:@"description"]){
                        
                        
                        
                        //a href=" ~ " までを取り出す
                        NSArray *names = [string componentsSeparatedByString:@"a href=\""];
                        if ([names count] >= 2) {
                            NSArray* arr = [[names objectAtIndex:1] componentsSeparatedByString:@"\""];
                            NSString* imgURL = [arr objectAtIndex:0];
                            
                            NSData *rowImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                            
                            
                            //画像をトリミング
                            UIImage* img = [self trimImage:[UIImage imageWithData:rowImgData] size:CGSizeMake(60,60)];
                            
                            imgBuffer = [[NSData alloc] initWithData:UIImagePNGRepresentation( img )];
                            
                        }
                    }
                    
                    break;
                default:
                    break;
            }
            
            break;
        case 2:
            switch (checkingMode) {
                case 0:
                    break;
                case 1:
                    if ([_elementName isEqualToString:@"title"]){
                        //サイトのタイトルを入力
                        //if([[readingSite name]isEqualToString:@"NoName"])
                        [readingSite setName:string];
                    }
                    break;
                case 2:
                    if ([_elementName isEqualToString:@"title"]){
                        
                        
                        //ニュースのタイトルを設定
                        titleBuffer = string;
                        
                    }else if ([_elementName isEqualToString:@"link"]){
                        
                        //コンテンツのURLを設定
                        contentURLBuffer = string;
                        
                    }else if([_elementName isEqualToString:@"dc:date"]||[_elementName isEqualToString:@"pubDate"]){
                        
                        //更新日付を設定
                        
                        //RSS2.0型変換
                        //Thu, 5 Jun 2014 16:41:56 +0900
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];
                        dateBuffer = [dateFormatter dateFromString:string];
                        
                        
                        
                    }else if([_elementName isEqualToString:@"content:encoded"]|| [_elementName isEqualToString:@"description"]){
                        
                        
                        return;
                        
                        //a href=" ~ " までを取り出す
                        NSArray *names = [string componentsSeparatedByString:@"a href=\""];
                        if ([names count] >= 2) {
                            NSArray* arr = [[names objectAtIndex:1] componentsSeparatedByString:@"\""];
                            NSString* imgURL = [arr objectAtIndex:0];
                            
                            NSData *rowImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                            
                            
                            //画像をトリミング
                            UIImage* img = [self trimImage:[UIImage imageWithData:rowImgData] size:CGSizeMake(60,60)];
                            
                            imgBuffer = [[NSData alloc] initWithData:UIImagePNGRepresentation( img )];
                            
                        }
                    }
                    
                    break;
                default:
                    break;
            }
            
            break;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (version == -1) {
        return;
    }
    
    switch (version) {
        case 1:
            if ([elementName isEqualToString:@"item"]){
                checkingMode = 2;
                
                //サイトの最終更新時間と比較して新しかったらエンティティを生成してデータを代入
                
                if ([readingSite lastUpdated]== NULL || [[readingSite lastUpdated] compare:dateBuffer] == NSOrderedAscending) {
                    
                    //未来のデータは無視
                    if([dateBuffer compare: [NSDate date]] == NSOrderedDescending){
                        return;
                    }
                    
                    
                    //新しいニュースエンティティを作成
                    checkingNews = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
                    
                    [checkingNews setTitle:titleBuffer];
                    [checkingNews setContentURL:contentURLBuffer];
                    [checkingNews setImage:imgBuffer];
                    [checkingNews setDate:dateBuffer];
                    
                    //サイトに追加
                    
                    [[readingSite news] addObject:checkingNews];
                    
                    [checkingNews setSite:readingSite];
                    
                    //[readingSite setLastUpdated:[checkingNews date]];
                    titleBuffer = NULL;
                    contentURLBuffer = NULL;
                    dateBuffer = NULL;
                    imgBuffer = NULL;
                    
                }else{
                    [_parser abortParsing];
                }
            }
            break;
        case 2:
            if ([elementName isEqualToString:@"item"]){
                
                //サイトの最終更新時間と比較して新しかったらエンティティを生成してデータを代入
                
                if ([readingSite lastUpdated]== NULL || [[readingSite lastUpdated] compare:dateBuffer] == NSOrderedAscending) {
                    
                    //未来のデータは無視
                    if([dateBuffer compare: [NSDate date]] == NSOrderedDescending){
                        return;
                    }
                    
                    
                    //新しいニュースエンティティを作成
                    checkingNews = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
                    
                    [checkingNews setTitle:titleBuffer];
                    [checkingNews setContentURL:contentURLBuffer];
                    [checkingNews setImage:imgBuffer];
                    [checkingNews setDate:dateBuffer];
                    
                    //サイトに追加
                    
                    [[readingSite news] addObject:checkingNews];
                    
                    [checkingNews setSite:readingSite];
                    
                    //[readingSite setLastUpdated:[checkingNews date]];
                    titleBuffer = NULL;
                    contentURLBuffer = NULL;
                    dateBuffer = NULL;
                    imgBuffer = NULL;
                    
                }else{
                    [_parser abortParsing];
                }
                
            }
            break;
    }
    
}



- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    rssSiteNumber ++;
    
    if (rssSiteNumber == 2) {
        
    }
    //NSLog(@"%@",[rssData description]);
}


- (UIImage *)trimImage:(UIImage *)imgOriginal size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    // draw scaled image into thumbnail context
    [imgOriginal drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}


@end
