//
//  Game.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "Game.h"
#import "Site.h"

@implementation Game

@dynamic name;
@dynamic unuse;
@dynamic sites;
@dynamic gameId;
@dynamic color;
@dynamic image;
@dynamic imageData;

- (void)changeUnuseState:(int)value
{
    [self setUnuse:@(value)];
    
    for (Site* s in [self sites]) {
        [s changeUnuseState:value];
    }
}

@end
