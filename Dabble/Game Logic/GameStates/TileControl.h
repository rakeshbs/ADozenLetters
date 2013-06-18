//
//  TileControl.h
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "Tile.h"
#import "GLShaderManager.h"

@interface TileControl : GLElement
{
    NSMutableArray *tilesArray;
    
    NSString *charArray1[3];
    
    GLShaderProgram *colorShaderProgram;
    GLShaderProgram *textureShaderProgram;
    
    
    InstancedVertexColorData *tileColorData;
    InstancedTextureVertexColorData *shadowTextureData;
    InstancedTextureVertexColorData *characterTextureData;
    InstancedTextureVertexColorData *scoreTextureData;
    
    
    FontSpriteSheet *characterSpriteSheet;
    FontSpriteSheet *scoreSpriteSheet;
    Texture2D *shadowTexture;
    
    Vector3D tileVertices[6];
    Vector3D shadowVertices[6];
    
    Color4B tileColors[2][2];
    
    GLuint colorBuffer;
    GLuint textureBuffer;
    
    GLuint ATTRIB_COLOR_MVPMATRIX;
    GLuint ATTRIB_COLOR_VERTEX;
    GLuint ATTRIB_COLOR_COLOR;
    
    GLuint ATTRIB_TEXTURE_MVPMATRIX;
    GLuint ATTRIB_TEXTURE_VERTEX;
    GLuint ATTRIB_TEXTURE_COLOR;
    GLuint ATTRIB_TEXTURE_TEXCOORDS;
    
    size_t SIZE_MATRIX;
    size_t SIZE_VERTEX;
    size_t SIZE_COLOR;
    size_t SIZE_TEXCOORDS;
    
    size_t COLOR_STRIDE;
    size_t TEXTURE_STRIDE;
    
    
}

-(Color4B)getColorForState:(int)state andColorIndex:(int)index;

@end
