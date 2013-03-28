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
#define ANIMATION_THROW 8


#define SHADOW_ALPHA_MAX 1.0f
#define SHADOW_ALPHA_MIN 0.0f
#define WIGGLE_ANGLE 10.0f
#define REDCOLOR_MIN 0.01f
#define REDCOLOR_MAX 1.0f

#define NUMBEROFSCORES 7


@implementation Square

@synthesize character,anchorPoint,colorIndex;

Vector3D rectVertices[4];   
static Color4f tileColors[2][2][4];
static Color4f characterColors[2];
static Color4f transparentColor = (Color4f) {.red = 1.0, .blue = 1.0, .green = 1.0, .alpha = 0.0};

Color4f *currentTileColor;
Color4f currentCharacterColor;


SoundManager *soundManager;

int letterScores[NUMBEROFSCORES] = {1,2,3,4,5,8,10};
NSString *lettersPerScore[NUMBEROFSCORES]= {@"AEIOULNRST",@"DG",@"BCMP",@"FHVWY",@"K",@"JX",@"QZ"};

-(void)setColorIndex:(int)_colorIndex
{
    colorIndex = _colorIndex;
    squareColorShader.colors = (currentTileColor+colorIndex*4);
}

-(CGRect)frame
{
    return CGRectMake(self.centerPoint.x-squareSize/2, 460 - (self.centerPoint.y + squareSize/2), squareSize, squareSize);
    
}

-(id)initWithCharacter:(NSString *)_character
{
    if (self = [super init])
    {
        
        startAngle = 0;
        wiggleAngle = 0;
        shadowAlpha = 0;
        self.character = _character;
        shadowAnimationCount = 0;
        tileColorIndex = 0;
        shadowVisible = NO;
        
        for (int i = 0;i<NUMBEROFSCORES;i++)
        {
            if ([lettersPerScore[i] rangeOfString:_character].location != NSNotFound)
            {
                score = letterScores[i];
                break;
            }
        }
        
        
        [self setupGraphics];
       // [self setupSounds];
    
    }
    
    return self;
}


-(void)setupSounds
{
    soundManager = [SoundManager sharedSoundManager];
    [soundManager loadSoundWithKey:@"pick" soundFile:@"bip1.aiff"];
    [soundManager loadSoundWithKey:@"place" soundFile:@"bip2.aiff"];
    
}

-(void)setupGraphics
{
    TextureManager *texManager = [TextureManager getSharedTextureManager];
    characterTexture =[texManager getStringTexture:self.character                                                                     dimensions:CGSizeMake(squareSize,squareSize)
                                         horizontalAlignment:UITextAlignmentCenter verticalAlignment:UITextAlignmentMiddle
                                          fontName:@"Lato"
                                          fontSize:40];
    
    scoreTexture =[texManager getStringTexture:[NSString stringWithFormat:@"%d",score]                                                                     dimensions:CGSizeMake(squareSize-10,squareSize-5)
                               horizontalAlignment:UITextAlignmentRight verticalAlignment:UITextAlignmentBottom
                                          fontName:@"Lato"
                                          fontSize:15];
    
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    
    rectVertices[0] =  (Vector3D) {.x = -squareSize/(2), .y = -squareSize/(2), .z = 10.0f};
    rectVertices[1] = (Vector3D)  {.x = squareSize/(2), .y = - squareSize/(2), .z = 10.0f};
    rectVertices[2] = (Vector3D)  {.x = squareSize/(2), .y =  squareSize/(2), .z = 10.0f};
    rectVertices[3] = (Vector3D)  {.x = -squareSize/(2), .y = squareSize/(2), .z = 10.0f};
    
    colorIndex = 0;
    [self setupColors];
    
    squareColorShader = [[ColorShader alloc]init];
    squareColorShader.drawMode = GL_TRIANGLE_FAN;
    squareColorShader.vertices = rectVertices;
    squareColorShader.colors = (currentTileColor + 2 * colorIndex);
    squareColorShader.count = 4;

    characterTextureShader = [[StringTextureShader alloc]init];
    characterTextureShader.count = 4;
    characterTextureShader.vertices = [characterTexture getTextureVertices];
    characterTextureShader.texture = characterTexture;
    characterTextureShader.textureCoordinates = [characterTexture getTextureCoordinates];
    characterTextureShader.textureColor = &currentCharacterColor;
    
    scoreTextureShader = [[StringTextureShader alloc]init];
    scoreTextureShader.count = 4;
    scoreTextureShader.vertices = [scoreTexture getTextureVertices];
    scoreTextureShader.texture = scoreTexture;
    scoreTextureShader.textureCoordinates = [scoreTexture getTextureCoordinates];
    scoreTextureShader.textureColor = &currentCharacterColor;
    
    shadowTextureShader = [[TextureShader alloc]init];
    shadowTextureShader.drawMode = GL_TRIANGLE_FAN;
    shadowTextureShader.count = 4;
    shadowTextureShader.texture = shadowTexture;
    shadowTextureShader.vertices = [shadowTexture getTextureVertices];
    shadowTextureShader.textureCoordinates = [shadowTexture getTextureCoordinates];
    shadowTextureShader.textureColor = &transparentColor;
    
}

