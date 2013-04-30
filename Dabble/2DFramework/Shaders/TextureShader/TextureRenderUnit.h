//
//  TextureRenderUnit.h
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"
#import "NEONMatrix.h"
#import "TextureManager.h"
#import "FontSpriteSheetManager.h"
#import "MVPMatrixManager.h"
#import "GLShaderProgram.h"

typedef struct
{
    Matrix3D mvpMatrix;
    Vertex3D vertex;
    TextureCoord texCoords;
    Color4B color;
    
} TextureVertexData;


@interface TextureRenderUnit : NSObject
{
    GLShaderProgram *shader;
    
    MVPMatrixManager *matrixManager;
    GLuint vao;
    GLuint vbo;
    
    GLuint ATTRIB_COLOR;
    GLuint ATTRIB_VERTEX;
    GLuint ATTRIB_MVPMATRIX;
    GLuint ATTRIB_TEXCOORD;
    
    int currentVBO;
    int count;
    
    size_t SIZE_MATRIX;
    size_t SIZE_VERTEX;
    size_t SIZE_TEXCOORD;
    size_t SIZE_COLOR;
    size_t STRIDE;
    
    TextureVertexData *dataBuffer;
}

@property (nonatomic,retain) Texture2D *texture;
@property (nonatomic) BOOL isFont;

-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount;
-(void)draw;
-(void)begin;
-(void)addDefaultTextureCoordinatesWithColor:(Color4B)_ctextureColor;

@end
