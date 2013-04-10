//
//  ColorShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ColorShader.h"

#define NUMBEROFMATRICES 50
#define NUMBEROFVERTICES 1000

@implementation ColorShader
@synthesize colors,vertices,drawMode,count;

-(id)init
{
    if (self = [super init])
    {
        mvpMatrixCount = 0;
        shader = [shaderManager getShaderByVertexShaderFileName:@"ColorShader"
                                      andFragmentShaderFileName:@"ColorShader"];
        
        [shader addAttribute:@"vertex"];
        [shader addAttribute:@"color"];        
        [shader addAttribute:@"mvpmatrixIndex"];
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertex"];
        colorAttribute = [shader attributeIndex:@"color"];
        mvpmatrixIndexAttribute = [shader attributeIndex:@"mvpmatrixIndex"];
        
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        
        mvpMatrices = malloc(NUMBEROFMATRICES * sizeof(GLfloat)*16);
        memset(mvpMatrices, 0, sizeof(GLfloat)*16);
        vertices = malloc(sizeof(Vector3D)*NUMBEROFVERTICES);
        colors = malloc(sizeof(Color4B)*NUMBEROFVERTICES);
        matrixIndices = malloc(sizeof(GLubyte)*NUMBEROFVERTICES);
    }
    return self;
}

-(void)begin
{
    count = 0;
    mvpMatrixCount = 0;
}

-(void)addMatrix
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    int ind = mvpMatrixCount*16;
    Matrix3DCopyS(mvpMatrix, (mvpMatrices+ind));
    mvpMatrixCount++;
}

-(void)addVertices:(Vertex3D *)_vertices withColorsPerVertex:(Color4B *)_colors andCount:(int)_count
{
    memccpy(vertices+count,_vertices, 0, _count*sizeof(Vertex3D));
    memccpy(colors+count,_colors, 0, _count*sizeof(Color4B));
    for (int i = 0;i<_count;i++)
        *(matrixIndices+count+i) = mvpMatrixCount-1;
    count+=_count;
}

-(void)addVertices:(Vertex3D *)_vertices withUniformColor:(Color4B)_color andCount:(int)_count
{
    for (int i = 0;i<_count;i++)
    {
        *(vertices+count+i) = _vertices[i];
        *(matrixIndices+count+i) = mvpMatrixCount-1;
        *(colors+count+i) = _color;
    }
    count+=_count;
}

-(void)end
{
    [self draw];
}

-(void)draw
{
    [shader use];
    
    glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(verticesAttribute);
    
    glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, colors);
    glEnableVertexAttribArray(colorAttribute);
    
    glVertexAttribPointer(mvpmatrixIndexAttribute, 1, GL_FLOAT, GL_FALSE, 0, matrixIndices);
    glEnableVertexAttribArray(mvpmatrixIndexAttribute);
    
    glUniformMatrix4fv(mvpMatrixUniform, mvpMatrixCount, GL_FALSE, mvpMatrices);
    
    glDrawArrays(GL_TRIANGLES, 0, count);
   
}


@end
