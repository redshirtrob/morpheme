//
//  TileGridLayer.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "TileGridLayer.h"
#import "LetterTile.h"
#import "MorphemeCommon.h"

#define kLeftMargin (20.0)
#define kRightMargin (20.0)
#define kTopMargin (44.0)
#define kSeparatorMargin (8.0)
#define kTileWidth (64.0)
#define kTileHeight (64.0)

#define XCoord(i) (kLeftMargin + (((i)+1) * kSeparatorMargin) + ((i + 0.5) * kTileWidth))
#define YCoord(j) (1024 - (kTopMargin + (((j)+1) * kSeparatorMargin) + ((j + 0.5) * kTileHeight)))

@implementation TileGridLayer

- (id)init {
    self = [super init];
    if (self) {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tiles.plist"];
	for (int i = 0; i < 10; i++) {
	    for (int j = 0; j < 10; j++) {
		LetterTile *tile = [LetterTile randomTile];
		tile.position = ccp(XCoord(i), YCoord(j));
		[self addChild:tile];
	    }
	}
    }
    return self;
}

- (void)dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [super dealloc];
}

@end
