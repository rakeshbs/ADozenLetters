//
//  Square.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Tile.h"
#import "GLCommon.h"
#import "EasingFunctions.h"
#import "Scene.h"
#import "SoundManager.h"
#import "TextureStringLayer.h"

#define ANIMATION_MOVE 1
#define ANIMATION_WIGGLE 2
#define ANIMATION_SHOW_SHADOW 3
#define ANIMATION_HIDE_SHADOW 4
#define ANIMATION_QUEUE_MOVE 5
#define ANIMATION_SHOW_COLOR 6
#define ANIMATION_HIDE_COLOR 7
#define ANIMATION_THROW 8


#define SHADOW_ALPHA_MAX 255
#define SHADOW_ALPHA_MIN 0
#define WIGGLE_ANGLE 10.0f
#define REDCOLOR_MIN 0.01f
#define REDCOLOR_MAX 1.0f

#define NUMBEROFSCORES 7


@implementation Tile

@synthesize character,anchorPoint,colorIndex,isBonded;

Vector3D rectVertices[6];
static Color4B tileColors[2][2];
static Color4B characterColors;
static Color4B transparentColor = (Color4B) {.red = 255, .blue = 255, .green = 255, .alpha = 0};


SoundManager *soundManager;

int letterScores[NUMBEROFSCORES] = {1,2,3,4,5,8,10};
NSString *lettersPerScore[NUMBEROFSCORES]= {@"AEIOULNRST",@"DG",@"BCMP",@"FHVWY",@"K",@"JX",@"QZ"};

-(void)setColorIndex:(int)_colorIndex
{
    colorIndex = _colorIndex;
    for (int i = 0;i<6;i++)
    {
        Color4fCopy(&tileColors[0][colorIndex], (tileColorShader.colors+i));
    }
}

-(CGRect)frame
{
    return CGRectMake(self.centerPoint.x-tileSquareSize/2, [UIScreen mainScreen].bounds.size.height - (self.centerPoint.y + tileSquareSize/2), tileSquareSize, tileSquareSize);
    
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
        isBonded = 0;
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

-(void)setupStrings
{
    TextureStringLayer *texString1 = [[TextureStringLayer alloc]init];
    texString1.string = self.character;
    texString1.dimensions = CGSizeMake(tileSquareSize, tileSquareSize);
    texString1.horizontalTextAlignment = UITextAlignmentCenter;
    texString1.verticalTextAlignment = UITextAlignmentMiddle;
    texString1.fontName= @"Lato";
    texString1.fontSize = 40;
    
    TextureStringLayer *texString2 = [[TextureStringLayer alloc]init];
    texString2.string = [NSString stringWithFormat:@"%d",score];
    texString2.dimensions = CGSizeMake(tileSquareSize-5, tileSquareSize-5);
    texString2.horizontalTextAlignment = UITextAlignmentRight;
    texString2.verticalTextAlignment = UITextAlignmentBottom;
    texString2.fontName= @"Lato";
    texString2.fontSize = 15;
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:texString1];
    [array addObject:texString2];
    
    characterTexture = [textureManager getLayeredStringTexture:array :self.character];
    
    [array release];
    [texString1 release];
    [texString2 release];
}

