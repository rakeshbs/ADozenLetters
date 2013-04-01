//
//  TextureShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 13/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "StringTextureShader.h"

@implementation StringTextureShader

@synthesize textureCoordinates,vertices,count,texture,textureColors,drawMode;


-(void)setCount:(int)_count
{
    count = _count;
    if (vertices != NULL)
    {
        free(vertices);
        free(textureColors);
        free(textureCoordinates);
    }
    
    vertices = malloc(sizeof(Vector3D)*count);
    textureColors = malloc(sizeof(Color4B)*count);
    textureCoordinates = malloc(sizeof(TextureCoord)*count);
}



-(id)init
{
    if (self = [super init])
    {
        shader = [shaderManager getShaderByVertexShaderFileName:@"StringTextureShader"
                                      andFragmentShaderFileName:@"StringTextureShader"];
        
        [shader addAttribute:@"vertices"];
        [shader addAttribute:@"textureCoordinates"];
        [shader addAttribute:@"textureColors"];
        
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertices"];
        textureCoordinatesAttribute = [shader attributeIndex:@"textureCoordinates"];
        textureColorsAttribute = [shader attributeIndex:@"textureColors"];
        
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        textureUniform = [shader uniformIndex:@"texture"];
       
    }
    return self;
}

-(void)draw
{
    glEnable(GL_TEXTURE_2D);
    
    [shader use];
    
    glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(verticesAttribute);
    
    glVertexAttribPointer(textureColorsAttribute, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, textureColors);
    glEnableVertexAttribArray(textureColorsAttribute);
    
    
    glVertexAttribPointer(textureCoordinatesAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(textureCoordinatesAttribute);
    
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    glUniformMatrix4fv(mvpMatrixUniform, 1, FALSE, mvpMatrix);
    
    
    glActiveTexture (GL_TEXTURE0);
    [texture bindTexture];
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(drawMode, 0, count);
    
    glDisable(GL_TEXTURE_2D);
}


@end
