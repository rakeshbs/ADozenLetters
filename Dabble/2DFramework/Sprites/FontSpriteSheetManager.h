//
//  FontSpriteSheetManager.h
//  Dabble
//
//  Created by Rakesh on 08/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FontSpriteSheet.h"

@interface FontSpriteSheetManager : NSObject
{
    NSMutableDictionary *dictionary;
}
+(FontSpriteSheetManager *)getSharedFontSpriteSheetManager;
-(FontSprite *)getFontForCharacter:(NSString *)character withFont:(NSString *)fontName andSize:(CGFloat)size;
@end
