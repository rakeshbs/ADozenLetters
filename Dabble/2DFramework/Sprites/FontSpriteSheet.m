//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "FontSpriteSheet.h"
#import "Texture2D.h"

static NSString *fontCharactersUpper = @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
static NSString *fontCharactersLower = @"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,v,z";
static NSString *fontCharactersNumbers = @"0,1,2,3,4,5,6,7,8,9";

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
    
    self.textureCoordinatesCGRect = CGRectMake(_offSetX/totalWidth, _offSetY/totalHeight, _width/totalWidth, _height/totalHeight);
    
    
    CGFloat scale = [[UIScreen mainScreen]scale]*2;
    
    _textureRect[0] = (Vector3D) { .x = -_width/scale, .y = -_height/scale, .z = 0.0};
    _textureRect[1] = (Vector3D) { .x = _width/scale, .y = -_height/scale, .z = 0.0};
    _textureRect[2] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
    _textureRect[3] = (Vector3D) { .x = -_width/scale, .y =   -_height/scale, .z = 0.0};
    _textureRect[4] = (Vector3D) { .x = -_width/scale, .y = _height/scale, .z = 0.0};
    _textureRect[5] = (Vector3D) { .x = _width/scale, .y = _height/scale, .z = 0.0};
    
    self.textureCGRect = CGRectMake(-_width/scale, -_height/scale, 2*_width/scale , 2 * _height/scale);
    
}

-(void)dealloc
{

    self.fontSpriteSheet = nil;
    self.key = nil;
    free(_textureRect);
    
    free(_textureCoordinates);
    [super dealloc];
}

@end

@implementation FontSpriteSheet

@synthesize texture,fontSpriteDictionary;

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

    [texture release];
    self.fontName = nil;
    self.fontColor = nil;
    [super dealloc];
}




@end
