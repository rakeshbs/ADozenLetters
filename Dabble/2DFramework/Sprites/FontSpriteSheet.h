//
//  SpriteSheet.h
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"

typedef enum 
{
    FontSpriteTypeAlphabetsUppercase = 0,
    FontSpriteTypeAlphabetsLowerCase,
    FontSpriteTypeNumbers
}FontSpriteType;

@class Texture2D;

@class FontSpriteSheet;

@interface FontSprite : NSObject
@property (nonatomic,retain) NSString *key;
@property (nonatomic) CGFloat offSetX;
@property (nonatomic) CGFloat offSetY;
@property (nonatomic) CGFloat textureWidth;
@property (nonatomic) CGFloat textureHeight;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic,retain) FontSpriteSheet *fontSpriteSheet;
@property (nonatomic) TextureCoord *textureCoordinates;
@property (nonatomic) Vector3D *texureRect;

-(void)calculateCoordinates;

@end

@interface FontSpriteSheet : NSObject {
	Texture2D *fontSpriteSheet;
    NSDictionary *fontSpriteDictionary;
    

}

@property (nonatomic,retain) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) FontSpriteType fontSpriteType;
@property (nonatomic,retain) UIColor* fontColor;
@property (nonatomic) CGFloat textureWidth;
@property (nonatomic) CGFloat textureHeight;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

-(void)calculateCoordinates;
-(void)addFontSprite:(FontSprite *)fontSprite;
@end