//
//  Square.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "TextureManager.h"
#import "FlatColorShader.h"
#import "TextureShader.h"
#import "StringTextureShader.h"
#define tileSquareSize 60.0f
#define shadowSize 90.0f

@interface Tile : GLElement <AnimationDelegate>
{
    NSString *character;
    Texture2D *characterTexture;
    Texture2D *shadowTexture;
    Texture2D *scoreTexture;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    CGFloat shadowAlpha;
    CGFloat wiggleAngle;
    CGFloat startAngle;
    
    int colorIndex;
    
    CGPoint touchOffSet;
    BOOL touchStarted;
    
    short touchCorner;
    
    int horizontalDirection;
    int verticalDirection;
    
    CGPoint prevTouchPoint;
    
    int shadowAnimationCount;
    BOOL shadowVisible;
    
    CGFloat redColor;
    
    int score;
    
    FlatColorShader *tileColorShader;
    StringTextureShader *characterTextureShader;
    TextureShader *shadowTextureShader;
    
    int isBonded;
    
    CGPoint anchorPoint;
    
    Color4f *currentTileColor;
    Color4f *currentCharacterColor;
    CGFloat *startAlphas;
    CGFloat characterStartAlpha;

}
@property (nonatomic,retain) NSString *character;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) int colorIndex;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic,assign) NSMutableArray *tilesArray;
@property (nonatomic)    int isBonded;
-(id)initWithCharacter:(NSString *)_character;

-(void)wiggleFor:(CGFloat)duration;
-(void)resetToAnchorPoint;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)animateShowColorInDuration:(CGFloat)duration;
-(void)animateHideColorInDuration:(CGFloat)duration;
@end
