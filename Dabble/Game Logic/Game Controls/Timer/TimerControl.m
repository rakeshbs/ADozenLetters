//
//  TimerControl.m
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TimerControl.h"

@implementation TimerControl

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        textureShaderProgram = [shaderManager getShaderByVertexShaderFileName:@"InstancedTextureShader" andFragmentShaderFileName:@"TextureShader"];
        
        
        ATTRIB_TEXTURE_MVPMATRIX = [textureShaderProgram attributeIndex:@"mvpmatrix"];
        ATTRIB_TEXTURE_VERTEX = [textureShaderProgram attributeIndex:@"vertex"];
        ATTRIB_TEXTURE_COLOR = [textureShaderProgram attributeIndex:@"textureColor"];
        ATTRIB_TEXTURE_TEXCOORDS = [textureShaderProgram attributeIndex:@"textureCoordinate"];
        glGenBuffers(1, &textureBuffer);
        

    }
    return self;
}

-(void)setTimeLeft:(CGFloat)time
{
    timeLeft = time;
}

-(void)draw
{
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    [textureShaderProgram use];
    
    glBindBuffer(GL_ARRAY_BUFFER, textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexDataCount * sizeof(InstancedTextureVertexColorData), vertexData, GL_DYNAMIC_DRAW);
    [fontSpriteSheet.texture bindTexture];
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_TEXCOORDS);
    glVertexAttribPointer(ATTRIB_TEXTURE_TEXCOORDS, 2, GL_FLOAT, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTURE_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(TextureCoord));
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_COLOR);
    glVertexAttribPointer(ATTRIB_TEXTURE_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D)+sizeof(TextureCoord));
    
    
    glDrawArrays(GL_TRIANGLES, 0, vertexDataCount);
    
    [mvpMatrixManager popModelViewMatrix];
    
    glDisable(GL_TEXTURE_2D);

}

@end
