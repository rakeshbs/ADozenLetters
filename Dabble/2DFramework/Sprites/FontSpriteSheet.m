//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FontSpriteSheet.h"
#import "Texture2D.h"

NSString *fontCharactersUpper = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
NSString *fontCharactersLower = @"abcdefghijklmnopqrstuvwxvz";
NSString *fontCharactersNumbers = @"1234567890:.";

@implementation FontSprite

-(void)calculateCoordinates
{
    _textureCoordinates = malloc(sizeof(TextureCoord)*4);
    _texureRect = malloc(sizeof(Vector3D)*4);
    
    CGFloat totalWidth = self.fontSpriteSheet.textureWidth;
    CGFloat totalHeight = self.fontSpriteSheet.textureHeight;
    
    _textureCoordinates[0] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    _textureCoordinates[1] = (TextureCoord) { .s = ( (_offSetX+_width)/totalWidth),
        .t = ((_offSetY+_height)/totalHeight)};
    
    _textureCoordinates[2] = (TextureCoord) {  .s = ( (_offSetX+_width)/totalWidth), 
        .t = (_offSetY/totalHeight)};
    _textureCoordinates[3] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = (_offSetY/totalHeight)};
    
    _texureRect[0] = (Vector3D) { .x = 0, .y = 0, .z = 0};
    _texureRect[1] = (Vector3D) { .x = 0, .y = 0, .z = 0};
    _texureRect[2] = (Vector3D) { .x = 0, .y = 0, .z = 0};
    _texureRect[3] = (Vector3D) { .x = 0, .y = 0, .z = 0};
}

-(void)dealloc
{
    [super dealloc];
    self.fontSpriteSheet = nil;
    self.key = nil;
    free(_texureRect);
    free(_textureCoordinates);
}

@end

@implementation FontSpriteSheet

-(id)initWithType:(FontSpriteType)type andFontName:(NSString *)fontName andFontSize:(CGFloat)fontSize
{
    if (self = [super init])
    {
        fontSpriteDictionary = [[NSMutableDictionary alloc]init];
        self.fontSpriteType = type;
        
        
        if (type == FontSpriteTypeAlphabetsUppercase)
        {
            fontSpriteSheet = [[Texture2D alloc]
                                      initFontSpriteSheetWith:fontCharactersUpper
                                      andFontSprite:self];
        }
        else if (type == FontSpriteTypeAlphabetsUppercase)
        {
            fontSpriteSheet = [[Texture2D alloc]
                              initFontSpriteSheetWith:fontCharactersLower
                              andFontSprite:self];
        }
        else
        {
            fontSpriteSheet = [[Texture2D alloc]
                           initFontSpriteSheetWith:fontCharactersNumbers
                           andFontSprite:self];

        }
        
    }
    return self;

}



-(void)addFontSprite:(FontSprite *)fontSprite
{
    [fontSpriteDictionary setValue:fontSprite forKey:fontSprite.key];
    fontSprite.fontSpriteSheet = self;
}

-(void)dealloc
{
    [super dealloc];
    [fontSpriteSheet release];
    self.fontName = nil;
    self.fontColor = nil;
}




@end
