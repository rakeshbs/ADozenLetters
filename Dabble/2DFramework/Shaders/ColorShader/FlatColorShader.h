//
//  ColorShader.h
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLShaderProgram.h"
#import "GLCommon.h"
#import "MVPMatrixManager.h"
#import "GLShaderManager.h"
#import "GLShader.h"

@interface ColorShader : GLShader
{
    Color4f *colors;
    Vector3D *vertices;
    GLShaderProgram *shader;
    
    GLuint colorAttribute;
    GLuint verticesAttribute;
    GLuint mvpMatrixUniform;
    GLenum drawMode;
    int count;
    
}
 
@property (nonatomic)     GLenum drawMode;
@property (nonatomic) Color4f *colors;
@property (nonatomic) Vector3D *vertices;
@property (nonatomic) int count;

@end
