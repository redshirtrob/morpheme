//
//  TileGridLayer.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "SimpleAudioEngine.h"

#import "TileGridLayer.h"
#import "LetterTile.h"
#import "MorphemeCommon.h"
#import "NSMutableArray+Range.h"
#import "NSMutableArray+Shuffle.h"

// Default grid layout
#define GRID_SIDE_MARGIN (20.0)
#define GRID_TOP_MARGIN (44.0)
#define GRID_SEPARATOR_MARGIN (8.0)
#define GRID_TILE_WIDTH (64.0)
#define GRID_TILE_HEIGHT (64.0)
#define SHIFT_DETENT (63.0)
#define SCALE_DETENT (0.95)

#define XCoord(i) (GRID_SIDE_MARGIN + (((i)+1) * GRID_SEPARATOR_MARGIN) + (((i) + 0.5) * GRID_TILE_WIDTH))
#define YCoord(j) (1024 - (GRID_TOP_MARGIN + (((j)+1) * GRID_SEPARATOR_MARGIN) + (((j) + 0.5) * GRID_TILE_HEIGHT)))

// Prevent bouncing between swipe types
#define H_SWIPE_LENGTH (5.0)
#define H_SWIPE_VARIANCE (4.0)
#define V_SWIPE_LENGTH (5.0)
#define V_SWIPE_VARIANCE (4.0)

// Swipe Events
typedef enum {
    kGridSwipeEventNone = -1,
    kGridSwipeEventLeft = 0,
    kGridSwipeEventRight,
    kGridSwipeEventUp,
    kGridSwipeEventDown,
} GridSwipeEventType;

typedef enum {
    kWordOrientationNone = -1,
    kWordOrientationHorizontal = 0,
    kWordOrientationVertical,
} WordOrientationType;

#define IsHorizontalSwipe(s) ((BOOL)(s == kGridSwipeEventLeft || s == kGridSwipeEventRight))
#define IsVerticalSwipe(s) ((BOOL)(s == kGridSwipeEventUp || s == kGridSwipeEventDown))
#define AreSwipesSame(s1, s2) ((BOOL)((IsHorizontalSwipe(s1) && IsHorizontalSwipe(s2)) || (IsVerticalSwipe(s1) && IsVerticalSwipe(s2))))

@interface TileGridLayer ()
@property (nonatomic, assign) UITouch *activeTouch;
@property (nonatomic, retain) NSMutableArray *gameGrid;
@property (nonatomic, retain) NSMutableArray *gridCoordinates;
@property (nonatomic, retain) LetterTile *activeTile;
@property (nonatomic) GridSwipeEventType prevSwipe;
@property (nonatomic) CGPoint startLocation;
@property (nonatomic) CGFloat totalSwipeDelta;
@property (nonatomic, retain) CCSpriteBatchNode *tilesSheet;
@property (nonatomic, retain) NSDictionary *board;
@end

@implementation TileGridLayer

- (id)initWithGameBoard:(NSDictionary *)board {
    self = [super init];
    if (self) {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kTileDataFile];
	self.tilesSheet = [CCSpriteBatchNode batchNodeWithFile:kTileTextureFile];
	[self addChild:_tilesSheet];
	self.board = board;
	[self initializeGridWithBoard:board];
	[self initializeSounds];
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (void)dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [_activeTile release];
    [_gameGrid release];
    [_gridCoordinates release];
    [_tilesSheet release];
    [_board release];
    [super dealloc];
}

- (void)unlockWord:(NSString *)word {
    NSInteger row, col;
    WordOrientationType type;
    BOOL found = [self findWord:word row:&row column:&col type:&type locked:YES];
    if (found) {
	[self updateObjectsAtRow:row column:col length:[word length] type:type locked:NO];
    }
}

- (BOOL)lockWord:(NSString *)word {
    NSInteger row, col;
    WordOrientationType type;
    BOOL found = [self findWord:word row:&row column:&col type:&type locked:NO];
    if (found) {
	[self updateObjectsAtRow:row column:col length:[word length] type:type locked:YES];
    }
    return found;
}

#pragma mark - Tile Animation

- (void)snapTiles {
    if (IsHorizontalSwipe(_prevSwipe)) {
	for (NSInteger col = 0; col < [_board[@"width"] intValue]; col++) {
	    [self resetObjectAtRow:[self activeRow] column:col];
	}
    }
    else {
	for (NSInteger row = 0; row < [_board[@"height"] intValue]; row++) {
	    [self resetObjectAtRow:row column:[self activeColumn]];
	}
    }
}

