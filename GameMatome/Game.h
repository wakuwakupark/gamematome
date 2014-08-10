//
//  Game.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Game : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * unuse;
@property (nonatomic, retain) NSMutableSet *sites;
@end

@interface Game (CoreDataGeneratedAccessors)

- (void)addSitesObject:(NSManagedObject *)value;
- (void)removeSitesObject:(NSManagedObject *)value;
- (void)addSites:(NSSet *)values;
- (void)removeSites:(NSSet *)values;

- (void) changeUnuseState:(int)value;

@end