-(void)setupColors
{
    CGFloat alpha = 0.93f;
    
    tileColors[0][0][0] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = 1.0f};
    tileColors[0][0][1] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = 1.0f};
    tileColors[0][0][2] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = 1.0f};
    tileColors[0][0][3] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = 1.0f};
    
    //255 250 231
    
    tileColors[0][1][0] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = alpha};
    tileColors[0][1][1] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = alpha};
    tileColors[0][1][2] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = alpha};
    tileColors[0][1][3] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = alpha};
    
    
    CGFloat alpha2 = 0.5;
    //    rgb 243 156 18
    
    tileColors[1][0][0] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = 1.0f};
    tileColors[1][0][1] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = 1.0f};
    tileColors[1][0][2] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = 1.0f};
    tileColors[1][0][3] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = 1.0f};
    
    
    //    rgb 243 156 18
    
    tileColors[1][1][0] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = alpha2};
    tileColors[1][1][1] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = alpha2};
    tileColors[1][1][2] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = alpha2};
    tileColors[1][1][3] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = alpha2};
    
    currentTileColor = malloc(sizeof(Color4f)*8);
    
    for (int i = 0;i<2;i++)
        for (int j = 0;j<4;j++)
            Color4fCopy(&tileColors[tileColorIndex][i][j], (currentTileColor+4*i+j));
    
    characterColors[0] = (Color4f) { .red = 0.952, .green = 0.611 , .blue = 0.066, .alpha = 1.0f};
    characterColors[1] = (Color4f) { .red = 1.0f, .blue = 1.0 , .green = 1.0f, .alpha = 1.0f};
    
    Color4fCopy(&characterColors[tileColorIndex], &currentCharacterColor);
}

