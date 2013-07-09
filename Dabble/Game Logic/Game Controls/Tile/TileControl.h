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

#define TileControlStateHide 1
#define TileControlStateShow 2


@interface TileControlEventData : NSObject
@property (nonatomic,retain) NSMutableString *concatenatedString;
@property (nonatomic) int scorePerMove;
@property (nonatomic) int eventState;
@end

@interface TileControl : GLElement <AnimationDelegate>
{
    NSMutableArray *tilesArray;
    
    
    InstancedVertexColorData *tileColorData;
    InstancedTextureVertexColorData *shadowTextureData;
    InstancedTextureVertexColorData *characterTextureData;
    InstancedTextureVertexColorData *scoreTextureData;
    InstancedTextureVertexColorData *tileTextureData;
    
    
    FontSpriteSheet *characterSpriteSheet;
    FontSpriteSheet *scoreSpriteSheet;
    Texture2D *shadowTexture;
    Texture2D *tileTexture;
    
    TextureCoord *shadowTexCoordinates;
    TextureCoord *tileTexCoordinates;
    
    Vector3D tileVertices[6];
    Vector3D shadowVertices[6];
    
    Color4B tileColors[2][2];
    
    GLRenderer *textureRenderer;
    
    float *xMargins;
    float yMargin;
    int shadowCount;
    
    int *scorePerRow;
    char *rearrangedCharacters;
    int numberOfRows;
    int *numberOfLettersPerRow;
    int lengthOfCharRow;
    
    NSMutableArray *generatedWords;
    
    NSMutableArray *newWordsPerMove;
    NSMutableArray *usedWordsPerTurn;
    NSMutableArray *wordsPerMove;
    NSMutableString *concatenatedWords;
    
    int scorePerMove;
    
    Dictionary *dictionary;
    
    NSObject *target;
    SEL selector;
    
    int relativePosition;
    
    CGFloat scale;
}

@property (nonatomic,readonly, getter=theNewWordsPerMove) NSMutableArray *newWordsPerMove;
@property (nonatomic,readonly) NSMutableArray *usedWordsPerTurn;
@property (nonatomic,readonly) NSMutableArray *wordsPerMove;
@property (nonatomic,readonly)  NSMutableString *concatenatedWords;
@property (nonatomic,readonly)     NSMutableArray *allowedWords;

-(Color4B)getColorForState:(int)state andColorIndex:(int)index;
-(void)createTiles:(NSString *)dataStr;
-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector;
-(void)showTiles;
-(void)hideTiles;
@end
