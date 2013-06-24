//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "FontSpriteSheet.h"
#import "Texture2D.h"

static NSString *fontCharactersUpper = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static NSString *fontCharactersLower = @"abcdefghijklmnopqrstuvwxvz";
static NSString *fontCharactersNumbers = @"1234567890";

@implementation FontSprite



-(void)calculateCoordinates
{
    if (_textureCoordinates !=nil)
        return;
    _textureCoordinates = malloc(sizeof(TextureCoord)*6);
    _textureRect = malloc(sizeof(Vector3D)*6);
    
    CGFloat totalWidth = self.fontSpriteSheet.width;
    CGFloat totalHeight = self.fontSpriteSheet.height;
    
    _textureCoordinates[0] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    _textureCoordinates[1] = (TextureCoord)
        {.s = ( (_offSetX+_width)/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    
    _textureCoordinates[2] = (TextureCoord)
        {.s = ( (_offSetX+_width)/totalWidth), .t = (_offSetY/totalHeight)};
    
    _textureCoordinates[3] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    _textureCoordinates[4] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = (_offSetY/totalHeight)};
    _textureCoordinates[5] = (TextureCoord)
        {.s = ( (_offSetX+_width)/totalWidth), .t = (_offSetY/totalHeight)};
    
    
    CGFloat scale = [[UIScreen mainScreen]scale]*2;
    
    _textureRect[0] = (Vector3D) { .x = -_width/scale, .y = -_height/scale, .z = 0.0};
    _textureRect[1] = (Vector3D) { .x = _width/scale, .y = -_height/scale, .z = 0.0};
    _textureRect[2] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
    _textureRect[3] = (Vector3D) { .x = -_width/scale, .y =   -_height/scale, .z = 0.0};
    _textureRect[4] = (Vector3D) { .x = -_width/scale, .y = _height/scale, .z = 0.0};
    _textureRect[5] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
}

-(void)dealloc
{
    [super dealloc];
    self.fontSpriteSheet = nil;
    self.key = nil;
    free(_textureRect);
    
    free(_textureCoordinates);
}

@end

@implementation FontSpriteSheet

@synthesize texture;

-(id)initWithType:(FontSpriteType)type andFontName:(NSString *)fontName andFontSize:(CGFloat)fontSize
{
    if (self = [super init]) 
    {
        fontSpriteDictionary = [[NSMutableDictionary alloc]init];
        self.fontSpriteType = type;
        self.fontName = fontName;
        self.fontSize = fontSize;
        
        
        if (type == FontSpriteTypeAlphabetsUppercase)
        {
            texture = [[Texture2D alloc]
                                      initFontSpriteSheetWith:fontCharactersUpper
                                      andFontSprite:self];
        }
        else if (type == FontSpriteTypeAlphabetsUppercase)
        {
            texture = [[Texture2D alloc]
                              initFontSpriteSheetWith:fontCharactersLower
                              andFontSprite:self];
        }
        else
        {
            texture = [[Texture2D alloc]
                           initFontSpriteSheetWith:fontCharactersNumbers
                           andFontSprite:self];

        }
        
    }
    return self;

}

-(void)calculateCoordinates
{
    for (FontSprite *f in fontSpriteDictionary.objectEnumerator)
    {
        [f calculateCoordinates];
    }
}

-(FontSprite *)getFontSprite:(NSString *)str
{
    return fontSpriteDictionary[str];
}

-(void)addFontSprite:(FontSprite *)fontSprite
{
    [fontSpriteDictionary setValue:fontSprite forKey:fontSprite.key];
    fontSprite.fontSpriteSheet = self;
}

-(void)dealloc
{
    [super dealloc];
    [texture release];
    self.fontName = nil;
    self.fontColor = nil;

}




@end
