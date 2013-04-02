//
//  MorphemeCommon.h
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//
//

#ifndef Morpheme_MorphemeCommon_h
#define Morpheme_MorphemeCommon_h

#define kTileTextureFile @"Tiles.png"
#define kTileDataFile @"Tiles.plist"
#define kDefaultBackgroundImage @"kerrisky.png"

#define PRINT_POINT(l, s) NSLog(@"%s: (%6.2f, %6.2f)", l, s.x, s.y)
#define PRINT_SIZE(l, s) NSLog(@"%s: [%6.2f, %6.2f]", l, s.width, s.height)
#define PRINT_RECT(l, s) NSLog(@"%s: (%6.2f, %6.2f) [%6.2f, %6.2f]", l, s.origin.x, s.origin.y, s.size.width, s.size.height)

#endif
