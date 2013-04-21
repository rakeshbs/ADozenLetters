//
//  ColorShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ColorRenderer.h"

#define VBOLENGTH 5000

@implementation ColorRenderer
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
        
        [self setupVBO];
    }
    return self;
}

-(void)setupVBO
{
    glGenBuffers(VBO_COUNT, vbos);
    for (int i = 0;i<VBO_COUNT;i++)
    {
        glBindBuffer(GL_ARRAY_BUFFER, vbos[i]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*VBOLENGTH, NULL, GL_STREAM_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
}

-(void)begin
{
    count = 0;
    glBindBuffer(GL_ARRAY_BUFFER, vbos[currentVBO]);
    buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)addVertices:(Vertex3D *)_vertices withColorsPerVertex:(Color4B *)_colors andCount:(int)_count
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    
    for (int i = 0;i<_count;i++)
    {
        memcpy( buffer,mvpMatrix, SIZE_MATRIX);
        buffer+=SIZE_MATRIX;
        memcpy(buffer,_vertices+i, SIZE_VERTEX);
        buffer+=SIZE_VERTEX;
        memcpy(buffer,_colors+i, SIZE_COLOR);
        buffer+=SIZE_COLOR;

    }
    count+=_count;
}

-(void)addVertices:(Vertex3D *)_vertices withUniformColor:(Color4B)_color andCount:(int)_count
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    
    for (int i = 0;i<_count;i++)
    {
        memcpy( buffer,mvpMatrix, SIZE_MATRIX);
        buffer+=SIZE_MATRIX;
        memcpy(buffer,_vertices+i, SIZE_VERTEX);
        buffer+=SIZE_VERTEX;
        memcpy(buffer,&_color, SIZE_COLOR);
        buffer+=SIZE_COLOR;
    }
    count+=_count;
}

-(void)end
{

    [self draw];
}

-(void)draw
{
    glBindBuffer(GL_ARRAY_BUFFER, vbos[currentVBO]);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    [shader use];
    
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
    
    glDrawArrays(GL_TRIANGLES, 0, count);
    
    glDisableVertexAttribArray(ATTRIB_VERTICES);
    glDisableVertexAttribArray(ATTRIB_COLORS);
    glDisableVertexAttribArray(ATTRIB_MVPMATRICES + 0);
    glDisableVertexAttribArray(ATTRIB_MVPMATRICES + 1);
    glDisableVertexAttribArray(ATTRIB_MVPMATRICES + 2);
    glDisableVertexAttribArray(ATTRIB_MVPMATRICES + 3);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    currentVBO++;
    currentVBO = currentVBO % VBO_COUNT;
   
}

-(void)dealloc
{
    [super dealloc];
        NSLog(@"deallocating color renderer");

    glDeleteBuffers(VBO_COUNT, vbos);
    
}


@end
