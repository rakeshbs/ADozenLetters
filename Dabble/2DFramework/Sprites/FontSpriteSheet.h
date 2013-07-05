//
//  SpriteSheet.h
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 Qucentis. All rights reserved.
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
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic,retain) FontSpriteSheet *fontSpriteSheet;
@property (nonatomic) TextureCoord *textureCoordinates;
@property (nonatomic) Vector3D *textureRect;
@property (nonatomic) CGRect textureCGRect;
@property (nonatomic) CGRect textureCoordinatesCGRect;


-(void)calculateCoordinates;

@end

@interface FontSpriteSheet : NSObject {
	Texture2D *texture;
    NSDictionary *fontSpriteDictionary;
    

}
@property (nonatomic,retain) Texture2D *texture;
@property (nonatomic,retain) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) FontSpriteType fontSpriteType;
@property (nonatomic,retain) UIColor* fontColor;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;


-(void)calculateCoordinates;
-(id)initWithType:(FontSpriteType)type andFontName:(NSString *)fontName andFontSize:(CGFloat)fontSize;
-(FontSprite *)getFontSprite:(NSString *)str;
-(void)addFontSprite:(FontSprite *)fontSprite;
@end