//
//  TextureShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 13/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TextureShader.h"

@implementation TextureShader

@synthesize textureCoordinates,vertices,drawMode,count,texture,textureColor;

-(id)init
{
    if (self = [super init])
    {
        shader = [shaderManager getShaderByVertexShaderFileName:@"TextureShader"
                                      andFragmentShaderFileName:@"TextureShader"];
        
        [shader addAttribute:@"vertices"];
        [shader addAttribute:@"textureCoordinates"];
        
        if (![shader link])
            NSLog(@"Link failed");
        
        verticesAttribute = [shader attributeIndex:@"vertices"];

        textureCoordinatesAttribute = [shader attributeIndex:@"textureCoordinates"];
        mvpMatrixUniform = [shader uniformIndex:@"mvpmatrix"];
        textureUniform = [shader uniformIndex:@"texture"];
        textureColorUniform = [shader uniformIndex:@"textureColor"];
    }
    return self;
}

-(void)draw
{
    glEnable(GL_TEXTURE_2D);
    
    [shader use];
    
    glVertexAttribPointer(verticesAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(verticesAttribute);
    
    glVertexAttribPointer(textureCoordinatesAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(textureCoordinatesAttribute);
    
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    glUniformMatrix4fv(mvpMatrixUniform, 1, FALSE, mvpMatrix);
    
    glUniform4f(textureColorUniform, textureColor->red, textureColor->green, textureColor->blue, textureColor->alpha);
    
    glActiveTexture (GL_TEXTURE0);
    [texture bindTexture];
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(drawMode, 0, count);
    
    glDisable(GL_TEXTURE_2D);
}


@end
