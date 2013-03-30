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

@interface FlatColorShader : GLShader
{
    Color4f color;
    Vector3D *vertices;
    GLShaderProgram *shader;
    
    GLuint colorUniform;
    GLuint verticesAttribute;
    GLuint mvpMatrixUniform;
    GLenum drawMode;
    int count;
    CGFloat pointSize;
    
}
@property (nonatomic)    CGFloat pointSize;
@property (nonatomic)     GLenum drawMode;
@property (nonatomic) Color4f color;
@property (nonatomic) Vector3D *vertices;
@property (nonatomic) int count;

@end
