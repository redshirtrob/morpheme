//
//  WordListLayer.m
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "WordListLayer.h"
#import "MorphemeCommon.h"
#import "RJLabelTTF.h"

#define N_ROWS (5)
#define N_COLS (3)

#define WORD_LIST_SIDE_MARGIN (24.0)
#define WORD_LIST_BOTTOM_MARGIN (22.0)
#define LABEL_WIDTH (180.0)
#define LABEL_HEIGHT (30.0)
#define LABEL_HORIZONTAL_SEPARATOR (46.0)
#define LABEL_VERTICAL_SEPARATOR (12.0)
#define FONT_SIZE (28.0)

#define XCoord(i) (WORD_LIST_SIDE_MARGIN + (((i) + 1) * LABEL_HORIZONTAL_SEPARATOR) + (((i) + 0.5) * LABEL_WIDTH))
#define YCoord(j) (_offset - ((((j) + 1) * LABEL_VERTICAL_SEPARATOR) + (((j) + 0.5) * LABEL_HEIGHT)))

@interface WordListLayer ()
@property (nonatomic, assign) UITouch *activeTouch;
@property (nonatomic, retain) NSMutableArray *wordLabels;
@end

@implementation WordListLayer {
    NSArray *_wordList;
}

- (id)initWithOffset:(CGFloat)offset wordList:(NSArray *)wordList {
    self = [super init];
    if (self) {
	self.offset = offset;
	_wordLabels = [[NSMutableArray alloc] init];
	for (NSInteger row = 0; row < N_ROWS; row++) {
	    for (NSInteger col = 0; col < N_COLS; col++) {
		RJLabelTTF *label = [RJLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:FONT_SIZE];
		label.position = ccp(XCoord(col), YCoord(row));
		[self addChild:label];
		[_wordLabels addObject:label];
	    }
	}
	self.wordList = wordList;
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (void)dealloc {
    [_wordList release];
    [_wordLabels release];
    [super dealloc];
}

#pragma mark Getters/Setters

- (void)setWordList:(NSArray *)wordList {
    if (_wordList != wordList) {
	NSArray *tmpWordList = _wordList;
	_wordList = [wordList retain];
	[tmpWordList release];
	[self updateLabels];
    }
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL touchBegan = NO;
    if (!_activeTouch && [self labelForTouch:touch]) {
	self.activeTouch = touch;
	touchBegan = YES;
    }
    return touchBegan;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (touch == _activeTouch) {
	RJLabelTTF *label = [self labelForTouch:touch];
	if (label) [self handleTouchUpInside:label];
	self.activeTouch = nil;
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    if (touch == _activeTouch) {
	self.activeTouch = nil;
    }
}

#pragma mark - Helpers

- (void)handleTouchUpInside:(RJLabelTTF *)label {
    NSLog(@"User tapped: %@", label.string);
}

- (void)updateLabels {
    NSInteger index = 0;
    for (RJLabelTTF *label in _wordLabels) {
	NSString *word = @"";
	if (index < [_wordList count]) {
	    word = _wordList[index];
	}
	[label setString:word];
	index++;
    }
}

- (RJLabelTTF *)labelForTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint glLocation = [[CCDirector sharedDirector] convertToGL:location];
    for (RJLabelTTF *label in _wordLabels) {
	if (CGRectContainsPoint(label.boundingBox, glLocation)) {
	    return label;
	}
    }
    return nil;
}

@end
