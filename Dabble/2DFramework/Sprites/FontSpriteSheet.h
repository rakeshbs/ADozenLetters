//
//  SpriteSheet.h
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "GLCommon.h"

@interface FontSprite : NSObject


@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) NSMutableArray *textureStringLayers;
@property (nonatomic) CGFloat offSetX;
@property (nonatomic) CGFloat offSetY;
@property (nonatomic) CGFloat widthX;
@property (nonatomic) CGFloat widthY;

@end

@interface FontSpriteSheet : NSObject {
	Texture2D *fontSpriteSheet;
    NSDictionary *fontSpriteDictionary;
    
    FontSprite *currentGenFontSprite;
    
    
}

@end