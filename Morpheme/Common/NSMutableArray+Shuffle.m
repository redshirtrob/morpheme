//
//  NSMutableArray+Shuffle.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright (c) 2013 Robert Jones. All rights reserved.
//

#import <stdlib.h>
#import "NSMutableArray+Shuffle.h"

/* Plucked from:
 * http://stackoverflow.com/questions/791232/canonical-way-to-randomize-an-nsarray-in-objective-c
 * http://en.wikipedia.org/wiki/Knuth_shuffle
 */ 

@implementation NSMutableArray (Shuffle)

- (void)shuffle {
    NSInteger count = [self count];
    for(NSUInteger i = count; i > 0; i--) {
        NSUInteger j = arc4random() % count;
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

@end
