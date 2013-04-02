//
//  IntroScene.m
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "IntroScene.h"
#import "MainMenuLayer.h"

@implementation IntroScene

- (id)init {
    self = [super init];
    if (self) {
	CCLayer *backgroundLayer = [[CCLayer alloc] init];
	CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
	CGSize size = [[CCDirector sharedDirector] winSize];
	background.position = ccp(size.width/2, size.height/2);
	[backgroundLayer addChild:background];
	[self addChild:backgroundLayer];
	[backgroundLayer release];

	MainMenuLayer *menuLayer = [[MainMenuLayer alloc] init];
	[self addChild:menuLayer];
	[menuLayer release];
    }
    return self;
}

@end
