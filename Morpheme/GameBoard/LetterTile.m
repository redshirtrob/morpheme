//
//  LetterTile.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <stdlib.h>
#import "LetterTile.h"

static NSArray *TypeMap = nil;

@interface LetterTile ()
@end

@implementation LetterTile

+ (void)load {
    TypeMap = [@[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H",
		 @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q",
		 @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"] retain];
}

+ (id)letterTileWithType:(LetterTileType)type {
    return [[[LetterTile alloc] initWithType:type] autorelease];
}

+ (id)randomTile {
    LetterTileType type = (LetterTileType)(arc4random() % 26);
    return [self letterTileWithType:type];
}

+ (NSString *)colorFrameFileFromType:(LetterTileType)type {
    return [NSString stringWithFormat:@"%@-Color.png", TypeMap[type]];
}

+ (NSString *)whiteFrameFileFromType:(LetterTileType)type {
    return [NSString stringWithFormat:@"%@-White.png", TypeMap[type]];
}

- (id)initWithType:(LetterTileType)type {
    self = [super initWithSpriteFrameName:[LetterTile colorFrameFileFromType:type]];
    if (self) {
	_type = type;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: Letter='%@'", [super description], TypeMap[_type]];
}

- (BOOL)containsTouchLocation:(CGPoint)location {
    return CGRectContainsPoint(self.boundingBox, location);
}

@end
