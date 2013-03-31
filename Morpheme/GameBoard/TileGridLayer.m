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

#define N_ROWS (10)
#define N_COLS (10)

#define kLeftMargin (20.0)
#define kRightMargin (20.0)
#define kTopMargin (44.0)
#define kSeparatorMargin (8.0)
#define kTileWidth (64.0)
#define kTileHeight (64.0)

#define XCoord(i) (kLeftMargin + (((i)+1) * kSeparatorMargin) + (((i) + 0.5) * kTileWidth))
#define YCoord(j) (1024 - (kTopMargin + (((j)+1) * kSeparatorMargin) + (((j) + 0.5) * kTileHeight)))

@interface TileGridLayer ()
@property (nonatomic, retain) UITouch *activeTouch;
@property (nonatomic, retain) NSMutableArray *gameGrid;
@property (nonatomic, retain) LetterTile *activeTile;
@end

@implementation TileGridLayer

- (id)init {
    self = [super init];
    if (self) {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tiles.plist"];
	CCSpriteBatchNode *tilesSheet = [CCSpriteBatchNode batchNodeWithFile:@"Tiles.png"];
	[self addChild:tilesSheet];
	_gameGrid = [[NSMutableArray alloc] init];
	for (int i = 0; i < N_ROWS; i++) {
	    NSMutableArray *row = [[NSMutableArray alloc] init];
	    for (int j = 0; j < N_COLS; j++) {
		LetterTile *tile = [LetterTile randomTile];
		tile.position = ccp(XCoord(i), YCoord(j));
		[tilesSheet addChild:tile];
		[row addObject:tile];
	    }
	    [_gameGrid addObject:row];
	    [row release];
	}
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (void)dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [_activeTouch release];
    [_activeTile release];
    [_gameGrid release];
    [super dealloc];
}

- (LetterTile *)tileForTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint glLocation = [[CCDirector sharedDirector] convertToGL:location];
    for (NSArray *row in _gameGrid) {
	for (LetterTile *tile in row) {
	    if ([tile containsTouchLocation:glLocation]) {
		return tile;
	    }
	}
    }
    return nil;
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL touchBegan = NO;
    if (!_activeTouch) {
	if ( (self.activeTile = [self tileForTouch:touch]) != nil) {
	    self.activeTouch = touch;
	    touchBegan = YES;
	    NSLog(@"activeTile=%@", _activeTile);
	}
    }
    return touchBegan;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    self.activeTouch = nil;
    self.activeTile = nil;
    // Evaluate Game Board
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    self.activeTouch = nil;
    self.activeTile = nil;
    // Evaluate Game Board
}

@end
