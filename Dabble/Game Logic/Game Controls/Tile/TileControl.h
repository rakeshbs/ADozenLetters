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
#import "TileSpriteSheet.h"
#import "SoundManager.h"

#define TileControlStateHide 1
#define TileControlStateShow 2



@interface TileControlEventData : NSObject
@property (nonatomic) int eventState;
@property (nonatomic) int score;
@end

@interface TileControl : GLElement <AnimationDelegate>
{
    NSMutableArray *tilesArray;
    
    InstancedVertexColorData *tileColorData;
    InstancedTextureVertexColorData *shadowTextureData;
    InstancedTextureVertexColorData *characterTextureData;
    InstancedTextureVertexColorData *scoreTextureData;
    InstancedTextureVertexColorData *tileTextureData;
    
   // FontSpriteSheet *characterSpriteSheet;
    FontSpriteSheet *scoreSpriteSheet;
    Texture2D *shadowTexture;
    Texture2D *tileTexture;
    
    Vector3D tileVertices[6];
    Vector3D transparentVertices[6];
    Vector3D shadowVertices[6];
    
    TextureCoord *shadowTexCoordinates;
    TextureCoord *tileTexCoordinates;
    
    Color4B tileColors[2][2];
    
    GLRenderer *colorRenderer;
    GLRenderer *textureRenderer;
    GLRenderer *stringTextureRenderer;
    
    int shadowCount;
    int characterDataCount;
    int tileColorVerticesCount;
    
    
  /*  NSMutableArray *generatedWords;
    NSMutableArray *newWordsPerMove;
    NSMutableArray *usedWordsPerTurn;
    NSMutableArray *wordsPerMove;
    NSMutableString *concatenatedWords;
    */
    
    int scorePerMove;
    
    Dictionary *dictionary;
    
    NSObject *target;
    SEL selector;
    
    int relativePosition;

    CGPoint *thirteenLayout;
    CGPoint *twelveLayout;
    
    CGPoint collapsePoint;
    
    NSMutableString *generatedString;
    
    BOOL isPlayable;
    
    int tileSequence[13];
    int score;
    
    int checkWord3,checkWord4,checkWord5;
    
    TileSpriteSheet *tileSpriteSheet;
    
    Sprite *tileSprite;
    SoundManager *soundManager;
}

@property (nonatomic,readonly, getter=theNewWordsPerMove) NSMutableArray *newWordsPerMove;
@property (nonatomic,readonly) NSMutableArray *usedWordsPerTurn;
@property (nonatomic,readonly) NSMutableArray *wordsPerMove;
@property (nonatomic,readonly)  NSMutableString *concatenatedWords;
@property (nonatomic,retain)     NSMutableArray *allowedWords;

-(Color4B)getColorForState:(int)state andColorIndex:(int)index;
-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector;
-(void)showTiles;
-(void)rearrangeToTwelveLetters;
-(void)startHidingTiles;
-(void)cancelHidingTiles;
-(void)hideTiles;
-(void)loadDozenLetters:(NSString *)letters;
-(void)togglePlayability:(BOOL)ON;
@end