-(void)setupGraphics
{
    [self setupStrings];
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    
    rectVertices[0] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 10.0f};
    rectVertices[1] = (Vector3D)  {.x = tileSquareSize/(2), .y = - tileSquareSize/(2), .z = 10.0f};
    rectVertices[2] = (Vector3D)  {.x = tileSquareSize/(2), .y =  tileSquareSize/(2), .z = 10.0f};
    
    rectVertices[3] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 10.0f};
    rectVertices[4] = (Vector3D)  {.x = -tileSquareSize/(2), .y = tileSquareSize/(2), .z = 10.0f};
    rectVertices[5] =  (Vector3D) {.x = tileSquareSize/(2), .y = tileSquareSize/(2), .z = 10.0f};
    
    [self setupColors];
    
    tileColorShader = [[ColorShader alloc]init];
    tileColorShader.drawMode = GL_TRIANGLES;
    tileColorShader.count = 12;
    for (int i = 0;i<6;i++)
    {
        Vector3DCopy(&rectVertices[i],(tileColorShader.vertices+i));
        Color4fCopy(&tileColors[0][colorIndex], (tileColorShader.colors+i));
    }
    for (int i = 0;i<6;i++)
    {
        Vector3DCopy(&rectVertices[i],(tileColorShader.vertices+i+6));
    }

    
    shadowTextureShader = [[TextureShader alloc]init];
    shadowTextureShader.drawMode = GL_TRIANGLES;
    shadowTextureShader.count = 6;
    shadowTextureShader.texture = shadowTexture;
    
    Vector3D *texVertices1 = [shadowTexture getTextureVertices];
    TextureCoord *texCoords1 = [shadowTexture getTextureCoordinates];
    for (int i = 0;i<6;i++)
    {
        Vector3DCopy((texVertices1+i), (shadowTextureShader.vertices+i));
        TextureCoordCopy((texCoords1+i), (shadowTextureShader.textureCoordinates+i));
    }
    
    shadowTextureShader.vertices = [shadowTexture getTextureVertices];
    shadowTextureShader.textureCoordinates = [shadowTexture getTextureCoordinates];
    
    characterTextureShader = [[StringTextureShader alloc]init];
    characterTextureShader.drawMode = GL_TRIANGLES;
    characterTextureShader.count = 12;
    characterTextureShader.texture = characterTexture;
    Vector3D *texVertices2 = [characterTexture getTextureVertices];
    TextureCoord *texCoords2 = [characterTexture getTextureCoordinates];
    
    for (int i = 0;i<6;i++)
    {
        Vector3DCopy((texVertices2+i), (characterTextureShader.vertices+i));
        TextureCoordCopy((texCoords2+i), (characterTextureShader.textureCoordinates+i));
        Color4fCopyS(tileColors[0][0], (characterTextureShader.textureColors+i));

    }
    for (int i = 0;i<6;i++)
    {
        Vector3DCopy((texVertices2+i), (characterTextureShader.vertices+i+6));
        TextureCoordCopy((texCoords2+i), (characterTextureShader.textureCoordinates+i+6));

    }
    
}

-(void)setupColors
{
    CGFloat alpha = 0.93f;
    
    tileColors[0][0] = (Color4B) { .red = 255, .blue = 255 , .green = 255, .alpha = 255};
    
    //255 250 231
    tileColors[0][1] = (Color4B) { .red = 255, .blue = 250 , .green = 250, .alpha = 238};
    
    //    rgb 243 156 18
    tileColors[1][0] = (Color4B) { .red = 243, .green = 156 , .blue = 18, .alpha = 255};
    //    rgb 243 156 18
    tileColors[1][1] = (Color4B) { .red = 243, .green = 156 , .blue = 18, .alpha = 238};
    
    
    characterColors = (Color4B) { .red = 243, .green = 156 , .blue = 18, .alpha = 255};
    
    shadowColor = malloc(sizeof(Color4B));
    Color4fCopyS(transparentColor, shadowColor);
    
    currentTileColor = malloc(sizeof(Color4B)*2);
    currentCharacterColor = malloc(sizeof(Color4B));
    startAlphas = malloc(sizeof(CGFloat)*2);
    
    for (int c = 0;c<2;c++)
    {
        Color4fCopy(&(tileColors[1][c]), (currentTileColor+c));
        (currentTileColor+c)->alpha = 0.0;
    }
    
    Color4fCopy(&characterColors , currentCharacterColor);
    
}


-(void)draw
{
    for (int i = 0;i<6;i++)
    {
        Color4fCopyS(currentTileColor[colorIndex], (tileColorShader.colors+i+6));
        Color4fCopy(shadowColor, (shadowTextureShader.textureColors+i));
        Color4fCopy(currentCharacterColor, (characterTextureShader.textureColors+i+6));
    }
    
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager rotateByAngleInDegrees:wiggleAngle InX:0 Y:0 Z:1];
    [mvpMatrixManager translateInX:self.centerPoint.x Y:self.centerPoint.y Z:0];
    
    [tileColorShader draw];
    
    [characterTextureShader draw];
    [shadowTextureShader draw];

    [mvpMatrixManager popModelViewMatrix];
    
}

