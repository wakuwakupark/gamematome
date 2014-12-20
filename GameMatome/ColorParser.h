//
//  ColorParser.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/12/20.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorParser : NSObject

+ (UIColor *)parseFromRGBString:(NSString*)rgbString read:(BOOL)read;

@end
