//
//  TextureShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 13/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TextureRenderer.h"


@implementation TextureRenderer

-(id)init
{
    if (self = [super init])
    {
        textureRenderUnits = [[NSMutableArray alloc]init];
        
        SIZE_MATRIX = sizeof(GLfloat) * 16;
        SIZE_COLOR = sizeof(Color4B);
        SIZE_VERTEX = sizeof(Vertex3D);
        SIZE_TEXCOORDS = sizeof(TextureCoord);
        STRIDE = SIZE_MATRIX + SIZE_COLOR + SIZE_VERTEX + SIZE_TEXCOORDS;
        
    }
    return self;
}

-(void)setFontSprite:(FontSprite *)_fontSprite
{
    if (_fontSprite.fontSpriteSheet.renderUnit == nil)
    {
       TextureRenderUnit *renderUnit = [[TextureRenderUnit alloc]init];
        renderUnit.texture = _fontSprite.fontSpriteSheet.texture;
        _fontSprite.fontSpriteSheet.renderUnit = renderUnit;
        [textureRenderUnits addObject:renderUnit];
        [renderUnit begin];
        [renderUnit release];
    }
    isFontSprite = YES;
    currentTextureCoordinates = _fontSprite.textureCoordinates;
    currentRenderUnit = _fontSprite.fontSpriteSheet.renderUnit;
    currentRenderUnit.isFont = YES;
}

-(void)setTexture:(Texture2D *)_texture
{
    if (_texture.renderUnit == nil)
    {
        TextureRenderUnit *renderUnit = [[TextureRenderUnit alloc]init];
        renderUnit.texture = _texture;
        _texture.renderUnit = renderUnit;
        [textureRenderUnits addObject:renderUnit];
        [renderUnit begin];
       [renderUnit release];
    }
    isFontSprite = NO;
    currentTextureCoordinates = [_texture getTextureCoordinates];
    currentRenderUnit = _texture.renderUnit;
    currentRenderUnit.isFont = NO;
}

-(TextureRenderUnit *)getNewTextureRenderUnit
{
    TextureRenderUnit *renderUnit = [[TextureRenderUnit alloc]init];
    [textureRenderUnits addObject:renderUnit];
    [renderUnit begin];
    [renderUnit release];
    return renderUnit;
}

-(void)addVertices:(Vertex3D *)_vertices andColor:(Color4B)_textureColor andCount:(int)count
{
    [currentRenderUnit addVertices:_vertices andTextureCoords:currentTextureCoordinates andColor:_textureColor andCount:count];
}

-(void)begin
{
    for (TextureRenderUnit *renderUnit in textureRenderUnits)
    {
        [renderUnit begin];
    }
}

-(void)end
{
   [self draw];
}

-(void)draw
{
    
    glEnable(GL_TEXTURE_2D);
    
    for (TextureRenderUnit *renderUnit in textureRenderUnits)
    {
        [renderUnit draw];
    }
    
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_TEXTURE_2D);
     
}

-(void)dealloc
{
    [super dealloc];
    NSLog(@"deallocation texture renderer");
    [textureRenderUnits release];
}


@end
