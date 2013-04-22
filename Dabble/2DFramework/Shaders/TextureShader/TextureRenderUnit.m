//
//  TextureRenderUnit.m
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TextureRenderUnit.h"
#import "GLShaderManager.h"

#define VBOLENGTH 5000

@implementation TextureRenderUnit

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


-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    
    for (int i = 0;i<ccount;i++)
    {
        memcpy( buffer,mvpMatrix, SIZE_MATRIX);
        buffer+=SIZE_MATRIX;
        memcpy(buffer,_cvertices+i, SIZE_VERTEX);
        buffer+=SIZE_VERTEX;
        memcpy(buffer,_ctextureCoordinates+i, SIZE_TEXCOORD);
        buffer+=SIZE_TEXCOORD;
        memcpy(buffer,&_ctextureColor, SIZE_COLOR);
        buffer+=SIZE_COLOR;
    }
    count+=ccount;
    
}

-(void)draw
{
    
    glBindBuffer(GL_ARRAY_BUFFER, vbos[currentVBO]);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
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
    
    glDrawArrays(GL_TRIANGLES, 0, count);
    
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_COLOR);
    glDisableVertexAttribArray(ATTRIB_MVPMATRIX + 0);
    glDisableVertexAttribArray(ATTRIB_MVPMATRIX + 1);
    glDisableVertexAttribArray(ATTRIB_MVPMATRIX + 2);
    glDisableVertexAttribArray(ATTRIB_MVPMATRIX + 3);
    glDisableVertexAttribArray(ATTRIB_TEXCOORD);
    
    currentVBO++;
    currentVBO%=VBO_COUNT;
}

-(void)dealloc
{
    [super dealloc];
    NSLog(@"deallocating texture render unit");
    glDeleteBuffers(VBO_COUNT, vbos);
//    self.texture = nil;
}

@end
