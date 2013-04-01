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
    kSwipeLeft = 0,
    kSwipeRight,
    kSwipeUp,
    kSwipeDown,
} SwipeType;

#define XCoord(i) (kLeftMargin + (((i)+1) * kSeparatorMargin) + (((i) + 0.5) * kTileWidth))
#define YCoord(j) (1024 - (kTopMargin + (((j)+1) * kSeparatorMargin) + (((j) + 0.5) * kTileHeight)))
#define IsHorizontalSwipe(s) ((BOOL)(s == kSwipeLeft || s == kSwipeRight))
#define IsVerticalSwipe(s) ((BOOL)(s == kSwipeUp || s == kSwipeDown))
#define AreSwipesSame(s1, s2) ((BOOL)((IsHorizontalSwipe(s1) && IsHorizontalSwipe(s2)) || (IsVerticalSwipe(s1) && IsVerticalSwipe(s2))))

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
    if (IsHorizontalSwipe(_prevSwipe)) {
	for (LetterTile *tile in _gameGrid[_activeTile.row]) {
	    tile.position = [_gridCoordinates[tile.row][tile.col] CGPointValue];
	    tile.scale = 1.0;
	}
    }
    else {
	for (NSMutableArray *row in _gameGrid) {
	    LetterTile *tile = row[_activeTile.col];
	    tile.position = [_gridCoordinates[tile.row][tile.col] CGPointValue];
	    tile.scale = 1.0;
	}
    }
}

- (void)shiftLeftByDelta:(CGFloat)delta {
    NSInteger start = [self startColumn];
    NSInteger end = [self endColumn];
    LetterTile *firstTile = (LetterTile *)_gameGrid[_activeTile.row][start];
    CGPoint firstTilePoint = [_gridCoordinates[_activeTile.row][start] CGPointValue];
    CGPoint startPoint = [_gridCoordinates[_activeTile.row][_activeTile.col] CGPointValue];
    CGFloat totalChange = fabsf(startPoint.x-_activeTile.position.x);

    // First Tile
    if (firstTile.position.x > firstTilePoint.x) {
	firstTile.position = ccp(firstTile.position.x-delta, firstTile.position.y);
    }
    else {
	firstTile.scale = (kTileWidth-totalChange)/kTileWidth;
	firstTile.position = ccp(firstTilePoint.x-totalChange/2.0, firstTilePoint.y);
    }

    // Shift the rest of the row
    for (NSInteger col = start+1; col < end; col++) {
	LetterTile *tile = (LetterTile *)_gameGrid[_activeTile.row][col];
	tile.position = ccp(tile.position.x-delta, tile.position.y);
    }

    // Last Tile
    LetterTile *lastTile = (LetterTile *)_gameGrid[_activeTile.row][end];
    if (lastTile.scale < 1.0) {
	CGPoint lastTilePoint = [_gridCoordinates[_activeTile.row][end] CGPointValue];
	lastTile.scale = (kTileWidth-totalChange)/kTileWidth;
	if (lastTile.scale > 0.95) {
	    lastTile.scale = 1.0;
	    lastTile.position = ccp(lastTilePoint.x+delta, lastTilePoint.y);
	}
	else {
	    lastTile.position = ccp(lastTilePoint.x+totalChange/2.0, lastTilePoint.y);
	}
    }
    else {
	lastTile.position = ccp(lastTile.position.x-delta, lastTile.position.y);
    }
}

- (void)shiftRightByDelta:(CGFloat)delta {
    NSInteger start = [self startColumn];
    NSInteger end = [self endColumn];
    LetterTile *lastTile = (LetterTile *)_gameGrid[_activeTile.row][end];
    CGPoint lastTilePoint = [_gridCoordinates[_activeTile.row][end] CGPointValue];
    CGPoint startPoint = [_gridCoordinates[_activeTile.row][_activeTile.col] CGPointValue];
    CGFloat totalChange = fabsf(startPoint.x-_activeTile.position.x);

    // Last Tile
    if (lastTile.position.x < lastTilePoint.x) {
	lastTile.position = ccp(lastTile.position.x+delta, lastTile.position.y);
    }
    else {
	lastTile.scale = (kTileWidth-totalChange)/kTileWidth;
	lastTile.position = ccp(lastTilePoint.x+totalChange/2.0, lastTilePoint.y);
    }

    // Shift the rest of the row
    for (NSInteger col = end-1; col > start; col--) {
	LetterTile *tile = (LetterTile *)_gameGrid[_activeTile.row][col];
	tile.position = ccp(tile.position.x+delta, tile.position.y);
    }

    // First Tile
    LetterTile *firstTile = (LetterTile *)_gameGrid[_activeTile.row][start];
    if (firstTile.scale < 1.0) {
	CGPoint firstTilePoint = [_gridCoordinates[_activeTile.row][start] CGPointValue];
	firstTile.scale = (kTileWidth-totalChange)/kTileWidth;
	if (firstTile.scale > 0.95) {
	    firstTile.scale = 1.0;
	    firstTile.position = ccp(firstTilePoint.x-delta, firstTilePoint.y);
	}
	else {
	    firstTile.position = ccp(firstTilePoint.x-totalChange/2.0, firstTilePoint.y);
	}
    }
    else {
	firstTile.position = ccp(firstTile.position.x+delta, firstTile.position.y);
    }
}

- (void)updateWithSwipe:(SwipeType)swipe change:(CGFloat)change {
    if (!AreSwipesSame(swipe, _prevSwipe) && _prevSwipe != kSwipeNone) [self snapTiles];
    if (swipe == kSwipeLeft) {
	[self shiftLeftByDelta:change];
    }
    else if (swipe == kSwipeRight) {
	[self shiftRightByDelta:change];
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
    CGFloat deltaX = fabsf(currLocation.x-_startLocation.x);
    CGFloat deltaY = fabsf(currLocation.y-_startLocation.y);

    if ((IsHorizontalSwipe(_prevSwipe) && deltaX > 0) || (deltaX > H_SWIPE_LENGTH && fabsf(deltaY) < V_SWIPE_VARIANCE)) {
	SwipeType swipe = (_startLocation.x < currLocation.x) ? kSwipeRight : kSwipeLeft;
	[self updateWithSwipe:swipe change:deltaX];
	_startLocation = currLocation;
	return;
    }

    if ((IsVerticalSwipe(_prevSwipe) && deltaY > 0) || (deltaY > V_SWIPE_LENGTH && fabsf(deltaX) < H_SWIPE_VARIANCE)) {
	SwipeType swipe = (_startLocation.y < currLocation.y) ? kSwipeUp : kSwipeDown;
	[self updateWithSwipe:swipe change:deltaY];
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
