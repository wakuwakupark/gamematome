//
//  Site.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "Site.h"
#import "Game.h"
#import "News.h"


@implementation Site

@dynamic favorite;
@dynamic lastUpdated;
@dynamic name;
@dynamic pageURL;
@dynamic rssURL;
@dynamic type;
@dynamic unuse;
@dynamic game;
@dynamic news;

- (void) changeUnuseState:(int)value
{
    [self setUnuse:@(value)];
    
    for (News* n in [self news] ) {
        [n changeUnuseState:value];
    }
}



@end
