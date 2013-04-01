//
//  ColorShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ColorShader.h"

@implementation ColorShader
@synthesize colors,vertices,drawMode,count;

-(void)setCount:(int)_count
{
    count = _count;
    if (vertices != NULL)
    {
        free(vertices);
        free(colors);
    }
    
    vertices = malloc(sizeof(Vector3D)*count);
    colors = malloc(sizeof(Color4B)*count);
}

-(id)init
{
    if (self = [super init])
    {
        shader = [shaderManager getShaderByVertexShaderFileName:@"ColorShader"
                                      andFragmentShaderFileName:@"ColorShader"];
        
        [shader addAttribute:@"vertex"];
        [shader addAttribute:@"color"];        
        
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertex"];
        colorAttribute = [shader attributeIndex:@"color"];
        
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        
}
    return self;
}

-(void)draw
{
    [shader use];
    
    glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(verticesAttribute);
    
    glVertexAttribPointer(colorAttribute, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, colors);
    glEnableVertexAttribArray(colorAttribute);
    
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    glUniformMatrix4fv(mvpMatrixUniform, 1, FALSE, mvpMatrix);
    
    glDrawArrays(drawMode, 0, count);
   
}


@end
