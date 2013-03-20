//
//  Square.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Square.h"
#import "GLCommon.h"
#import "EasingFunctions.h"
#import "Scene.h"
#import "SoundManager.h"

#define ANIMATION_MOVE 1
#define ANIMATION_WIGGLE 2
#define ANIMATION_SHOW_SHADOW 3
#define ANIMATION_HIDE_SHADOW 4
#define ANIMATION_QUEUE_MOVE 5
#define ANIMATION_SHOW_COLOR 6
#define ANIMATION_HIDE_COLOR 7


#define SHADOW_ALPHA_MAX 1.0f
#define SHADOW_ALPHA_MIN 0.0f
#define WIGGLE_ANGLE 20.0f
#define REDCOLOR_MIN 0.01f
#define REDCOLOR_MAX 1.0f



@implementation Square

@synthesize character;

Vector3D rectVertices[4];
Vector3D shadowVertices[4];
Color4f rectColors[4];
TextureCoord characterTextureCoordinates[4];
TextureCoord shadowTextureCoordinates[4];
SoundManager *soundManager;

-(CGRect)frame
{
    return CGRectMake(self.centerPoint.x-squareSize/2, 460 - (self.centerPoint.y + squareSize/2), squareSize, squareSize);
    
}

-(id)initWithCharacter:(NSString *)_character
{
    if (self = [super init])
    {
        redColor = REDCOLOR_MIN;
        self.character = _character;
        shadowAnimationCount = 0;
        shadowVisible = NO;
        TextureManager *texManager = [TextureManager getSharedTextureManager]; 
        characterTexture =[texManager getStringTexture:_character                                                                     dimensions:CGSizeMake(squareSize,squareSize)
                                             alignment:UITextAlignmentCenter
                                              fontName:@"ArialRoundedMTBold"
                                              fontSize:45];
        shadowTexture = [textureManager getTexture:@"shadow.png"];
        
        rectVertices[0] =  (Vector3D) {.x = -squareSize/(2), .y = -squareSize/(2), .z = 10.0f};
        rectVertices[1] = (Vector3D)  {.x = squareSize/(2), .y = - squareSize/(2), .z = 10.0f};
        rectVertices[2] = (Vector3D)  {.x = squareSize/(2), .y =  squareSize/(2), .z = 10.0f};
        rectVertices[3] = (Vector3D)  {.x = -squareSize/(2), .y = squareSize/(2), .z = 10.0f};
        
        shadowVertices[0] =  (Vector3D) {.x = -shadowSize/(2), .y = -shadowSize/(2), .z = 10.0f};
        shadowVertices[1] = (Vector3D)  {.x = shadowSize/(2), .y = - shadowSize/(2), .z = 10.0f};
        shadowVertices[2] = (Vector3D)  {.x = shadowSize/(2), .y =  shadowSize/(2), .z = 10.0f};
        shadowVertices[3] = (Vector3D)  {.x = -shadowSize/(2), .y = shadowSize/(2), .z = 10.0f};
        
        
        GLfloat grayColor = 0.93f;
        
        rectColors[0] = (Color4f) { .red = grayColor, .blue = 0 , .green = grayColor, .alpha = 1.0f};
        rectColors[1] = (Color4f) { .red = grayColor, .blue = 0 , .green = grayColor, .alpha = 1.0f};
        rectColors[2] = (Color4f) { .red = grayColor, .blue = 0 , .green = grayColor, .alpha = 1.0f};
        rectColors[3] = (Color4f) { .red = grayColor, .blue = 0 , .green = grayColor, .alpha = 1.0f};

        characterTextureCoordinates[0] = (TextureCoord) { .s = 0, .t = characterTexture.maxS};
        characterTextureCoordinates[1] = (TextureCoord) { .s = characterTexture.maxS, .t = characterTexture.maxT};
        characterTextureCoordinates[2] = (TextureCoord) { .s = characterTexture.maxS, .t = 0};
        characterTextureCoordinates[3] = (TextureCoord) { .s = 0, .t = 0};
        
        shadowTextureCoordinates[0] = (TextureCoord) { .s = 0, .t = shadowTexture.maxS};
        shadowTextureCoordinates[1] = (TextureCoord) { .s = shadowTexture.maxS, .t = shadowTexture.maxT};
        shadowTextureCoordinates[2] = (TextureCoord) { .s = shadowTexture.maxS, .t = 0};
        shadowTextureCoordinates[3] = (TextureCoord) { .s = 0, .t = 0};
        
        
        startAngle = 0;
        wiggleAngle = 0;
        shadowAlpha = 0;
        
     //   soundManager = [SoundManager sharedSoundManager]; 
     //   [soundManager loadSoundWithKey:@"pick" soundFile:@"bip1.aiff"];
     //   [soundManager loadSoundWithKey:@"place" soundFile:@"bip2.aiff"];
        
        squareColorShader = [[ColorShader alloc]init];
        squareColorShader.drawMode = GL_TRIANGLE_FAN;
        squareColorShader.vertices = rectVertices;
        squareColorShader.colors = rectColors;
        squareColorShader.count = 4;
        
        characterTextureShader = [[StringTextureShader alloc]init];
        characterTextureShader.count = 4;
        characterTextureShader.vertices = rectVertices;
        characterTextureShader.texture = characterTexture;
        characterTextureShader.textureCoordinates = characterTextureCoordinates;
        characterTextureShader.textureColor = (Color4f) {.red = 0.4, .green = 0.8, .blue = 0.9, .alpha = 1.0};
     
        shadowTextureShader = [[TextureShader alloc]init];
        shadowTextureShader.drawMode = GL_TRIANGLE_FAN;
        shadowTextureShader.count = 4;
        shadowTextureShader.vertices = shadowVertices;
        shadowTextureShader.texture = shadowTexture;
        shadowTextureShader.textureCoordinates = shadowTextureCoordinates;
        shadowTextureShader.textureColor = (Color4f) {.red = 1.0, .blue = 1.0, .green = 1.0, .alpha = 0.0};
    }
    
    return self;
}

