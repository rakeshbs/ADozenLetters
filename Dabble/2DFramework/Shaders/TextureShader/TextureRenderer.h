//
//  TextureShader.h
//  OpenGLES2.0
//
//  Created by Rakesh on 13/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLShaderProgram.h"
#import "GLCommon.h"
#import "MVPMatrixManager.h"
#import "GLShaderManager.h"
#import "GLRenderer.h"
#import "Texture2D.h"
#import "TextureRenderUnit.h"

@interface TextureRenderer : GLRenderer
{
    GLShaderProgram *shader;
    
    GLuint textureCoordinatesAttribute;
    GLuint verticesAttribute;
    
    GLuint mvpMatrixUniform;
    GLuint textureColorsAttribute;
    GLuint textureUniform;
    GLuint mvpmatrixIndexAttribute;
    
    NSMutableDictionary *textureRenderUnits;
    TextureRenderUnit *currentRenderUnit;
    
    BOOL isFontSprite;
    TextureCoord *currentTextureCoordinates;
}

-(void)addVertices:(Vertex3D *)_vertices andColor:(Color4B)_textureColor andCount:(int)count;
-(void)addMatrix;
-(void)setTexture:(Texture2D *)_texture;
-(void)begin;
-(void)end;
-(void)setFontSprite:(FontSprite *)_fontSprite;
@end
