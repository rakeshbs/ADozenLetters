//
//  BatchRenderer.h
//  Dabble
//
//  Created by Rakesh on 06/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLShaderManager.h"
#import "GLCommon.h"
#import "MVPMatrixManager.h"

@interface GLRenderer : NSObject
{
    GLint UNIFORM_MVPMATRIX;
    
    GLuint ATTRIB_VERTEX;
    GLuint ATTRIB_COLOR;
    GLuint ATTRIB_POINTSIZE;
    GLuint ATTRIB_MVPMATRIX;
    GLuint ATTRIB_TEXTURECOORD;
    
    GLShaderManager *shaderManager;
    MVPMatrixManager *mvpMatrixManager;
    GLShaderProgram *program;
    
    ShaderAttributeTypes shaderType;
    
    int dataCount;
    
    GLuint vbo,vao;
    
    GLenum primitive;
    
    bool isTexture;
}

-(id)initWithVertexShader:(NSString *)vertexShaderName andFragmentShader:(NSString *)fragmentShaderName;
@end
