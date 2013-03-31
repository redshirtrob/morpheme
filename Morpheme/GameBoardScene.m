//
//  GameBoardScene.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "GameBoardScene.h"
#import "MorphemeCommon.h"

@interface GameBoardScene ()
@property (nonatomic, retain) CCLayer *backgroundLayer;
@property (nonatomic, retain) CCSprite *background;
@end

@implementation GameBoardScene

- (id)init {
    self = [super init];
    if (self) {
	_backgroundLayer = [[CCLayer alloc] init];
	_background = [CCSprite spriteWithFile:@"gameboard-bg.png"];
	[_backgroundLayer addChild:_background];
	[self addChild:_backgroundLayer];
    }
    return self;
}

-(void)onEnter {
    [super onEnter];
    CGSize size = [[CCDirector sharedDirector] winSize];
    _background.position = ccp(size.width/2, size.height/2);
}

- (void)dealloc {
    [super dealloc];
}

@end
