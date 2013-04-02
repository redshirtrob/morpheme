//
//  MainMenuLayer.m
//  Morpheme
//
//  Created by Robert Jones on 4/2/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameBoardScene.h"
#import "RJLabelTTF.h"

@interface MainMenuLayer ()
@property (nonatomic, retain) NSArray *boards;
@end

@implementation MainMenuLayer

- (id)init {
    self = [super init];
    if (self) {
	RJLabelTTF *title = [RJLabelTTF labelWithString:@"Morpheme" fontName:@"Comfortaa-Bold" fontSize:72];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	title.position =  ccp(size.width/2.0, size.height*3.0/5.0);
	[self addChild:title];

	[CCMenuItemFont setFontSize:36];
	CCMenuItem *levelOneItem = [CCMenuItemFont itemWithString:@"Level One" target:self selector:@selector(play:)];
	levelOneItem.tag = 0;
	CCMenuItem *levelTwoItem = [CCMenuItemFont itemWithString:@"Level Two" target:self selector:@selector(play:)];
	levelTwoItem.tag = 1;
	CCMenuItem *levelThreeItem = [CCMenuItemFont itemWithString:@"Level Three" target:self selector:@selector(play:)];
	levelThreeItem.tag = 2;

	CCMenu *menu = [CCMenu menuWithItems:levelOneItem, levelTwoItem, levelThreeItem, nil];
	[menu alignItemsVerticallyWithPadding:20];
	[menu setPosition:ccp(size.width/2.0, size.height*3.0/5.0 - 200)];
	[self addChild:menu];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"GameBoards" ofType:@"plist"];
	NSDictionary *gameBoards = [NSDictionary dictionaryWithContentsOfFile:path];
	self.boards = gameBoards[@"boards"];
    }
    return self;
}

- (void)dealloc {
    [_boards release];
    [super dealloc];
}

- (void)play:(id)sender {
    CCMenuItem *item = (CCMenuItem *)sender;
    NSInteger gameNumber = item.tag;

    GameBoardScene *scene = [[[GameBoardScene alloc] initWithGameBoard:_boards[gameNumber]] autorelease];
    [[CCDirector sharedDirector] pushScene:scene];
}

@end
