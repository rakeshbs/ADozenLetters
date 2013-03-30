//
//  ColorShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 07/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "FlatColorShader.h"

@implementation FlatColorShader
@synthesize color,vertices,drawMode,count,pointSize;

-(id)init
{
    if (self = [super init])
    {
        shader = [shaderManager getShaderByVertexShaderFileName:@"FlatColorShader"
                                      andFragmentShaderFileName:@"FlatColorShader"];
        
        [shader addAttribute:@"vertices"];
        
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertices"];
        colorUniform = [shader uniformIndex:@"color"];
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        
}
    return self;
}

-(void)draw
{
    [shader use];
    
    glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(verticesAttribute);
    
    glUniform4f(colorUniform, color.red, color.green, color.blue, color.alpha);
    
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    glUniformMatrix4fv(mvpMatrixUniform, 1, FALSE, mvpMatrix);
    
    glDrawArrays(drawMode, 0, count);
   
}


@end
