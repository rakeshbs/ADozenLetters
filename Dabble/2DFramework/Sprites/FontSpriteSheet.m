//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FontSpriteSheet.h"
#import "Texture2D.h"

static NSString *fontCharactersUpper = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static NSString *fontCharactersLower = @"abcdefghijklmnopqrstuvwxvz";
static NSString *fontCharactersNumbers = @"1234567890";

@implementation FontSprite



-(void)calculateCoordinates
{
    _textureCoordinates = malloc(sizeof(TextureCoord)*6);
    _texureRect = malloc(sizeof(Vector3D)*6);
    
    CGFloat totalWidth = self.fontSpriteSheet.width;
    CGFloat totalHeight = self.fontSpriteSheet.height;
    
    _textureCoordinates[0] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    _textureCoordinates[1] = (TextureCoord) { .s = ( (_offSetX+_width)/totalWidth),
        .t = ((_offSetY+_height)/totalHeight)};
    
    _textureCoordinates[2] = (TextureCoord) {  .s = ( (_offSetX+_width)/totalWidth),
        .t = (_offSetY/totalHeight)};
    
    _textureCoordinates[3] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = ((_offSetY+_height)/totalHeight)};
    _textureCoordinates[4] = (TextureCoord) { .s = (_offSetX/totalWidth), .t = (_offSetY/totalHeight)};
    _textureCoordinates[5] = (TextureCoord) {  .s = ( (_offSetX+_width)/totalWidth),
        .t = (_offSetY/totalHeight)};
    
    
    /*
     
     textureCoordinates[0] = (TextureCoord) { .s = 0, .t = _maxT};
     textureCoordinates[1] = (TextureCoord) { .s = _maxS, .t =_maxT};
     textureCoordinates[2] = (TextureCoord) { .s = _maxS, .t = 0};
     
     textureCoordinates[3] = (TextureCoord) { .s = 0, .t = _maxT};
     textureCoordinates[4] = (TextureCoord) { .s = 0, .t = 0};
     textureCoordinates[5] = (TextureCoord) { .s = _maxS, .t = 0};
     
     
     textureVertices[0] = (Vector3D) {.x = -width / (2*scale) , .y = -height / (2*scale), .z = 0.0};
     textureVertices[1] = (Vector3D) {.x = width / (2*scale) , .y = -height / (2*scale),  .z = 0.0};
     textureVertices[2] = (Vector3D) {.x = width / (2*scale) , .y = height / (2*scale),	.z = 0.0};
     
     textureVertices[3] = (Vector3D) {.x = -width / (2*scale) , .y = -height / (2*scale), .z = 0.0};
     textureVertices[4] = (Vector3D) {.x = -width / (2*scale) , .y = height / (2*scale),	.z = 0.0};
     textureVertices[5] = (Vector3D) {.x = width / (2*scale) , .y = height / (2*scale),	.z = 0.0};
     
     */
    
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    _texureRect[0] = (Vector3D) { .x = -_width/scale, .y = -_height/scale, .z = 0.0};
    _texureRect[1] = (Vector3D) { .x = _width/scale, .y = -_height/scale, .z = 0.0};
    _texureRect[2] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
    _texureRect[3] = (Vector3D) { .x = -_width/scale, .y = -_height/scale, .z = 0.0};
    _texureRect[4] = (Vector3D) { .x = -_width/scale, .y = _height/scale, .z = 0.0};
    _texureRect[5] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
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
