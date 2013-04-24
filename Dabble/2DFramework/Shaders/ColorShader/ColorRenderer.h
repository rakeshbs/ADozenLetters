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

#define VBO_COUNT 1

typedef struct
{
    Matrix3D mvpMatrix;
    Vector3D vertex;
    Color4B color;
    
} ColorVertexData;

@interface ColorVertexLayer : NSObject
{
    ColorVertexData *data;
    int count;
}
@end


@interface ColorRenderer : GLRenderer
{
    GLShaderProgram *shader;
    
    GLuint vao;
    GLuint vbos[VBO_COUNT];
    GLvoid *buffer;
    
    GLuint ATTRIB_COLORS;
    GLuint ATTRIB_VERTICES;
    GLuint ATTRIB_MVPMATRICES;
    GLenum DRAW_MODE;
    
    int count;
    
    size_t SIZE_MATRIX;
    size_t SIZE_VERTEX;
    size_t SIZE_COLOR;
    size_t STRIDE;
    
    ColorVertexData *dataBuffer;
    NSMutableArray *layers;
    
    int  countDataBuffer;
    
    int currentVBO;
}
@property (nonatomic)    CGFloat pointSize;
@property (nonatomic)     GLenum DRAW_MODE;

-(void)begin;
-(void)end;
-(void)addVertices:(Vertex3D *)_vertices withColorsPerVertex:(Color4B *)_colors andCount:(int)_count;
-(void)addVertices:(Vertex3D *)_vertices withUniformColor:(Color4B)_color andCount:(int)_count;
@end
