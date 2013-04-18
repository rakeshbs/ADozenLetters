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
        shader = [shaderManager getShaderByVertexShaderFileName:@"TextureShader"
                                      andFragmentShaderFileName:@"TextureShader"];
        
        [shader addAttribute:@"vertices"];
        [shader addAttribute:@"textureCoordinates"];
        [shader addAttribute:@"textureColors"];
        [shader addAttribute:@"mvpmatrixIndex"];
        
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertices"];
        textureCoordinatesAttribute = [shader attributeIndex:@"textureCoordinates"];
        textureColorsAttribute = [shader attributeIndex:@"textureColors"];
        mvpmatrixIndexAttribute = [shader attributeIndex:@"mvpmatrixIndex"];
        
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        textureUniform = [shader uniformIndex:@"texture"];
        
        textureRenderUnits = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}

-(void)setFontSprite:(FontSprite *)_fontSprite
{
    NSString *key = [NSString stringWithFormat:@"%d",_fontSprite.fontSpriteSheet.texture.name];
    TextureRenderUnit *renderUnit = [textureRenderUnits valueForKey:key];
    if (renderUnit == nil)
    {
       renderUnit = [[TextureRenderUnit alloc]init];
        renderUnit.texture = _fontSprite.fontSpriteSheet.texture;
        [textureRenderUnits setObject:renderUnit forKey:key];
        [renderUnit release];
    }
    isFontSprite = YES;
    currentTextureCoordinates = _fontSprite.textureCoordinates;
    currentRenderUnit = renderUnit;
    currentRenderUnit.isFont = YES;
}

-(void)setTexture:(Texture2D *)_texture
{
    NSString *key = [NSString stringWithFormat:@"%d",_texture.name];
    TextureRenderUnit *renderUnit = [textureRenderUnits valueForKey:key];
    if (renderUnit == nil)
    {
        renderUnit = [[TextureRenderUnit alloc]init];
        renderUnit.texture = _texture;
        [textureRenderUnits setObject:renderUnit forKey:key];
        [renderUnit release];
    }
    isFontSprite = NO;

    currentTextureCoordinates = [_texture getTextureCoordinates];
    currentRenderUnit = renderUnit;
    currentRenderUnit.isFont = NO;
}

-(void)addMatrix
{
    [currentRenderUnit addMatrix];
}

-(void)addVertices:(Vertex3D *)_vertices andColor:(Color4B)_textureColor andCount:(int)count
{
    [currentRenderUnit addVertices:_vertices andTextureCoords:currentTextureCoordinates
                          andColor:_textureColor andCount:count];
}

-(void)begin
{
    for (TextureRenderUnit *renderUnit in [textureRenderUnits objectEnumerator])
    {
        renderUnit.count = 0;
        renderUnit.mvpMatrixCount = 0;
    }
}

-(void)end
{
   [self draw];
}

-(void)draw
{
    
    glEnable(GL_TEXTURE_2D);
    
    [shader use];
    
    for (TextureRenderUnit *renderUnit in [textureRenderUnits objectEnumerator])
    {
        if (renderUnit.isFont)
        {
            glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
        }
        else
        {
            glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        }
        
        glActiveTexture (GL_TEXTURE0);
        [renderUnit.texture bindTexture];
    
        glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, 0, 0, renderUnit.vertices);
        glEnableVertexAttribArray(verticesAttribute);
    
        glVertexAttribPointer(textureColorsAttribute, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, renderUnit.textureColors);
        glEnableVertexAttribArray(textureColorsAttribute);
    
    
        glVertexAttribPointer(textureCoordinatesAttribute, 2, GL_FLOAT, 0, 0, renderUnit.textureCoordinates);
        glEnableVertexAttribArray(textureCoordinatesAttribute);
    
        glUniformMatrix4fv(mvpMatrixUniform, renderUnit.mvpMatrixCount, FALSE, renderUnit.mvpMatrices);
    
        glVertexAttribPointer(mvpmatrixIndexAttribute, 1, GL_FLOAT, GL_FALSE, 0, renderUnit.matrixIndices);
        glEnableVertexAttribArray(mvpmatrixIndexAttribute);
    
        glUniform1i (textureUniform, 0);
        
        glDrawArrays(GL_TRIANGLES, 0, renderUnit.count);
    }
    
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_TEXTURE_2D);
     
}

-(void)dealloc
{
    [super dealloc];
    [textureRenderUnits release];
}


@end