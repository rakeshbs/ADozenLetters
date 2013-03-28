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
#import "GLShader.h"
#import "Texture2D.h"


@interface TextureShader : GLShader
{
    Vector3D *vertices;
    TextureCoord *textureCoordinates;
    Texture2D *texture;
    Color4f *textureColor;
    
    GLShaderProgram *shader;
    
    GLuint textureCoordinatesAttribute;
    GLuint verticesAttribute;
    
    GLuint mvpMatrixUniform;
    GLuint textureColorUniform;
    GLuint textureUniform;
    
    GLenum drawMode;
    int count;
    
}

@property (nonatomic) GLenum drawMode;
@property (nonatomic) TextureCoord *textureCoordinates;
@property (nonatomic) Color4f *textureColor;
@property (nonatomic) Vector3D *vertices;
@property (nonatomic) int count;
@property (nonatomic,retain) Texture2D *texture;

@end
