//
//  TileGridLayer.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "TileGridLayer.h"
#import "MorphemeCommon.h"

@implementation TileGridLayer

- (id)init {
    self = [super init];
    if (self) {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tiles.plist"];
	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"A-Color.png"];
	sprite.position = ccp(100.0, 100.0);
	[self addChild:sprite];
    }
    return self;
}

@end
