//
//  WordListLayer.h
//  Morpheme
//
//  Created by Robert Jones on 4/1/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol WordListLayerDelegate;

@interface WordListLayer : CCLayer {
    
}

@property (nonatomic, assign) id <WordListLayerDelegate> delegate;
@property (nonatomic) CGFloat offset;
@property (nonatomic, retain) NSArray *wordList;

- (id)initWithOffset:(CGFloat)offset wordList:(NSArray *)wordList;

@end

@protocol WordListLayerDelegate
@required
- (void)didUnlockWord:(NSString *)word;
- (BOOL)didLockWord:(NSString *)word;
@end
