//
//  TileControl.h
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "Tile.h"
#import "Dictionary.h"
#import "GLShaderManager.h"

@interface TileControl : GLElement
{
    NSMutableArray *tilesArray;
    GLShaderProgram *colorShaderProgram;
    GLShaderProgram *textureShaderProgram;
    
    
    InstancedVertexColorData *tileColorData;
    InstancedTextureVertexColorData *shadowTextureData;
    InstancedTextureVertexColorData *characterTextureData;
    InstancedTextureVertexColorData *scoreTextureData;
    
    
    FontSpriteSheet *characterSpriteSheet;
    FontSpriteSheet *scoreSpriteSheet;
    Texture2D *shadowTexture;
    
    TextureCoord *shadowTexCoordinates;
    
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
    
    float *xMargins;
    float yMargin;
    int shadowCount;
    
    
    char *rearrangedCharacters;
    int numberOfRows;
    int *numberOfLettersPerRow;
    int lengthOfCharRow;
    
    NSMutableArray *generatedWords;
    
    NSMutableArray *newWordsPerTurn;
    NSMutableArray *usedWordsPerTurn;
    NSMutableArray *wordsPerTurn;
    NSMutableString *concatenatedWords;
    
    Dictionary *dictionary;
    
    NSObject *target;
    SEL selector;
}

@property (nonatomic,readonly) NSMutableArray *newWordsPerTurn;
@property (nonatomic,readonly) NSMutableArray *usedWordsPerTurn;
@property (nonatomic,readonly) NSMutableArray *wordsPerTurn;
@property (nonatomic,readonly)  NSMutableString *concatenatedWords;

-(Color4B)getColorForState:(int)state andColorIndex:(int)index;
-(void)createTiles:(NSString *)dataStr;
-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector;

@end
