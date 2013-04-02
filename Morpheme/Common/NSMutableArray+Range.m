//
//  NSMutableArray+Range.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright (c) 2013 Robert Jones. All rights reserved.
//

#import "NSMutableArray+Range.h"

@implementation NSMutableArray (Range)

+ (id)arrayWithRange:(NSRange)range {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = range.location; i < range.location+range.length; i++) {
	[array addObject:@(i)];
    }
    return array;
}

@end
