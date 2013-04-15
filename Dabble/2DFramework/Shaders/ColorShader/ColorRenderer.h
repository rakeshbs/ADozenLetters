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
#import "GLRenderer.h"

@interface ColorRenderer : GLRenderer
{
    Color4B *colors;
    Vector3D *vertices;
    GLfloat *matrixIndices;
    int mvpMatrixCount;
    GLShaderProgram *shader;
    
    GLfloat *mvpMatrices;
    
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

-(void)addMatrix;
-(void)begin;
-(void)end;
-(void)addVertices:(Vertex3D *)_vertices withColorsPerVertex:(Color4B *)_colors andCount:(int)_count;
-(void)addVertices:(Vertex3D *)_vertices withUniformColor:(Color4B)_color andCount:(int)_count;
@end
