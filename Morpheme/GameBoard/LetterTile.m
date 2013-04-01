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

@implementation LetterTile {
    BOOL _lockedHorizontal;
    BOOL _lockedVertical;
}

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
    BOOL locked = !(arc4random() % 10);
    LetterTile *tile = [self letterTileWithType:type];
    tile.lockedHorizontal = tile.lockedVertical = locked;
    return tile;
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
    return [NSString stringWithFormat:@"%@: Letter='%@', coords=(%d, %d)", [super description], TypeMap[_type], _row, _col];
}

- (BOOL)containsTouchLocation:(CGPoint)location {
    return CGRectContainsPoint(self.boundingBox, location);
}

#pragma mark - Getters/Setters

- (BOOL)isLocked {
    return (BOOL)(_lockedVertical || _lockedHorizontal);
}

- (BOOL)isLockedHorizontal {
    return _lockedHorizontal;
}

- (void)setLockedHorizontal:(BOOL)lockedHorizontal {
    _lockedHorizontal = lockedHorizontal;
    [self updateFrame];
}

- (BOOL)isLockedVertical {
    return _lockedVertical;
}

- (void)setLockedVertical:(BOOL)lockedVertical {
    _lockedVertical = lockedVertical;
    [self updateFrame];
}

#pragma mark - Private Methods

- (void)updateFrame {
    NSString *frameName = self.isLocked ? [LetterTile whiteFrameFileFromType:_type] : [LetterTile colorFrameFileFromType:_type];
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

@end
