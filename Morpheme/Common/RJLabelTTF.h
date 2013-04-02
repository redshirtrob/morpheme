//
//  RJLabelTTF.h
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RJLabelTTF : CCLabelTTF {
}

@property (nonatomic) BOOL strikethrough;
@property (nonatomic, retain) UIColor *strikethroughColor;
@property (nonatomic) CGFloat strikethroughWidth;

@end
