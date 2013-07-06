//
//  BatchRenderer.m
//  Dabble
//
//  Created by Rakesh on 06/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLRenderer.h"

@implementation GLRenderer

-(id)initWithVertexShader:(NSString *)vertexShaderName andFragmentShader:(NSString *)fragmentShaderName
{
    if (self = [super init])
    {
        UNIFORM_MVPMATRIX = -1;
        shaderManager = [GLShaderManager sharedGLShaderManager];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        program = [shaderManager getShaderByVertexShaderFileName:vertexShaderName andFragmentShaderFileName:fragmentShaderName];
        shaderType = program.shaderType;        
        glGenBuffers(1, &vbo);
        glGenVertexArraysOES(1, &vao);
        primitive = GL_TRIANGLES;
        
        switch (shaderType) {
            case ShaderAttributeMatrixVertexColor:
                [self setupMatrixVertexColorRenderer];
                break;
            case ShaderAttributeMatrixVertexColorTexture:
                [self setupMatrixVertexColorTextureRenderer];
                break;
            case ShaderAttributeVertexColor:
                [self setupVertexColorRenderer];
                break;
            case ShaderAttributeVertexColorTexture:
                [self setupVertexColorTextureRenderer];
                break;
            case ShaderAttributeVertexColorPointSize:
                [self setupVertexColorPointSizeRenderer];
                break;
            default:
                break;
        }
    }
    return self;
}

-(void)setupMatrixVertexColorRenderer
{
    ATTRIB_MVPMATRIX = [program attributeIndex:@"mvpmatrix"];
    ATTRIB_VERTEX = [program attributeIndex:@"vertex"];
    ATTRIB_COLOR = [program attributeIndex:@"color"];
    primitive = GL_TRIANGLES;
    
    glBindVertexArrayOES(vao);
    
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D));
    
    
    glBindVertexArrayOES(0);
}

-(void)setupMatrixVertexColorTextureRenderer
{
    ATTRIB_MVPMATRIX = [program attributeIndex:@"mvpmatrix"];
    ATTRIB_VERTEX = [program attributeIndex:@"vertex"];
    ATTRIB_COLOR = [program attributeIndex:@"textureColor"];
    ATTRIB_TEXTURECOORD = [program attributeIndex:@"textureCoordinate"];
    primitive = GL_TRIANGLES;
    
    glBindVertexArrayOES(vao);
    
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURECOORD);
    glVertexAttribPointer(ATTRIB_TEXTURECOORD, 2, GL_FLOAT, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(TextureCoord));
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D)+sizeof(TextureCoord));
    
    glBindVertexArrayOES(0);

}

-(void)setupVertexColorRenderer
{
    ATTRIB_VERTEX = [program attributeIndex:@"vertex"];
    ATTRIB_COLOR = [program attributeIndex:@"color"];
    UNIFORM_MVPMATRIX = [program uniformIndex:@"mvpmatrix"];
    primitive = GL_TRIANGLES;
    
    glBindVertexArrayOES(vao);
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(VertexColorData),0);
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(VertexColorData),
                          (GLvoid*)sizeof(Vertex3D));

    
    glBindVertexArrayOES(0);
}

-(void)setupVertexColorTextureRenderer
{
    ATTRIB_VERTEX = [program attributeIndex:@"vertex"];
    ATTRIB_COLOR = [program attributeIndex:@"textureColor"];
    ATTRIB_TEXTURECOORD = [program attributeIndex:@"textureCoordinate"];
    UNIFORM_MVPMATRIX = [program uniformIndex:@"mvpmatrix"];
    primitive = GL_TRIANGLES;
    
    glBindVertexArrayOES(vao);
    
    glEnableVertexAttribArray(ATTRIB_TEXTURECOORD);
    glVertexAttribPointer(ATTRIB_TEXTURECOORD, 2, GL_FLOAT, GL_TRUE,  sizeof(TextureVertexColorData),
                          0);
    
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(TextureVertexColorData),
                          (GLvoid*)sizeof(TextureCoord));
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(TextureVertexColorData),
                          (GLvoid*)sizeof(Vertex3D)+sizeof(TextureCoord));
    
     glBindVertexArrayOES(0);

}

-(void)setupVertexColorPointSizeRenderer
{
    UNIFORM_MVPMATRIX = [program attributeIndex:@"vertex"];
    ATTRIB_VERTEX = [program attributeIndex:@"vertex"];
    ATTRIB_COLOR = [program attributeIndex:@"color"];
    ATTRIB_POINTSIZE = [program attributeIndex:@"size"];
    primitive = GL_POINTS;
    
    glBindVertexArrayOES(vao);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(PointVertexColorSize),0);
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(PointVertexColorSize),
                          (GLvoid*)sizeof(Vertex3D));
    
    glEnableVertexAttribArray(ATTRIB_POINTSIZE);
    glVertexAttribPointer(ATTRIB_POINTSIZE, 1, GL_FLOAT, 0,  sizeof(PointVertexColorSize),
                          (GLvoid*)(sizeof(Vertex3D)+sizeof(Color4B)));
    
    glBindVertexArrayOES(0);
    
}

-(void)draw
{
    if (UNIFORM_MVPMATRIX >= 0)
    {
        Matrix3D result;
        [mvpMatrixManager getMVPMatrix:result];
        glUniformMatrix4fv(UNIFORM_MVPMATRIX, 1, GL_FALSE, result);
    }
    if (isTexture)
    {
        glEnable(GL_TEXTURE_2D);
        glBindVertexArrayOES(vao);
        glDrawArrays(primitive, 0, dataCount);
        glDisable(GL_TEXTURE_2D);
    }
    else
    {
        glBindVertexArrayOES(vao);
        glDrawArrays(primitive, 0, dataCount);
    }
}



@end
