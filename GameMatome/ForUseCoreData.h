//
//  ForUseCoreData.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/02.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;
@class Site;
@class News;
@class Memo;

@interface ForUseCoreData : NSObject
{
   
}


+ (void) setManagedObejctContext: (NSManagedObjectContext*) man;
+ (NSManagedObjectContext*) getManagedObjectContext;

+ (NSArray*) getEntityDataEntityNameWithEntityName:(NSString*)entityName;
+ (NSArray*) getEntityDataEntityNameWithEntityName:(NSString*)entityName condition:(NSString*)condition;
+ (NSArray*) getAllNewsOrderByDate;
+ (NSArray*) getFavoriteNewsOrderByDate;
+ (void) deleteAllObjects;


@end
