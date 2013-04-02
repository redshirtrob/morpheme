//
//  GameOverMenuLayer.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "GameOverMenuLayer.h"
#import "RJLabelTTF.h"

@implementation GameOverMenuLayer

- (id)init {
    self = [super init];
    if (self) {
	RJLabelTTF *title = [RJLabelTTF labelWithString:@"You Win!" fontName:@"Marker Felt" fontSize:96];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	title.position =  ccp(size.width/2.0, size.height*3.0/5.0);
	[self addChild:title];

	[CCMenuItemFont setFontSize:36];
	CCMenuItem *playAgainItem = [CCMenuItemFont itemWithString:@"Play Again" target:self selector:@selector(playAgain:)];
	CCMenuItem *quitItem = [CCMenuItemFont itemWithString:@"Quit" target:self selector:@selector(quit:)];

	CCMenu *menu = [CCMenu menuWithItems:playAgainItem, quitItem, nil];
	[menu alignItemsVerticallyWithPadding:40];
	[menu setPosition:ccp(size.width/2.0, size.height*3.0/5.0 - 200)];
	[self addChild:menu];
    }
    return self;
}

- (void)playAgain:(id)sender {
    [[CCDirector sharedDirector] popScene];
}

- (void)quit:(id)sender {
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] popScene];
}

@end
