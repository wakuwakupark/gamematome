//
//  Site.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSString * rssURL;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * unuse;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSMutableSet *news;
@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addNewsObject:(NSManagedObject *)value;
- (void)removeNewsObject:(NSManagedObject *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;

- (void) changeUnuseState:(int)value;

@end
