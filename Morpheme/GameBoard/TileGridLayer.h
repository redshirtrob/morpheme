//
//  TileGridLayer.h
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TileGridLayer : CCLayer {
    
}

- (id)initWithGameBoard:(NSDictionary *)board;
- (void)unlockWord:(NSString *)word;
- (BOOL)lockWord:(NSString *)word;

@end
