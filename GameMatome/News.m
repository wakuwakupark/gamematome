//
//  News.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "News.h"
#import "Memo.h"
#import "Site.h"


@implementation News

@dynamic contentURL;
@dynamic date;
@dynamic image;
@dynamic favorite;
@dynamic didRead;
@dynamic title;
@dynamic unuse;
@dynamic site;
@dynamic memo;
@dynamic newsId;
@dynamic isNew;

- (void) changeUnuseState:(int)value
{
    [self setUnuse:@(value)];
}

@end
