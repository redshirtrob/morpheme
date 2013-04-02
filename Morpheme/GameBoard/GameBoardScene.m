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

@interface GameBoardScene ()
@property (nonatomic, retain) CCLayer *backgroundLayer;
@property (nonatomic, retain) TileGridLayer *tileGridLayer;
@property (nonatomic, retain) WordListLayer *wordListLayer;
@end

@implementation GameBoardScene

- (id)init {
    self = [super init];
    if (self) {
	_backgroundLayer = [[CCLayer alloc] init];
	CCSprite *background = [CCSprite spriteWithFile:@"gameboard-bg.png"];
	CGSize size = [[CCDirector sharedDirector] winSize];
	background.position = ccp(size.width/2, size.height/2);
	[_backgroundLayer addChild:background];
	[self addChild:_backgroundLayer];

	_tileGridLayer = [[TileGridLayer alloc] init];
	[self addChild:_tileGridLayer];
	
	_wordListLayer = [[WordListLayer alloc] initWithOffset:LABEL_Y_OFFSET wordList:nil];
	[self addChild:_wordListLayer];
    }
    return self;
}

- (void)dealloc {
    [_backgroundLayer release];
    [_tileGridLayer release];
    [_wordListLayer release];
    [super dealloc];
}

@end
