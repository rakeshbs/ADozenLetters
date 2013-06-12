//
//  ColorShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "BatchColorRenderer.h"

#define VBOLENGTH 10000

@implementation ColorVertexLayer

@end

@implementation BatchColorRenderer
@synthesize DRAW_MODE;


-(id)init
{
    if (self = [super init])
    {
        shader = [shaderManager getShaderByVertexShaderFileName:@"ColorShader"
                                      andFragmentShaderFileName:@"ColorShader"];
        
        [shader addAttribute:@"vertex"];
        [shader addAttribute:@"color"];        
        [shader addAttribute:@"mvpmatrix"];
    
        if (![shader link])
            NSLog(@"Link failed");
        
        ATTRIB_VERTICES = [shader attributeIndex:@"vertex"];
        ATTRIB_COLORS = [shader attributeIndex:@"color"];
        ATTRIB_MVPMATRICES = [shader attributeIndex:@"mvpmatrix"];
         
        SIZE_MATRIX = sizeof(GLfloat) * 16;
        SIZE_COLOR = sizeof(Color4B);
        SIZE_VERTEX = sizeof(Vertex3D);
        STRIDE = SIZE_MATRIX + SIZE_COLOR + SIZE_VERTEX;
        
        currentVBO = 0;
        
        DRAW_MODE = GL_TRIANGLES;
        
        dataBuffer = malloc(sizeof(ColorVertexData) * VBOLENGTH);
     //   [self setupVBO];
    }
    return self;
}



-(void)setupVBO
{
    glGenBuffers(1, &vbo);
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(ColorVertexData), dataBuffer, GL_STREAM_DRAW);
    
    
    glEnableVertexAttribArray(ATTRIB_MVPMATRICES + 0);
    glEnableVertexAttribArray(ATTRIB_MVPMATRICES + 1);
    glEnableVertexAttribArray(ATTRIB_MVPMATRICES + 2);
    glEnableVertexAttribArray(ATTRIB_MVPMATRICES + 3);
    
    glVertexAttribPointer(ATTRIB_MVPMATRICES + 0, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_MVPMATRICES + 1, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_MVPMATRICES + 2, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_MVPMATRICES + 3, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_VERTICES);
    glVertexAttribPointer(ATTRIB_VERTICES, 3, GL_FLOAT, 0, STRIDE, (GLvoid*)SIZE_MATRIX);
    glEnableVertexAttribArray(ATTRIB_COLORS);
    glVertexAttribPointer(ATTRIB_COLORS, 4, GL_UNSIGNED_BYTE, GL_TRUE, STRIDE, (GLvoid*)(SIZE_MATRIX+SIZE_VERTEX));
    
    glBindVertexArrayOES(0);
}

-(void)begin
{
    count = 0;
}

-(void)addVertices:(Vertex3D *)_vertices withColorsPerVertex:(Color4B *)_colors andCount:(int)_count
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];

    for (int i = 0;i<_count;i++)
    {
        Matrix3DCopyS(mvpMatrix, dataBuffer[count].mvpMatrix);
        dataBuffer[count].vertex = _vertices[i];
        dataBuffer[count].color = _colors[i];
        count ++;
    }
}

-(void)addVertices:(Vertex3D *)_vertices withUniformColor:(Color4B)_color andCount:(int)_count
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];

    for (int i = 0;i<_count;i++)
    {
        memcpy(dataBuffer[count].mvpMatrix, mvpMatrix, SIZE_MATRIX);
        dataBuffer[count].vertex = _vertices[i];
        dataBuffer[count].color = _color;
        count ++;
    }
 
}

-(void)end
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(ColorVertexData), dataBuffer, GL_STREAM_DRAW);
    
    
    [self draw];
}

-(void)draw
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    [shader use];
    
    glBindVertexArrayOES(vao);
    
    glDrawArrays(DRAW_MODE, 0, count);
       
}

-(void)dealloc
{
    [super dealloc];
        NSLog(@"deallocating color renderer");

    glDeleteBuffers(1,&vbo);
    
}


@end