-(BOOL)animationUpdate:(Animation *)animation;
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
       if (shadowAlpha>= SHADOW_ALPHA_MAX)
           return YES;
        shadowAlpha = getEaseOut(SHADOW_ALPHA_MIN, SHADOW_ALPHA_MAX, animationRatio);
        shadowColor->alpha = shadowAlpha;
    }
    else if (animation.type == ANIMATION_HIDE_SHADOW)
    {
        if (shadowAlpha <= SHADOW_ALPHA_MIN)
            return YES;
        shadowAlpha = getEaseOut(SHADOW_ALPHA_MAX,SHADOW_ALPHA_MIN, animationRatio);
        shadowColor->alpha = shadowAlpha;
        
    }
    else if (animation.type == ANIMATION_WIGGLE)
    {
        wiggleAngle = getSineEaseOut(0, animationRatio, WIGGLE_ANGLE);
    }
    else if (animation.type == ANIMATION_SHOW_COLOR)
    {
        for (int c = 0;c<2;c++)
        {
            CGFloat alpha = getEaseIn(*(startAlphas+c), tileColors[1][c].alpha, animationRatio);
            (currentTileColor + c)->alpha = alpha;
        }
        
        CGFloat alpha = getEaseOut(characterStartAlpha, 0, animationRatio);
        currentCharacterColor->alpha = alpha;

    }
    else if (animation.type == ANIMATION_HIDE_COLOR)
    {
        
        for (int c = 0;c<2;c++)
        {
            CGFloat alpha = getEaseIn(*(startAlphas+c), 0, animationRatio);
            (currentTileColor + c)->alpha = alpha;
        }
        
        CGFloat alpha = getEaseOut(characterStartAlpha, 255, animationRatio);
        currentCharacterColor->alpha = alpha;

        
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
        
        if (isBonded == 1)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:self];
        }
        
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
        
        if (fabs(self.anchorPoint.y - self.centerPoint.y) > tileSquareSize/2)
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
    
    for (Tile *sq in _tilesArray)
    {
        if (sq == self)
            continue;
        
        CGRect sqAnchorRect = CGRectMake(sq.anchorPoint.x-tileSquareSize/2, sq.anchorPoint.y-tileSquareSize/2, tileSquareSize, tileSquareSize);
        
        CGRect selfAnchorRect = CGRectMake(self.centerPoint.x-tileSquareSize/2, self.centerPoint.y-tileSquareSize/2, tileSquareSize, tileSquareSize);
        
        CGRect intersection =  CGRectIntersection(sqAnchorRect, selfAnchorRect);
        CGFloat intersectionArea = intersection.size.height * intersection.size.width;
        
        if (intersectionArea >= tileSquareSize*tileSquareSize/2.0)
        {
            if (sq.isBonded == 1)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:sq];
            }
            
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
    else if (animation.type == ANIMATION_SHOW_COLOR||animation.type == ANIMATION_HIDE_COLOR)
    {
        for (int c = 0;c<2;c++)
        {
            *(startAlphas+c) = (currentTileColor + c)->alpha;
        }
        characterStartAlpha = currentCharacterColor->alpha;

    }
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE || animation.type == ANIMATION_THROW)
    {
        if (animation.type == ANIMATION_MOVE)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TileFinishedMoving" object:nil];
            
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
    if (isBonded == 1)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:self];
    }
    
    startPoint = self.centerPoint;
    endPoint = newPoint;
    [animator addAnimationFor:self ofType:ANIMATION_MOVE ofDuration:duration afterDelayInSeconds:0];
}

-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{

    if (isBonded == 1)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:self];
    }

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

-(void)animateShowColorInDuration:(CGFloat)duration
{
    if (isBonded == 0)
    {
        NSMutableArray *hideAnimations = [animator getRunningAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
        
        if (hideAnimations.count>0)
        {
            Animation *animation = hideAnimations[0];
            duration = [animation getAnimatedRatio]*duration;
            [animator removeRunningAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
        }
        [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
        
        [animator addAnimationFor:self ofType:ANIMATION_SHOW_COLOR ofDuration:duration afterDelayInSeconds:0];
        [hideAnimations release];
        isBonded = 1;
    }
}

-(void)animateHideColorInDuration:(CGFloat)duration
{
    NSMutableArray *showAnimations = [animator getRunningAnimationsForObject:self
                                                                      ofType:ANIMATION_SHOW_COLOR];
    
    if (showAnimations.count>0)
    {
        Animation *animation = showAnimations[0];
        duration = [animation getAnimatedRatio]*duration;
        [animator removeRunningAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    }
    [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    
    [animator addAnimationFor:self ofType:ANIMATION_HIDE_COLOR ofDuration:duration afterDelayInSeconds:0];
    isBonded = 0;
    [showAnimations release];

}

-(void)dealloc
{
    [super dealloc];
    free(shadowColor);
    free(currentCharacterColor);
    free(currentTileColor);
    free(startAlphas);
    self.tilesArray = nil;
}

@end