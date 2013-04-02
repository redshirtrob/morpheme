//
//  GameOverScene.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "GameOverScene.h"
#import "GameOverMenuLayer.h"
#import "MorphemeCommon.h"

@implementation GameOverScene

- (id)init {
    self = [super init];
    if (self) {
	CCLayer *backgroundLayer = [[CCLayer alloc] init];
	CCSprite *background = [CCSprite spriteWithFile:kDefaultBackgroundImage];
	CGSize size = [[CCDirector sharedDirector] winSize];
	background.position = ccp(size.width/2, size.height/2);
	[backgroundLayer addChild:background];
	[self addChild:backgroundLayer];
	[backgroundLayer release];

	GameOverMenuLayer *menuLayer = [[GameOverMenuLayer alloc] init];
	[self addChild:menuLayer];
	[menuLayer release];
    }
    return self;
}

@end
