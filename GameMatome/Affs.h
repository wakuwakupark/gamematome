//
//  Affs.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/23.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Affs : NSManagedObject

@property (nonatomic, retain) NSString * affsId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * siteName;



@end
