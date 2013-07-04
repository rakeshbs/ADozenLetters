//
//  Square.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "TextureManager.h"

#define tileSquareSize 60.0f
#define shadowSize 90.0f

@class TileControl;


@interface Tile : GLElement <AnimationDelegate>
{
    NSString *character;
    
    FontSprite *characterFontSprite;
    Texture2D *shadowTexture;
    FontSprite *scoreTexture;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    CGFloat shadowAlpha;
    CGFloat wiggleAngle;
    CGFloat startAngle;
    
    int colorIndex;
    
    CGPoint prevTouchPoint;
    
    int shadowAnimationCount;
    BOOL shadowVisible;
    
    int score;
    
    BOOL isBonded;
    
    CGPoint anchorPoint;
    
    Color4B *currentTileColor;
    Color4B *currentCharacterColor;

    Color4B *startTileColors;
    Color4B startCharacterColor;
    Color4B *shadowColor;

    BOOL isColorAnimating;
    BOOL isBondedColor;
}

@property (nonatomic,retain) NSString *character;
@property (nonatomic)     int score;

@property (nonatomic) Color4B *currentTileColor;
@property (nonatomic) Color4B *currentCharacterColor;
@property (nonatomic) Color4B *shadowColor;
@property (nonatomic)     CGFloat wiggleAngle;

@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) int colorIndex;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic,assign) NSMutableArray *tilesArray;
@property (nonatomic)    BOOL isBonded;

@property (nonatomic,assign) FontSprite *characterFontSprite;
@property (nonatomic, assign) Texture2D *shadowTexture;
@property (nonatomic, assign) FontSprite *scoreTexture;

@property (nonatomic,readonly) TileControl *tileControl;

-(id)initWithCharacter:(NSString *)_character;
-(void)wiggleFor:(CGFloat)duration;
-(void)setupColors;
-(void)resetToAnchorPoint;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)animateShowColorInDuration:(CGFloat)duration;
-(void)animateHideColorInDuration:(CGFloat)duration;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;

@end
