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

typedef enum {
    kSwipeHorizontal = 0,
    kSwipeVertical,
} SwipeType;

#define XCoord(i) (kLeftMargin + (((i)+1) * kSeparatorMargin) + (((i) + 0.5) * kTileWidth))
#define YCoord(j) (1024 - (kTopMargin + (((j)+1) * kSeparatorMargin) + (((j) + 0.5) * kTileHeight)))

@interface TileGridLayer ()
@property (nonatomic, assign) UITouch *activeTouch;
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
	for (int r = 0; r < N_ROWS; r++) {
	    NSMutableArray *row = [[NSMutableArray alloc] init];
	    for (int c = 0; c < N_COLS; c++) {
		LetterTile *tile = [LetterTile randomTile];
		tile.row = r;
		tile.col = c;
		tile.position = ccp(XCoord(c), YCoord(r));
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

- (void)updateWithSwipe:(SwipeType)swipe change:(CGFloat)change {
    if (swipe == kSwipeHorizontal) {
	for (LetterTile *tile in _gameGrid[_activeTile.row]) {
	    tile.position = ccp(tile.position.x+change, tile.position.y);
	}
    }
    else {
	// Handle vertical swipe
    }
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL touchBegan = NO;
    if (!_activeTouch) {
	if ( (self.activeTile = [self tileForTouch:touch]) != nil) {
	    self.activeTouch = touch;
	    touchBegan = YES;
	}
    }
    return touchBegan;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    CGPoint prevLocation = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:[touch view]]];
    CGFloat deltaX = location.x-prevLocation.x;
    CGFloat deltaY = location.y-prevLocation.y;
    SwipeType swipe = (fabsf(deltaX) >= fabsf(deltaY)) ? kSwipeHorizontal : kSwipeVertical;
    CGFloat change = swipe == kSwipeHorizontal ? deltaX : deltaX;
    [self updateWithSwipe:swipe change:change];
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
