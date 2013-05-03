//
//  Square.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "TextureManager.h"
#import "ColorRenderer.h"
#import "TextureRenderer.h"

#define tileSquareSize 60.0f
#define shadowSize 90.0f

@interface Tile : GLElement <AnimationDelegate>
{
    NSString *character;
    FontSprite *characterFontSprite;
    Texture2D *shadowTexture;
    FontSprite *scoreTexture;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    CGFloat shadowAlpha;
    Color4B *shadowColor;
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
    TextureRenderer *shadowTextureShader;
    
    int isBonded;
    
    CGPoint anchorPoint;
    
    Color4B *currentTileColor;
    Color4B *currentCharacterColor;
    CGFloat *startAlphas;
    CGFloat characterStartAlpha;

    BOOL isColorAnimating;
    
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
