//
//  TextureRenderUnit.h
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"
#import "TextureManager.h"
#import "FontSpriteSheetManager.h"
#import "MVPMatrixManager.h"
#import "GLShaderProgram.h"

#define VBO_COUNT 2

@interface TextureRenderUnit : NSObject
{
    GLShaderProgram *shader;
    
    MVPMatrixManager *matrixManager;
    GLuint vbos[VBO_COUNT];

    GLvoid *buffer;
    
    GLuint ATTRIB_COLORS;
    GLuint ATTRIB_VERTICES;
    GLuint ATTRIB_MVPMATRICES;
    GLuint ATTRIB_TEXCOORDS;
    
    int currentVBO;
    int count;
    
    size_t SIZE_MATRIX;
    size_t SIZE_VERTEX;
    size_t SIZE_TEXCOORDS;
    size_t SIZE_COLOR;
    size_t STRIDE;
    
}

@property (nonatomic,retain) Texture2D *texture;
@property (nonatomic) BOOL isFont;

-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount;
-(void)draw;
-(void)begin;

@end