-(void)draw
{
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager rotateByAngleInDegrees:wiggleAngle InX:0 Y:0 Z:1];
    [mvpMatrixManager translateInX:self.centerPoint.x Y:self.centerPoint.y Z:0];
    [shadowTextureShader draw];
    [squareColorShader draw];
    [characterTextureShader draw];
    [scoreTextureShader draw];
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
    else if (animation.type == ANIMATION_THROW)
    {
        CGFloat newX = getEaseInOutBack(startPoint.x, endPoint.x, animationRatio);
        CGFloat newY = getEaseInOutBack(startPoint.y, endPoint.y, animationRatio);
        _centerPoint = CGPointMake(newX, newY);
    }
    else if (animation.type == ANIMATION_SHOW_SHADOW)
    {
       if (shadowTextureShader.textureColor->alpha >= SHADOW_ALPHA_MAX)
           return YES;
        CGFloat calpha = getEaseOut(SHADOW_ALPHA_MIN, SHADOW_ALPHA_MAX, animationRatio);
        shadowTextureShader.textureColor = (Color4f) {.red = shadowTextureShader.textureColor.red, .blue = shadowTextureShader.textureColor.blue, .green =shadowTextureShader.textureColor.green, .alpha = calpha};
    }
    else if (animation.type == ANIMATION_HIDE_SHADOW)
    {
        if (shadowTextureShader.textureColor->alpha <= SHADOW_ALPHA_MIN)
            return YES;
        CGFloat calpha = getEaseOut(SHADOW_ALPHA_MAX,SHADOW_ALPHA_MIN, animationRatio);
        shadowTextureShader.textureColor = (Color4f) {.red = shadowTextureShader.textureColor.red, .blue = shadowTextureShader.textureColor.blue, .green =shadowTextureShader.textureColor->green, .alpha = calpha};
    }
    else if (animation.type == ANIMATION_WIGGLE)
    {
        wiggleAngle = getSineEaseOut(0, animationRatio, WIGGLE_ANGLE);
    }
    else if (animation.type == ANIMATION_SHOW_COLOR)
    {
        for (int c = 0;c<2;c++)
        {
            CGFloat red = getEaseIn(tileColors[0][c][0].red, tileColors[1][c][0].red, animationRatio);
            CGFloat blue = getEaseIn(tileColors[0][c][0].blue, tileColors[1][c][0].blue, animationRatio);
            CGFloat green = getEaseIn(tileColors[0][c][0].green, tileColors[1][c][0].green, animationRatio);
            CGFloat alpha = getEaseIn(tileColors[0][c][0].alpha, tileColors[1][c][0].alpha, animationRatio);
            
            
            for (int i = 0;i<4;i++)
            {
                (currentTileColor+c*4+i)->red = red;
                (currentTileColor+c*4+i)->blue = blue;
                (currentTileColor+c*4+i)->green = green;
                (currentTileColor+c*4+i)->alpha = alpha;
            }
        }
        
        CGFloat red = getEaseIn(characterColors[0].red, characterColors[1].red, animationRatio);
        CGFloat blue = getEaseIn(characterColors[0].blue, characterColors[1].blue, animationRatio);
        CGFloat green = getEaseIn(characterColors[0].green, characterColors[1].green, animationRatio);
        CGFloat alpha = getEaseIn(characterColors[0].alpha, characterColors[1].alpha, animationRatio);
        
        currentCharacterColor.red = red;
        currentCharacterColor.blue = blue;
        currentCharacterColor.green = green;
        currentCharacterColor.alpha = alpha;
        

    }
    else if (animation.type == ANIMATION_HIDE_COLOR)
    {
        for (int c = 0;c<2;c++)
        {
            CGFloat red = getEaseIn(tileColors[1][c][0].red, tileColors[0][c][0].red, animationRatio);
            CGFloat blue = getEaseIn(tileColors[1][c][0].blue, tileColors[0][c][0].blue, animationRatio);
            CGFloat green = getEaseIn(tileColors[1][c][0].green, tileColors[0][c][0].green, animationRatio);
            CGFloat alpha = getEaseIn(tileColors[1][c][0].alpha, tileColors[0][c][0].alpha, animationRatio);
            for (int i = 0;i<4;i++)
            {
                (currentTileColor+c*4+i)->red = red;
                (currentTileColor+c*4+i)->blue = blue;
                (currentTileColor+c*4+i)->green = green;
                (currentTileColor+c*4+i)->alpha = alpha;
            }
        }
        
        CGFloat red = getEaseIn(characterColors[1].red, characterColors[0].red, animationRatio);
        CGFloat blue = getEaseIn(characterColors[1].blue, characterColors[0].blue, animationRatio);
        CGFloat green = getEaseIn(characterColors[1].green, characterColors[0].green, animationRatio);
        CGFloat alpha = getEaseIn(characterColors[1].alpha, characterColors[0].alpha, animationRatio);
        
        currentCharacterColor.red = red;
        currentCharacterColor.blue = blue;
        currentCharacterColor.green = green;
        currentCharacterColor.alpha = alpha;
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
        int countThrow = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_THROW];
        
        int totatCount = countMove+countWiggle+countThrow;
        
        if (totatCount > 0 || touchesInElement.count > 0)
        {
            [animator addAnimationFor:self ofType:ANIMATION_SHOW_SHADOW ofDuration:0.2 afterDelayInSeconds:0];
        }
    }
    else
    {
        int countMove = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_MOVE];
        int countWiggle = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_WIGGLE];
        int countThrow = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_THROW];
        
        int totatCount = countMove+countWiggle+countThrow;
        
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
            
            int ci = sq.colorIndex;
            sq.colorIndex = self.colorIndex;
            self.colorIndex = ci;
            
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
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE || animation.type == ANIMATION_THROW)
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
  /*     [soundManager playSoundWithKey:@"place" gain:10.0f
                                 pitch:1.0f
                              location:CGPointZero
                            shouldLoop:NO];*/
    }
    else if (animation.type == ANIMATION_SHOW_SHADOW)
    {
        CGFloat p = (rand()%10 - 5)/20.0;
       // NSLog(@"%f",p);
        [soundManager playSoundWithKey:@"pick" gain:10.0f
                                 pitch:1.0f+p
                              location:CGPointZero
                            shouldLoop:NO];
    }
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE || animation.type == ANIMATION_THROW)
    {
        if (animation.type == ANIMATION_MOVE)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SquareFinishedMoving" object:nil];
            
            
        }
        shadowAnimationCount--;
        [self updateShadow];
    }
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

-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration
{
    
    startPoint = self.centerPoint;
    endPoint = newPoint;
    [animator addAnimationFor:self ofType:ANIMATION_THROW ofDuration:duration afterDelayInSeconds:0];
}

-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{
    
    startPoint = self.centerPoint;
    endPoint = newPoint;
    [animator addAnimationFor:self ofType:ANIMATION_THROW ofDuration:duration afterDelayInSeconds:delay];
}

-(void)animateColorInDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{
    if (tileColorIndex == 0)
    {
        NSLog(@"animate");
        [animator addAnimationFor:self ofType:ANIMATION_SHOW_COLOR ofDuration:duration afterDelayInSeconds:delay];
        tileColorIndex = 1;
    }
    else
    {
        [animator addAnimationFor:self ofType:ANIMATION_HIDE_SHADOW ofDuration:duration afterDelayInSeconds:delay];
        tileColorIndex = 0;
    }
}

-(void)dealloc
{
    [super dealloc];
    self.squaresArray = nil;
}

@end