- (void)shiftLeftByDelta:(CGFloat)delta {
    NSInteger start = [self startColumn];
    NSInteger end = [self endColumn];
    NSInteger activeRow = _activeTile.row;
    LetterTile *firstTile = [self objectAtRow:activeRow column:start];
    LetterTile *lastTile = [self objectAtRow:activeRow column:end];
    CGPoint firstTilePoint = [self pointForRow:activeRow column:start];
    CGPoint lastTilePoint = [self pointForRow:activeRow column:end];

    // First Tile
    if (firstTile.position.x > firstTilePoint.x) {
	firstTile.position = ccp(firstTile.position.x-delta, firstTile.position.y);
    }
    else {
	firstTile.scale = (GRID_TILE_WIDTH-_totalSwipeDelta)/GRID_TILE_WIDTH;
	firstTile.position = ccp(firstTilePoint.x-_totalSwipeDelta/2.0, firstTilePoint.y);
    }

    // Shift the rest of the row
    for (NSInteger col = start+1; col < end; col++) {
	LetterTile *tile = [self objectAtRow:activeRow column:col];
	tile.position = ccp(tile.position.x-delta, tile.position.y);
    }

    // Last Tile
    if (lastTile.scale < 1.0) {
	lastTile.scale = (GRID_TILE_WIDTH+_totalSwipeDelta)/GRID_TILE_WIDTH;
	lastTile.position = ccp(lastTilePoint.x-_totalSwipeDelta/2.0, lastTilePoint.y);
	if (lastTile.scale > SCALE_DETENT) {
	    lastTile.scale = 1.0;
	    lastTile.position = ccp(lastTilePoint.x+delta, lastTilePoint.y);
	}
    }
    else {
	lastTile.position = ccp(lastTile.position.x-delta, lastTile.position.y);
    }

    // Snap to position if necessary
    if (fabsf(_totalSwipeDelta) > SHIFT_DETENT) {
	[firstTile retain];
	[_gameGrid[activeRow] removeObjectAtIndex:firstTile.col];
	firstTile.position = lastTilePoint;
	firstTile.scale = 1.0;
	firstTile.col = lastTile.col;
	[_gameGrid[activeRow] insertObject:firstTile atIndex:firstTile.col];
	[firstTile release];

	for (NSInteger col = start; col < end; col++) {
	    LetterTile *thisTile = [self objectAtRow:activeRow column:col];
	    thisTile.position = [self pointForRow:activeRow column:col];
	    thisTile.col = col;
	    thisTile.scale = 1.0;
	}
	_totalSwipeDelta = 0;
	[[SimpleAudioEngine sharedEngine] playEffect:kTileMoveSound];
    }
}

- (void)shiftRightByDelta:(CGFloat)delta {
    NSInteger start = [self startColumn];
    NSInteger end = [self endColumn];
    NSInteger activeRow = _activeTile.row;
    LetterTile *firstTile = [self objectAtRow:activeRow column:start];
    LetterTile *lastTile = [self objectAtRow:activeRow column:end];
    CGPoint firstTilePoint = [self pointForRow:activeRow column:start];
    CGPoint lastTilePoint = [self pointForRow:activeRow column:end];

    // Last Tile
    if (lastTile.position.x < lastTilePoint.x) {
	lastTile.position = ccp(lastTile.position.x+delta, lastTile.position.y);
    }
    else {
	lastTile.scale = (GRID_TILE_WIDTH+_totalSwipeDelta)/GRID_TILE_WIDTH;
	lastTile.position = ccp(lastTilePoint.x-_totalSwipeDelta/2.0, lastTilePoint.y);
    }

    // Shift the rest of the row
    for (NSInteger col = end-1; col > start; col--) {
	LetterTile *tile = [self objectAtRow:activeRow column:col];
	tile.position = ccp(tile.position.x+delta, tile.position.y);
    }

    // First Tile
    if (firstTile.scale < 1.0) {
	firstTile.scale = (GRID_TILE_WIDTH-_totalSwipeDelta)/GRID_TILE_WIDTH;
	firstTile.position = ccp(firstTilePoint.x-_totalSwipeDelta/2.0, firstTilePoint.y);
	if (firstTile.scale > SCALE_DETENT) {
	    firstTile.scale = 1.0;
	    firstTile.position = ccp(firstTilePoint.x-delta, firstTilePoint.y);
	}
    }
    else {
	firstTile.position = ccp(firstTile.position.x+delta, firstTile.position.y);
    }

    // Snap to position if necessary
    if (fabsf(_totalSwipeDelta) > SHIFT_DETENT) {
	[lastTile retain];
	[_gameGrid[activeRow] removeObjectAtIndex:lastTile.col];
	lastTile.position = firstTilePoint;
	lastTile.scale = 1.0;
	lastTile.col = firstTile.col;
	[_gameGrid[activeRow] insertObject:lastTile atIndex:lastTile.col];

	for (NSInteger col = end; col > start; col--) {
	    LetterTile *thisTile = [self objectAtRow:activeRow column:col];
	    thisTile.position = [self pointForRow:activeRow column:col];
	    thisTile.col = col;
	    thisTile.scale = 1.0;
	}
	_totalSwipeDelta = 0;
	[[SimpleAudioEngine sharedEngine] playEffect:kTileMoveSound];
    }
}