-(void)draw
{
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager rotateByAngleInDegrees:wiggleAngle InX:0 Y:0 Z:1];
    [mvpMatrixManager translateInX:self.centerPoint.x Y:self.centerPoint.y Z:0];
    [shadowTextureShader draw];
    [squareColorShader draw];
    [characterTextureShader draw];
    [mvpMatrixManager popModelViewMatrix];
    
}

-(BOOL)update:(Animation *)animation;
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    if (animation.type == ANIMATION_MOVE)
    {
        CGFloat newX = getEaseOut(startPoint.x, endPoint.x, animationRatio);
        CGFloat newY = getEaseOut(startPoint.y, endPoint.y, animationRatio);
        _centerPoint = CGPointMake(newX, newY);
    }
    else if (animation.type == ANIMATION_SHOW_SHADOW)
    {
       if (shadowTextureShader.textureColor.alpha >= SHADOW_ALPHA_MAX)
           return YES;
        CGFloat calpha = getEaseOut(SHADOW_ALPHA_MIN, SHADOW_ALPHA_MAX, animationRatio);
        shadowTextureShader.textureColor = (Color4f) {.red = shadowTextureShader.textureColor.red, .blue = shadowTextureShader.textureColor.blue, .green =shadowTextureShader.textureColor.green, .alpha = calpha};
    }
    else if (animation.type == ANIMATION_HIDE_SHADOW)
    {
        if (shadowTextureShader.textureColor.alpha <= SHADOW_ALPHA_MIN)
            return YES;
        CGFloat calpha = getEaseOut(SHADOW_ALPHA_MAX,SHADOW_ALPHA_MIN, animationRatio);
        shadowTextureShader.textureColor = (Color4f) {.red = shadowTextureShader.textureColor.red, .blue = shadowTextureShader.textureColor.blue, .green =shadowTextureShader.textureColor.green, .alpha = calpha};
    }
    else if (animation.type == ANIMATION_WIGGLE)
    {
        wiggleAngle = getSineEaseOut(0, animationRatio, WIGGLE_ANGLE);
    }
    else if (animation.type == ANIMATION_SHOW_COLOR)
    {
        redColor = getEaseOut(REDCOLOR_MIN, REDCOLOR_MAX, animationRatio);
    }
    else if (animation.type == ANIMATION_HIDE_COLOR)
    {
        redColor = getEaseOut(REDCOLOR_MAX, REDCOLOR_MIN, animationRatio);
    }
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}

-(void)updateShadow
{
    if (!shadowVisible)
    {
        shadowVisible = YES;
        int countMove = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_MOVE];
        int countWiggle = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_WIGGLE];
        
        int totatCount = countMove+countWiggle;
        
        if (totatCount > 0 || touchesInElement.count > 0)
        {
            [animator addAnimationFor:self ofType:ANIMATION_SHOW_SHADOW ofDuration:0.2 afterDelayInSeconds:0];
        }
    }
    else
    {
        int countMove = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_MOVE];
        int countWiggle = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_WIGGLE];
        
        int totatCount = countMove+countWiggle;
        
        if (totatCount == 0 && touchesInElement.count == 0)
        {
            shadowVisible = NO;
            [animator addAnimationFor:self ofType:ANIMATION_HIDE_SHADOW ofDuration:0.2 afterDelayInSeconds:0];
        }
    }
}


-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    if (index == 0)
    {
        CGPoint touchPoint = [touch locationInView:self.scene.view];
        wiggleAngle = 0;
        
        [animator removeQueuedAnimationsForObject:self];
        [animator removeRunningAnimationsForObject:self];
        
        [self updateShadow];
        
        touchOffSet = CGPointMake(_centerPoint.x-touchPoint.x, _centerPoint.y-(460 - touchPoint.y));
        
        if (touchOffSet.x > 0 && touchOffSet.y < 0)
        {
            touchCorner = 1;
        }
        else if (touchOffSet.x < 0 && touchOffSet.y < 0)
        {
            touchCorner = 2;
        }
        else if (touchOffSet.x > 0 && touchOffSet.y > 0)
        {
            touchCorner = 3;
        }
        else if (touchOffSet.x > 0 && touchOffSet.y > 0)
        {
            touchCorner = 4;
        }
        else
        {
            touchCorner = 4;
        }
        
        prevTouchPoint = touchPoint;
    }
}


