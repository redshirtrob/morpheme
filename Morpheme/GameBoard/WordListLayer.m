//
//  WordListLayer.m
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "WordListLayer.h"
#import "MorphemeCommon.h"

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
@property (nonatomic, retain) NSMutableArray *wordLabels;
@end

@implementation WordListLayer

- (id)initWithOffset:(CGFloat)offset wordList:(NSArray *)wordList {
    self = [super init];
    if (self) {
	self.offset = offset;
	self.wordList = wordList;
	_wordLabels = [[NSMutableArray alloc] init];
	for (NSInteger row = 0; row < N_ROWS; row++) {
	    for (NSInteger col = 0; col < N_COLS; col++) {
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"kMbMMbMMbk" fontName:@"Marker Felt" fontSize:FONT_SIZE];
		label.position = ccp(XCoord(col), YCoord(row));
		[self addChild:label];
		[_wordLabels addObject:label];
	    }
	}
    }
    return self;
}

- (void)dealloc {
    [_wordList release];
    [_wordLabels release];
    [super dealloc];
}

#pragma mark Getters/Setters

@end
