//
//  Memo.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class News;

@interface Memo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) News *news;

@end