- (void)shiftUpByDelta:(CGFloat)delta {
    NSInteger start = [self startRow];
    NSInteger end = [self endRow];
    NSInteger activeCol = _activeTile.col;
    LetterTile *firstTile = [self objectAtRow:start column:activeCol];
    LetterTile *lastTile = [self objectAtRow:end column:activeCol];
    CGPoint firstTilePoint = [self pointForRow:start column:activeCol];
    CGPoint lastTilePoint = [self pointForRow:end column:activeCol];

    // First Tile
    if (firstTile.position.y < firstTilePoint.y) {
	firstTile.position = ccp(firstTile.position.x, firstTile.position.y+delta);
    }
    else {
	firstTile.scale = (GRID_TILE_HEIGHT-_totalSwipeDelta)/GRID_TILE_HEIGHT;
	firstTile.position = ccp(firstTilePoint.x, firstTilePoint.y+_totalSwipeDelta/2.0);
    }

    // Shift the rest of the column
    for (NSInteger row = start+1; row < end; row++) {
	LetterTile *tile = [self objectAtRow:row column:activeCol];
	tile.position = ccp(tile.position.x, tile.position.y+delta);
    }

    // Last Tile
    if (lastTile.scale < 1.0) {
	lastTile.scale = (GRID_TILE_HEIGHT+_totalSwipeDelta)/GRID_TILE_HEIGHT;
	lastTile.position = ccp(lastTilePoint.x, lastTilePoint.y+_totalSwipeDelta/2.0);
	if (lastTile.scale > SCALE_DETENT) {
	    lastTile.scale = 1.0;
	    lastTile.position = ccp(lastTilePoint.x, lastTilePoint.y-delta);
	}
    }
    else {
	lastTile.position = ccp(lastTile.position.x, lastTile.position.y+delta);
    }

    // Snap to position if necessary
    if (fabsf(_totalSwipeDelta) > SHIFT_DETENT) {
	[firstTile retain];
	for (NSInteger row = start+1; row <= end; row++) {
	    LetterTile *thisTile = [self objectAtRow:row column:activeCol];
	    thisTile.row = row-1;
	    thisTile.position = [self pointForRow:row-1 column:activeCol];
	    thisTile.scale = 1.0;
	    [_gameGrid[row-1] replaceObjectAtIndex:activeCol withObject:thisTile];
	}
	firstTile.position = [self pointForRow:end column:activeCol];
	firstTile.row = end;
	[_gameGrid[end] replaceObjectAtIndex:activeCol withObject:firstTile];
	[firstTile release];
	_totalSwipeDelta = 0;
	[[SimpleAudioEngine sharedEngine] playEffect:kTileMoveSound];
    }
}

