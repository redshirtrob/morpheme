//
//  LetterTile.h
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright 2013 Robert Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    LetterTileA = 0,
    LetterTileB,
    LetterTileC,
    LetterTileD,
    LetterTileE,
    LetterTileF,
    LetterTileG,
    LetterTileH,
    LetterTileI,
    LetterTileJ,
    LetterTileK,
    LetterTileL,
    LetterTileM,
    LetterTileN,
    LetterTileO,
    LetterTileP,
    LetterTileQ,
    LetterTileR,
    LetterTileS,
    LetterTileT,
    LetterTileU,
    LetterTileV,
    LetterTileW,
    LetterTileX,
    LetterTileY,
    LetterTileZ,
} LetterTileType;

@interface LetterTile : CCSprite {
    
}

@property (nonatomic) LetterTileType type;
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger col;
@property (nonatomic, readonly) BOOL isLocked;
@property (nonatomic, getter=isLockedVertical) BOOL lockedVertical;
@property (nonatomic, getter=isLockedHorizontal) BOOL lockedHorizontal;

+ (id)letterTileWithType:(LetterTileType)type;
+ (id)randomTile;

- (id)initWithType:(LetterTileType)type;
- (BOOL)containsTouchLocation:(CGPoint)location;

@end
