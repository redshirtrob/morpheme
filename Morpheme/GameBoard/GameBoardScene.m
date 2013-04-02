//
//  GameBoardScene.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "GameBoardScene.h"
#import "TileGridLayer.h"
#import "WordListLayer.h"
#import "MorphemeCommon.h"

#define LABEL_Y_OFFSET (242.0)

@interface GameBoardScene () <WordListLayerDelegate>
@property (nonatomic, retain) TileGridLayer *tileGridLayer;
@property (nonatomic, retain) WordListLayer *wordListLayer;
@property (nonatomic, retain) NSDictionary *board;
@end

@implementation GameBoardScene

- (id)initWithGameBoard:(NSDictionary *)board {
    self = [super init];
    if (self) {
	CCLayer *backgroundLayer = [[CCLayer alloc] init];
	CCSprite *background = [CCSprite spriteWithFile:kDefaultBackgroundImage];
	CGSize size = [[CCDirector sharedDirector] winSize];
	background.position = ccp(size.width/2, size.height/2);
	[backgroundLayer addChild:background];
	[self addChild:backgroundLayer];
	[backgroundLayer release];

	self.board = board;
	_tileGridLayer = [[TileGridLayer alloc] initWithGameBoard:board];
	[self addChild:_tileGridLayer];
	
	_wordListLayer = [[WordListLayer alloc] initWithOffset:LABEL_Y_OFFSET wordList:board[@"words"]];
	_wordListLayer.delegate = self;
	[self addChild:_wordListLayer];
    }
    return self;
}

- (void)dealloc {
    [_tileGridLayer release];
    _wordListLayer.delegate = nil;
    [_wordListLayer release];
    [super dealloc];
}

#pragma mark - WordListLayerDelegate

- (void)didUnlockWord:(NSString *)word {
    [_tileGridLayer unlockWord:word];
}

- (BOOL)didLockWord:(NSString *)word {
    return [_tileGridLayer lockWord:word];
}

@end