- (void)shiftDownByDelta:(CGFloat)delta {
    NSInteger start = [self startRow];
    NSInteger end = [self endRow];
    NSInteger activeCol = _activeTile.col;
    LetterTile *firstTile = [self objectAtRow:start column:activeCol];
    LetterTile *lastTile = [self objectAtRow:end column:activeCol];
    CGPoint firstTilePoint = [self pointForRow:start column:activeCol];
    CGPoint lastTilePoint = [self pointForRow:end column:activeCol];

    // Last Tile
    if (lastTile.position.y > lastTilePoint.y) {
	lastTile.position = ccp(lastTile.position.x, lastTile.position.y-delta);
    }
    else {
	lastTile.scale = (GRID_TILE_HEIGHT+_totalSwipeDelta)/GRID_TILE_HEIGHT;
	lastTile.position = ccp(lastTilePoint.x, lastTilePoint.y+_totalSwipeDelta/2.0);
    }

    // Shift the rest of the column
    for (NSInteger row = end-1; row > start; row--) {
	LetterTile *tile = [self objectAtRow:row column:activeCol];
	tile.position = ccp(tile.position.x, tile.position.y-delta);
    }

    // First Tile
    if (firstTile.scale < 1.0) {
	firstTile.scale = (GRID_TILE_HEIGHT-_totalSwipeDelta)/GRID_TILE_HEIGHT;
	firstTile.position = ccp(firstTilePoint.x, firstTilePoint.y+_totalSwipeDelta/2.0);
	if (firstTile.scale > SCALE_DETENT) {
	    firstTile.scale = 1.0;
	    firstTile.position = ccp(firstTilePoint.x, firstTilePoint.y-delta);
	}
    }
    else {
	firstTile.position = ccp(firstTile.position.x, firstTile.position.y-delta);
    }
    
    // Snap to position if necessary
    if (fabsf(_totalSwipeDelta) > SHIFT_DETENT) {
	[lastTile retain];
	for (NSInteger row = end-1; row >= start; row--) {
	    LetterTile *thisTile = [self objectAtRow:row column:activeCol];
	    thisTile.row = row+1;
	    thisTile.position = [self pointForRow:row+1 column:activeCol];
	    thisTile.scale = 1.0;
	    [_gameGrid[row+1] replaceObjectAtIndex:activeCol withObject:thisTile];
	}
	lastTile.position = [self pointForRow:start column:activeCol];
	lastTile.row = start;
	[_gameGrid[start] replaceObjectAtIndex:activeCol withObject:lastTile];
	[lastTile release];
	_totalSwipeDelta = 0;
	[[SimpleAudioEngine sharedEngine] playEffect:kTileMoveSound];
    }
}

- (void)updateWithSwipe:(GridSwipeEventType)swipe change:(CGFloat)change {
    if (!AreSwipesSame(swipe, _prevSwipe) && _prevSwipe != kGridSwipeEventNone) [self snapTiles];
    if (swipe == kGridSwipeEventLeft) {
	[self shiftLeftByDelta:change];
    }
    else if (swipe == kGridSwipeEventRight) {
	[self shiftRightByDelta:change];
    }
    else if (swipe == kGridSwipeEventUp) {
	[self shiftUpByDelta:change];
    }
    else if (swipe == kGridSwipeEventDown) {
	[self shiftDownByDelta:change];
    }
    _prevSwipe = swipe;
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL touchBegan = NO;
    if (!_activeTouch) {
	if ( ((self.activeTile = [self tileForTouch:touch]) != nil) && (self.activeTile.isLocked == NO)) {
	    self.activeTouch = touch;
	    touchBegan = YES;
	    _prevSwipe = kGridSwipeEventNone;
	    _startLocation = [touch locationInView:[touch view]];
	    _totalSwipeDelta = 0;
	}
    }
    return touchBegan;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint currLocation = [touch locationInView:[touch view]];
    CGFloat deltaX = fabsf(currLocation.x-_startLocation.x);
    CGFloat deltaY = fabsf(currLocation.y-_startLocation.y);

    if ((IsHorizontalSwipe(_prevSwipe) && deltaX > 0) || (deltaX > H_SWIPE_LENGTH && fabsf(deltaY) < V_SWIPE_VARIANCE)) {
	GridSwipeEventType swipe = (_startLocation.x < currLocation.x) ? kGridSwipeEventRight : kGridSwipeEventLeft;
	_totalSwipeDelta += (_startLocation.x < currLocation.x) ? -deltaX : deltaX;
	[self updateWithSwipe:swipe change:deltaX];
	_startLocation = currLocation;
	return;
    }

    if ((IsVerticalSwipe(_prevSwipe) && deltaY > 0) || (deltaY > V_SWIPE_LENGTH && fabsf(deltaX) < H_SWIPE_VARIANCE)) {
	GridSwipeEventType swipe = (_startLocation.y < currLocation.y) ? kGridSwipeEventDown : kGridSwipeEventUp;
	_totalSwipeDelta += (_startLocation.y < currLocation.y) ? -deltaY : deltaY;
	[self updateWithSwipe:swipe change:deltaY];
	_startLocation = currLocation;
	return;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self snapTiles];
    self.activeTouch = nil;
    self.activeTile = nil;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self snapTiles];
    self.activeTouch = nil;
    self.activeTile = nil;
}

#pragma mark - Grid Model Helpers

- (void)initializeSounds {
    [[SimpleAudioEngine sharedEngine] preloadEffect:kTileMoveSound];
}

