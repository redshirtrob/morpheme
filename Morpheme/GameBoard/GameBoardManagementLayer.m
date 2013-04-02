//
//  GameBoardManagementLayer.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "GameBoardManagementLayer.h"


@implementation GameBoardManagementLayer

- (id)init {
    self = [super init];
    if (self) {
	CGSize size = [[CCDirector sharedDirector] winSize];
	[CCMenuItemFont setFontSize:36];
	CCMenuItemFont *quitItem = [CCMenuItemFont itemWithString:@"Quit Board" target:self selector:@selector(quit:)];
	quitItem.color = ccc3(0, 0, 0);

	CCMenu *menu = [CCMenu menuWithItems:quitItem, nil];
	[menu alignItemsVerticallyWithPadding:20];

	[menu setPosition:ccp(size.width-100, 35.0)];
	[self addChild:menu];
    }
    return self;
}

- (void)quit:(id)sender {
    [[CCDirector sharedDirector] popScene];
}

@end
