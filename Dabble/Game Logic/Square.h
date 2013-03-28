//
//  Square.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "TextureManager.h"
#import "ColorShader.h"
#import "TextureShader.h"
#import "StringTextureShader.h"
#define squareSize 60.0f
#define shadowSize 90.0f

@interface Square : GLElement <AnimationDelegate>
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
    
    ColorShader *squareColorShader;
    StringTextureShader *characterTextureShader;
    StringTextureShader *scoreTextureShader;
    TextureShader *shadowTextureShader;
    
    int tileColorIndex;
    
    CGPoint anchorPoint;
}
@property (nonatomic,retain) NSString *character;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) int colorIndex;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic,assign) NSMutableArray *squaresArray;
-(id)initWithCharacter:(NSString *)_character;

-(void)wiggleFor:(CGFloat)duration;
-(void)resetToAnchorPoint;
-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration;
-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
-(void)animateColorInDuration:(CGFloat)duration afterDelay:(CGFloat)delay;
@end