- (void)initializeGridWithBoard:(NSDictionary *)board {
    NSInteger rowCount = [board[@"height"] intValue];
    NSInteger columnCount = [board[@"height"] intValue];
    _gameGrid = [[NSMutableArray alloc] init];
    _gridCoordinates = [[NSMutableArray alloc] init];
    NSMutableArray *order = [NSMutableArray arrayWithRange:NSMakeRange(0, rowCount*columnCount)];
    [order shuffle];
    NSInteger shuffleIndex = 0;
    for (int r = 0; r < rowCount; r++) {
	NSMutableArray *row = [[NSMutableArray alloc] init];
	NSMutableArray *coordinatesRow = [[NSMutableArray alloc] init];
	for (int c = 0; c < columnCount; c++) {
#define CHEAT_MODE
#if defined(CHEAT_MODE)
	    NSInteger shuffleRow = r;
	    NSInteger shuffleCol = c;
	    LetterTileType type  = CharacterToType([board[@"grid"][shuffleRow] characterAtIndex:shuffleCol]);
#else
	    NSInteger shuffleRow = [order[shuffleIndex] intValue] / rowCount;
	    NSInteger shuffleCol = [order[shuffleIndex] intValue] % rowCount;
	    LetterTileType type  = CharacterToType([board[@"grid"][shuffleRow] characterAtIndex:shuffleCol]);
#endif
	    shuffleIndex++;
#undef CHEAT_MODE
	    LetterTile *tile = [LetterTile letterTileWithType:type];
	    tile.row = r;
	    tile.col = c;
	    tile.position = ccp(XCoord(c), YCoord(r));
	    [_tilesSheet addChild:tile];
	    [row addObject:tile];
	    [coordinatesRow addObject:[NSValue valueWithCGPoint:tile.position]];
	}
	[_gridCoordinates addObject:coordinatesRow];
	[_gameGrid addObject:row];
	[coordinatesRow release];
	[row release];
    }
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

- (NSInteger)activeRow {
    return _activeTile.row;
}

- (NSInteger)activeColumn {
    return _activeTile.col;
}

- (LetterTile *)objectAtRow:(NSInteger)row column:(NSInteger)column {
    return (LetterTile *)_gameGrid[row][column];
}

- (CGPoint)pointForRow:(NSInteger)row column:(NSInteger)column {
    return [_gridCoordinates[row][column] CGPointValue];
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

- (void)resetObjectAtRow:(NSInteger)row column:(NSInteger)column {
    LetterTile *tile = [self objectAtRow:row column:column];
    tile.position = [self pointForRow:row column:column];
    tile.scale = 1.0;
}

- (void)updateObjectsAtRow:(NSInteger)row column:(NSInteger)column length:(NSInteger)length type:(WordOrientationType)type locked:(BOOL)locked {
    for (NSInteger i = 0; i < length; i++) {
	if (type == kWordOrientationHorizontal) {
	    LetterTile *tile = [self objectAtRow:row column:column+i];
	    tile.lockedHorizontal = locked;
	}
	else {
	    LetterTile *tile = [self objectAtRow:row+i column:column];
	    tile.lockedVertical = locked;
	}
    }
}

// Really naive grid search
- (BOOL)findWord:(NSString *)word row:(NSInteger *)row column:(NSInteger *)column type:(WordOrientationType *)type locked:(BOOL)locked {
    *type = kWordOrientationNone;
    *row  = *column = -1;
    NSInteger wordLength = [word length];

    // Search Rows
    for (NSInteger r = 0; r < [_board[@"height"] intValue]; r++) {
	for (NSInteger c = 0; c < ([_board[@"width"] intValue]-wordLength+1); c++) {
	    for (NSInteger i = 0; i < wordLength; i++) {
		LetterTile *tile = [self objectAtRow:r column:c+i];
		LetterTileType t = CharacterToType([word characterAtIndex:i]);
		if (tile.type == t && tile.isLockedHorizontal == locked) {
		    if (i == wordLength-1) {
			*row = r;
			*column = c;
			*type = kWordOrientationHorizontal;
			return YES;
		    }
		}
		else {
		    break;
		}
	    }
	}
    }

    // Search Columns
    for (NSInteger c = 0; c < [_board[@"width"] intValue]; c++) {
	for (NSInteger r = 0; r < ([_board[@"height"] intValue]-wordLength+1); r++) {
	    for (NSInteger i = 0; i < wordLength; i++) {
		LetterTile *tile = [self objectAtRow:r+i column:c];
		LetterTileType t = CharacterToType([word characterAtIndex:i]);
		if (tile.type == t && tile.isLockedVertical == locked) {
		    if (i == wordLength-1) {
			*row = r;
			*column = c;
			*type = kWordOrientationVertical;
			return YES;
		    }
		}
		else {
		    break;
		}
	    }
	}
    }

    return NO;
}

@end
