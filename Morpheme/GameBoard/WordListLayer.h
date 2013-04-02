//
//  WordListLayer.h
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface WordListLayer : CCLayer {
    
}

@property (nonatomic) CGFloat offset;
@property (nonatomic, retain) NSArray *wordList;

- (id)initWithOffset:(CGFloat)offset wordList:(NSArray *)wordList;

@end
