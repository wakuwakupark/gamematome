//
//  News.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memo, Site;

@interface News : NSManagedObject

@property (nonatomic, retain) NSString * contentURL;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * didRead;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unuse;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) Memo *memo;
@property (nonatomic, retain) NSNumber *newsId;
@property (nonatomic, retain) NSNumber *isNew;

- (void) changeUnuseState:(int)value;

@end
