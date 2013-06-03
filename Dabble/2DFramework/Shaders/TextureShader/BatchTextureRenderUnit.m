//
//  TextureRenderUnit.m
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "BatchTextureRenderUnit.h"
#import "GLShaderManager.h"

#define VBOLENGTH 100000

@implementation BatchTextureRenderUnit

-(id)init
{
    if (self = [super init])
    {
        matrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        count = 0;
        _isFont = NO;
        
        currentVBO = 0;
        
        shader = [[GLShaderManager sharedGLShaderManager] getShaderByVertexShaderFileName:@"TextureShader"
                                      andFragmentShaderFileName:@"TextureShader"];
        
        [shader addAttribute:@"vertex"];
        [shader addAttribute:@"textureCoordinate"];
        [shader addAttribute:@"textureColor"];
        [shader addAttribute:@"mvpmatrix"];
        
        if (![shader link])
            NSLog(@"Link failed");
        
        
        ATTRIB_VERTEX = [shader attributeIndex:@"vertex"];
        ATTRIB_COLOR = [shader attributeIndex:@"textureColor"];
        ATTRIB_MVPMATRIX = [shader attributeIndex:@"mvpmatrix"];
        ATTRIB_TEXCOORD = [shader attributeIndex:@"textureCoordinate"];
        
        SIZE_MATRIX = sizeof(GLfloat) * 16;
        SIZE_COLOR = sizeof(Color4B);
        SIZE_VERTEX = sizeof(Vertex3D);
        SIZE_TEXCOORD = sizeof(TextureCoord);
        STRIDE = SIZE_MATRIX + SIZE_COLOR + SIZE_VERTEX + SIZE_TEXCOORD;
        
        dataBuffer = malloc(sizeof(TextureVertexData)*VBOLENGTH);
        
        [self setupVBO];
        
    }
    return self;
}

-(void)setupVBO
{
    glGenBuffers(1, &vbo);
    glGenVertexArraysOES(1, &vao);
    
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(TextureVertexData)*count, dataBuffer, GL_STREAM_DRAW);
    
   
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 0, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 1, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 2, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_MVPMATRIX + 3, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)48);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0, STRIDE, (GLvoid*)SIZE_MATRIX);
    
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, 0, STRIDE, (GLvoid*)(SIZE_MATRIX+SIZE_VERTEX));
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, STRIDE, (GLvoid*)(SIZE_MATRIX+SIZE_VERTEX+SIZE_TEXCOORD));

    glBindVertexArrayOES(0);
    
}

-(void)begin
{
    count = 0;
}


-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount
{
    
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
 
    for (int i = 0;i<ccount;i++)
    {
        memcpy(dataBuffer[count].mvpMatrix, mvpMatrix, SIZE_MATRIX);
        dataBuffer[count].vertex = _cvertices[i];
        dataBuffer[count].color = _ctextureColor;
        dataBuffer[count].texCoords = _ctextureCoordinates[i];
        count ++;
    }
}

-(void)addDefaultTextureCoordinatesWithColor:(Color4B)_ctextureColor
{
    [self addVertices:[_texture getTextureVertices] andTextureCoords:[_texture getTextureCoordinates] andColor:_ctextureColor andCount:6];
}


-(void)draw
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(TextureVertexData)*count, dataBuffer, GL_STREAM_DRAW);
    
    [shader use];
    
    if (_isFont)
    {
        glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    }
    else
    {
        glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    }
    
    
    glActiveTexture (GL_TEXTURE0);
    [_texture bindTexture];
    
    glBindVertexArrayOES(vao);
      
    glDrawArrays(GL_TRIANGLES, 0, count);
    
    glBindVertexArrayOES(0);
    
}

-(void)dealloc
{
    [super dealloc];
    NSLog(@"deallocating texture render unit");
    glDeleteBuffers(1, &vbo);
//    self.texture = nil;
}

@end
