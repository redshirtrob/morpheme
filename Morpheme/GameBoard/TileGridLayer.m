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

#define H_SWIPE_LENGTH (5.0)
#define H_SWIPE_VARIANCE (4.0)
#define V_SWIPE_LENGTH (5.0)
#define V_SWIPE_VARIANCE (4.0)

#define kLeftMargin (20.0)
#define kRightMargin (20.0)
#define kTopMargin (44.0)
#define kSeparatorMargin (8.0)
#define kTileWidth (64.0)
#define kTileHeight (64.0)

typedef enum {
    kSwipeNone = -1,
    kSwipeHorizontal = 0,
    kSwipeVertical,
} SwipeType;

#define XCoord(i) (kLeftMargin + (((i)+1) * kSeparatorMargin) + (((i) + 0.5) * kTileWidth))
#define YCoord(j) (1024 - (kTopMargin + (((j)+1) * kSeparatorMargin) + (((j) + 0.5) * kTileHeight)))

@interface TileGridLayer ()
@property (nonatomic, assign) UITouch *activeTouch;
@property (nonatomic, retain) NSMutableArray *gameGrid;
@property (nonatomic, retain) NSMutableArray *gridCoordinates;
@property (nonatomic, retain) LetterTile *activeTile;
@property (nonatomic) SwipeType prevSwipe;
@property (nonatomic) CGPoint startLocation;
@end

@implementation TileGridLayer

- (id)init {
    self = [super init];
    if (self) {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tiles.plist"];
	CCSpriteBatchNode *tilesSheet = [CCSpriteBatchNode batchNodeWithFile:@"Tiles.png"];
	[self addChild:tilesSheet];
	_gameGrid = [[NSMutableArray alloc] init];
	_gridCoordinates = [[NSMutableArray alloc] init];
	for (int r = 0; r < N_ROWS; r++) {
	    NSMutableArray *row = [[NSMutableArray alloc] init];
	    NSMutableArray *coordinatesRow = [[NSMutableArray alloc] init];
	    for (int c = 0; c < N_COLS; c++) {
		LetterTile *tile = [LetterTile randomTile];
		tile.row = r;
		tile.col = c;
		tile.position = ccp(XCoord(c), YCoord(r));
		[tilesSheet addChild:tile];
		[row addObject:tile];
		[coordinatesRow addObject:[NSValue valueWithCGPoint:tile.position]];
	    }
	    [_gridCoordinates addObject:coordinatesRow];
	    [_gameGrid addObject:row];
	    [coordinatesRow release];
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

- (NSInteger)startColumn {
    NSInteger startIndex = _activeTile.col;
    NSInteger i = startIndex;
    while (i >= 0 && !((LetterTile *)_gameGrid[_activeTile.row][i]).isLocked) startIndex = i--;
    return startIndex;
}

- (NSInteger)endColumn {
    NSInteger endIndex = _activeTile.col;
    NSInteger i = endIndex;
    while (i < [_gameGrid[_activeTile.row] count] && !((LetterTile *)_gameGrid[_activeTile.row][i]).isLocked) endIndex = i++;
    return endIndex;
}

- (NSInteger)startRow {
    NSInteger startIndex = _activeTile.row;
    NSInteger i = startIndex;
    while (i>= 0 && !((LetterTile *)_gameGrid[i][_activeTile.col]).isLocked) startIndex = i--;
    return startIndex;
}

- (NSInteger)endRow {
    NSInteger endIndex = _activeTile.row;
    NSInteger i = endIndex;
    while (i < [_gameGrid count] && !((LetterTile *)_gameGrid[i][_activeTile.col]).isLocked) endIndex = i++;
    return endIndex;
}

- (void)snapTiles {
    if (_prevSwipe == kSwipeHorizontal) {
	for (LetterTile *tile in _gameGrid[_activeTile.row]) {
	    tile.position = [_gridCoordinates[tile.row][tile.col] CGPointValue];
	}
    }
    else {
	for (NSMutableArray *row in _gameGrid) {
	    LetterTile *tile = row[_activeTile.col];
	    tile.position = [_gridCoordinates[tile.row][tile.col] CGPointValue];
	}
    }
}

- (void)updateWithSwipe:(SwipeType)swipe change:(CGFloat)change {
    if (_prevSwipe != swipe && _prevSwipe != kSwipeNone) [self snapTiles];
    if (swipe == kSwipeHorizontal) {
	NSInteger start = [self startColumn];
	NSInteger end = [self endColumn];
	for (NSInteger col = start; col <= end && (start-end); col++) {
	    LetterTile *tile = (LetterTile *)_gameGrid[_activeTile.row][col];
	    tile.position = ccp(tile.position.x+change, tile.position.y);
	}
    }
    else {
	NSInteger start = [self startRow];
	NSInteger end = [self endRow];
	for (NSInteger row = start; row <= end && (start-end); row++) {
	    LetterTile *tile = (LetterTile *)_gameGrid[row][_activeTile.col];
	    tile.position = ccp(tile.position.x, tile.position.y-change);
	}
    }
    _prevSwipe = swipe;
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL touchBegan = NO;
    if (!_activeTouch) {
	if ( (self.activeTile = [self tileForTouch:touch]) != nil) {
	    self.activeTouch = touch;
	    touchBegan = YES;
	    _prevSwipe = kSwipeNone;
	    _startLocation = [touch locationInView:[touch view]];
	}
    }
    return touchBegan;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint currLocation = [touch locationInView:[touch view]];
    CGFloat deltaX = currLocation.x-_startLocation.x;
    CGFloat deltaY = currLocation.y-_startLocation.y;

    if ((_prevSwipe == kSwipeHorizontal && fabsf(deltaX) > 0) || (fabsf(deltaX) > H_SWIPE_LENGTH && fabsf(deltaY) < V_SWIPE_VARIANCE)) {
	[self updateWithSwipe:kSwipeHorizontal change:deltaX];
	_startLocation = currLocation;
	return;
    }

    if ((_prevSwipe == kSwipeVertical && fabsf(deltaY) > 0) || (fabsf(deltaY) > V_SWIPE_LENGTH && fabsf(deltaX) < H_SWIPE_VARIANCE)) {
	[self updateWithSwipe:kSwipeVertical change:deltaY];
	_startLocation = currLocation;
	return;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self snapTiles];
    self.activeTouch = nil;
    self.activeTile = nil;
    // Evaluate Game Board
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self snapTiles];
    self.activeTouch = nil;
    self.activeTile = nil;
    // Evaluate Game Board
}

@end