-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    
    if (index == 0)
    {
        
        CGPoint touchPoint = [touch locationInView:self.scene.view];
        
        self.centerPoint =  CGPointMake(touchPoint.x+touchOffSet.x, 460 - touchPoint.y + touchOffSet.y);
        
        CGFloat diffX = touchPoint.x - prevTouchPoint.x;
        CGFloat diffY = touchPoint.y - prevTouchPoint.y;
        
        if (fabs(diffY)>fabs(diffX)+5)
        {
            
            prevTouchPoint = touchPoint;
        }
        else if (fabs(diffX) > fabs(diffY)+5)
        {
            prevTouchPoint = touchPoint;
        }
        
        if (fabs(self.anchorPoint.y - self.centerPoint.y) > squareSize/2)
        {
            
            [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_QUEUE_MOVE];
            
            [animator addAnimationFor:self ofType:ANIMATION_QUEUE_MOVE
                           ofDuration:0.00001
                  afterDelayInSeconds:0.03];
        }
        else
        {
            [self checkCollissionAndMove];
        }
    }
}

-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	if (index == 0)
    {
        [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_QUEUE_MOVE];
        [self checkCollissionAndMove];
  
        if (touch.tapCount >= 1)
        {
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.2];
        }
        else
        {
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.2];
        }
        [self updateShadow];
    }
}

-(void)checkCollissionAndMove
{
    
    for (Square *sq in _squaresArray)
    {
        if (sq == self)
            continue;
        
        CGRect sqAnchorRect = CGRectMake(sq.anchorPoint.x-squareSize/2, sq.anchorPoint.y-squareSize/2, squareSize, squareSize);
        
        CGRect selfAnchorRect = CGRectMake(self.centerPoint.x-squareSize/2, self.centerPoint.y-squareSize/2, squareSize, squareSize);
        
        CGRect intersection =  CGRectIntersection(sqAnchorRect, selfAnchorRect);
        CGFloat intersectionArea = intersection.size.height * intersection.size.width;
        
        if (intersectionArea >= squareSize*squareSize/2.0)
        {
            CGPoint a1 = sq.anchorPoint;
            sq.anchorPoint = self.anchorPoint;
            self.anchorPoint = a1;
            if (sq.touchesInElement.count == 0)
            {
                [sq moveToFront];
                [self moveToFront];
                [sq moveToPoint:sq.anchorPoint inDuration:0.2];
                
                
            }
        }
        
    }
}

-(void)resetToAnchorPoint
{
    if (!CGPointEqualToPoint(self.centerPoint, self.anchorPoint))
    {
        [self moveToPoint:self.anchorPoint inDuration:0.2];
    }
}

-(void)animationStarted:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE)
    {
        shadowAnimationCount++;
        [self updateShadow];
    }
    else if (animation.type == ANIMATION_QUEUE_MOVE)
    {
        [self checkCollissionAndMove];
    }
    else if (animation.type == ANIMATION_HIDE_SHADOW)
    {
        [soundManager playSoundWithKey:@"place" gain:10.0f
                                 pitch:1.0f
                              location:CGPointZero
                            shouldLoop:NO];
    }
    else if (animation.type == ANIMATION_SHOW_SHADOW)
    {
        [soundManager playSoundWithKey:@"pick" gain:10.0f
                                 pitch:1.0f
                              location:CGPointZero
                            shouldLoop:NO];
    }
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE)
    {
        if (animation.type == ANIMATION_MOVE)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SquareFinishedMoving" object:nil];
            
            
        }
        shadowAnimationCount--;
        [self updateShadow];
    }
    else if (animation.type == ANIMATION_SHOW_COLOR)
    {
        [animator addAnimationFor:self ofType:ANIMATION_HIDE_COLOR
                       ofDuration:0.5
              afterDelayInSeconds:0];
    }
}

-(void)animateColorWithDelay:(CGFloat)delay
{
    [animator addAnimationFor:self ofType:ANIMATION_SHOW_COLOR
                   ofDuration:0.5
          afterDelayInSeconds:delay];
}

-(void)wiggleFor:(CGFloat)duration
{
    [animator addAnimationFor:self ofType:ANIMATION_WIGGLE ofDuration:duration afterDelayInSeconds:0];
}

-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration
{
    
    startPoint = self.centerPoint;
    endPoint = newPoint;
    [animator addAnimationFor:self ofType:ANIMATION_MOVE ofDuration:duration afterDelayInSeconds:0];
}

-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{
    
    startPoint = self.centerPoint;
    endPoint = newPoint;
    [animator addAnimationFor:self ofType:ANIMATION_MOVE ofDuration:duration afterDelayInSeconds:delay];
}


-(void)dealloc
{
    [super dealloc];
    self.squaresArray = nil;
}

@end
