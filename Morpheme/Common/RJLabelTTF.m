//
//  RJLabelTTF.m
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import "RJLabelTTF.h"
#import "MorphemeCommon.h"

#define OVERRUN (5.0)
#define LINE_WIDTH (3.0)
#define LABEL_RED (0)
#define LABEL_GREEN (15)
#define LABEL_BLUE (83)

@implementation RJLabelTTF {
    UIColor *_strikethroughColor;
    CGFloat _red;
    CGFloat _green;
    CGFloat _blue;
    CGFloat _alpha;
    CGPoint _strikethroughStart;
    CGPoint _strikethroughEnd;
}

+ (id)labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size {
    RJLabelTTF *label = [super labelWithString:string fontName:name fontSize:size];
    label.color = ccc3(LABEL_RED, LABEL_GREEN, LABEL_BLUE);
    label.strikethrough = NO;
    label.strikethroughWidth = LINE_WIDTH;
    label.strikethroughColor = [UIColor colorWithRed:CG(LABEL_RED) green:CG(LABEL_GREEN) blue:CG(LABEL_BLUE) alpha:1.0];
    return label;
}

- (void)draw {
    [super draw];
    if (_strikethrough && [self.string length]) {
	ccDrawColor4F(_red, _green, _blue, _alpha);
	glLineWidth(_strikethroughWidth);
	ccDrawLine(_strikethroughStart, _strikethroughEnd);
    }
}

- (void)dealloc {
    [_strikethroughColor release];
    [super dealloc];
}

#pragma mark Getters/Setters

- (void)setString:(NSString *)string {
    [super setString:string];
    CGRect frame = self.boundingBox;
    CGPoint point = [self convertToNodeSpace:frame.origin];
    CGFloat yOffset = point.y + frame.size.height/2.0;
    _strikethroughStart = ccp(point.x-OVERRUN, yOffset);
    _strikethroughEnd = ccp(point.x+frame.size.width+OVERRUN, yOffset);
}

- (void)setStrikethroughColor:(UIColor *)strikethroughColor {
    if (_strikethroughColor != strikethroughColor) {
	UIColor *tmpStrikethroughColor = _strikethroughColor;
	_strikethroughColor = [strikethroughColor retain];
	[tmpStrikethroughColor release];

	if ([_strikethroughColor getRed:&_red green:&_green blue:&_blue alpha:&_alpha] == NO) {
	    _red = _green = _blue = 0;
	    _alpha = 1.0;
	}
    }
}

- (UIColor *)strikethroughColor {
    return _strikethroughColor;
}

@end
