//
//  ColorParser.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/12/20.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "ColorParser.h"

@implementation ColorParser

+ (UIColor *)parseFromRGBString:(NSString*)rgbString read:(BOOL)read
{
    if([rgbString length] != 6){
        return read ? [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] : [UIColor whiteColor];
    }
    
    unsigned int red,green,blue;
    [[NSScanner scannerWithString:[[rgbString substringFromIndex:0] substringToIndex:2]] scanHexInt:&red];
    [[NSScanner scannerWithString:[[rgbString substringFromIndex:2] substringToIndex:2]] scanHexInt:&green];
    [[NSScanner scannerWithString:[[rgbString substringFromIndex:4] substringToIndex:2]] scanHexInt:&blue];
    
    if (read)
        return [UIColor colorWithRed:(double)red/300 green:(double)green/300 blue:(double)blue/300 alpha:0.5];
    else
        return [UIColor colorWithRed:(double)red/255 green:(double)green/255 blue:(double)blue/255 alpha:0.5];
}

@end
