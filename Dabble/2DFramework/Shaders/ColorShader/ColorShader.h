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
    Color4B *colors;
    Vector3D *vertices;
    GLfloat *matrixIndices;
    GLfloat mvpMatrixCount;
    GLShaderProgram *shader;
    
    Matrix3D *mvpMatrices;
    
    GLuint colorAttribute;
    GLuint verticesAttribute;
    GLuint mvpMatrixUniform;
    GLuint mvpmatrixIndexAttribute;
    GLenum drawMode;
    int count;
    
}
@property (nonatomic)    CGFloat pointSize;
@property (nonatomic)     GLenum drawMode;
@property (nonatomic) Color4B *colors;
@property (nonatomic) Vector3D *vertices;
@property (nonatomic) int count;

-(void)begin;
-(void)end;

@end
