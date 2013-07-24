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
#import "GLScene.h"
#import "SoundManager.h"
#import "TileControl.h"

#define ANIMATION_MOVE 1
#define ANIMATION_WIGGLE 2
#define ANIMATION_SHOW_SHADOW 3
#define ANIMATION_HIDE_SHADOW 4
#define ANIMATION_QUEUE_MOVE 5
#define ANIMATION_SHOW_COLOR 6
#define ANIMATION_HIDE_COLOR 7
#define ANIMATION_THROW 8
#define ANIMATION_MAKE_SHADOW_VISIBLE 9




#define SHADOW_ALPHA_MAX 255
#define SHADOW_ALPHA_MIN 0
#define WIGGLE_ANGLE 10.0f
#define REDCOLOR_MIN 0.01f
#define REDCOLOR_MAX 1.0f

#define NUMBEROFSCORES 7

@implementation Tile

@synthesize character,anchorPoint,colorIndex,isBonded;//characterFontSprite,scoreTexture,shadowTexture;

@synthesize currentTileColor,currentCharacterColor,shadowColor,wiggleAngle,score,characterCounter;

SoundManager *soundManager;

int letterScores[NUMBEROFSCORES] = {1,2,3,4,5,7,9};
NSString *lettersPerScore[NUMBEROFSCORES]= {@"AEIOULNRST",@"DG",@"BCMP",@"FHVWY",@"K",@"JX",@"QZ"};
NSString *fontStr =  @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
NSArray *charactersArray;

-(CGRect)frame
{
    return CGRectMake(self.centerPoint.x-tileSquareSize/2, (self.centerPoint.y - tileSquareSize/2), tileSquareSize, tileSquareSize);
    
}

-(TileControl *)tileControl
{
    return (TileControl *)self.parent;
}

-(BOOL)isDrawable
{
    return NO;
}

-(int)numberOfLayers
{
    return 6;
}


-(id)init
{
    if (self = [super init])
    {
        isColorAnimating = NO;
        startAngle = 0;
        wiggleAngle = 0;
        shadowAlpha = 0;
        isBonded = 0;
        shadowVisible = NO;
        charactersArray = [[fontStr componentsSeparatedByString:@","]retain];
        characterCounter = [[ElasticCounter alloc]initWithFrame:CGRectMake(0, 0, tileSquareSize, 49)];
        [characterCounter setSequence:charactersArray];
        isBondedColor = NO;
    }
    
    return self;
}

-(void)setTileCharacter:(NSString *)_character
{
    self.character = _character;
    [characterCounter setStringValueToCount:character inDuration:0.8];
}

-(void)setupSounds
{
    soundManager = [SoundManager sharedSoundManager];
    [soundManager loadSoundWithKey:@"pick" soundFile:@"bip1.aiff"];
    [soundManager loadSoundWithKey:@"place" soundFile:@"bip2.aiff"];
    
}


-(void)setupColors
{
    
    Color4B characterColors = (Color4B) { .red = 0, .green = 0 , .blue = 0, .alpha = 255};
    
    shadowColor = malloc(sizeof(Color4B));
    *shadowColor = (Color4B) {.red = 255, .green = 255, .blue = 255, .alpha = 0};
    
    currentTileColor = malloc(sizeof(Color4B)*2);
    currentCharacterColor = malloc(sizeof(Color4B));
    startTileColors = malloc(sizeof(Color4B)*2);
    
    for (int c = 0;c<2;c++)
    {
        TileControl *tC = (TileControl *)self.parent;
        Color4B tileColor = [tC getColorForState:0 andColorIndex:c];
        Color4fCopy(&tileColor, (currentTileColor+c));
    }
    
    Color4fCopy(&characterColors , currentCharacterColor);
    characterCounter.color = *currentCharacterColor;
}

-(BOOL)animationUpdate:(Animation *)animation;
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    if (animation.type == ANIMATION_MOVE)
    {
        CGPoint *startValue = ((CGPoint *)[animation getStartValue]);
        CGPoint *endValue = ((CGPoint *)[animation getEndValue]);
        
        CGFloat newX = getEaseOutBack(startValue->x, endValue->x, animationRatio);
        CGFloat newY = getEaseOutBack(startValue->y, endValue->y, animationRatio);
        
        _centerPoint = CGPointMake(newX, newY);
    }
    else if (animation.type == ANIMATION_THROW)
    {
        CGPoint *startValue = ((CGPoint *)[animation getStartValue]);
        CGPoint *endValue = ((CGPoint *)[animation getEndValue]);
        
        CGFloat newX = getEaseOutBack(startValue->x, endValue->x, animationRatio);
        CGFloat newY = getEaseOutBack(startValue->y, endValue->y, animationRatio);
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
            Color4B tileColor = [self.tileControl getColorForState:1 andColorIndex:c];
            
            (currentTileColor + c)->red = getEaseIn((startTileColors+c)->red, tileColor.red, animationRatio);
            (currentTileColor + c)->green = getEaseIn((startTileColors+c)->green, tileColor.green, animationRatio);
            (currentTileColor + c)->blue = getEaseIn((startTileColors+c)->blue, tileColor.blue, animationRatio);
            (currentTileColor + c)->alpha = getEaseIn((startTileColors+c)->alpha, tileColor.alpha, animationRatio);
            
        }
        
        Color4B charColor = [self.tileControl getColorForState:0 andColorIndex:0];
        
        
        currentCharacterColor->red  = getEaseIn(startCharacterColor.red, charColor.red, animationRatio);
        currentCharacterColor->green = getEaseIn(startCharacterColor.green, charColor.green, animationRatio);
        currentCharacterColor->blue = getEaseIn(startCharacterColor.blue, charColor.blue, animationRatio);
        currentCharacterColor->alpha = getEaseIn(startCharacterColor.alpha, charColor.alpha, animationRatio);
        
        characterCounter.color = *currentCharacterColor;
        
    }
    else if (animation.type == ANIMATION_HIDE_COLOR)
    {
        for (int c = 0;c<2;c++)
        {
            Color4B tileColor = [self.tileControl getColorForState:0 andColorIndex:c];
            
            (currentTileColor + c)->red = getEaseIn((startTileColors+c)->red, tileColor.red, animationRatio);
            (currentTileColor + c)->green = getEaseIn((startTileColors+c)->green, tileColor.green, animationRatio);
            (currentTileColor + c)->blue = getEaseIn((startTileColors+c)->blue, tileColor.blue, animationRatio);
            (currentTileColor + c)->alpha = getEaseIn((startTileColors+c)->alpha, tileColor.alpha, animationRatio);
            
        }
        
        Color4B charColor = [self.tileControl getColorForState:1 andColorIndex:0];
        
        
        currentCharacterColor->red  = getEaseIn(startCharacterColor.red, charColor.red, animationRatio);
        currentCharacterColor->green = getEaseIn(startCharacterColor.green, charColor.green, animationRatio);
        currentCharacterColor->blue = getEaseIn(startCharacterColor.blue, charColor.blue, animationRatio);
        currentCharacterColor->alpha = getEaseIn(startCharacterColor.alpha, charColor.alpha, animationRatio);
        
                characterCounter.color = *currentCharacterColor;
        
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
        int countShadow = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_MAKE_SHADOW_VISIBLE];
        
        int totatCount = countMove+countWiggle+countThrow+countShadow;
        
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
        int countShadow = [animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_MAKE_SHADOW_VISIBLE];
        
        int totatCount = countMove+countWiggle+countThrow+countShadow;
        
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
        CGPoint touchPoint = [touch locationInGLElement:self];
        
        wiggleAngle = 0;
        [self moveToFront];
        
        [animator removeQueuedAnimationsForObject:self];
        [animator removeRunningAnimationsForObject:self];
        
        if (isBonded == 1)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:self];
        }
        
        [self updateShadow];
        
        prevTouchPoint = touchPoint;
    }
}


-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    if (index == 0)
    {
       CGPoint touchPoint = [touch locationInGLElement:self];
        
        CGFloat diffX = touchPoint.x - prevTouchPoint.x;
        CGFloat diffY = touchPoint.y - prevTouchPoint.y;
        
        
        self.centerPoint =  CGPointMake(self.centerPoint.x + diffX, self.centerPoint.y + diffY);
        
        [self moveToFront];
    
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
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.3];
        }
        else
        {
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.3];
        }
        [self updateShadow];
    }
}

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
 	if (index == 0)
    {
        
        [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_QUEUE_MOVE];
        [self checkCollissionAndMove];
        
        if (touch.tapCount >= 1)
        {
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.3];
        }
        else
        {
            [self moveToPoint:CGPointMake(self.anchorPoint.x ,  self.anchorPoint.y) inDuration:0.3];
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
                [sq moveToPoint:sq.anchorPoint inDuration:0.3];
                
            }
        }
        
    }
}

-(void)resetToAnchorPoint
{
    if (!CGPointEqualToPoint(self.centerPoint, self.anchorPoint))
    {
        [self moveToPoint:self.anchorPoint inDuration:0.3];
    }
}

-(void)animationStarted:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE
        || animation.type == ANIMATION_THROW ||animation.type == ANIMATION_MAKE_SHADOW_VISIBLE)
    {
        if (animation.type == ANIMATION_THROW || animation.type == ANIMATION_MOVE)
        {
            [animation setStartValue:&_centerPoint OfSize:sizeof(CGPoint)];
        }
        
        if (animation.type == ANIMATION_THROW)
        {
           // [self moveToBack];
        }
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
            *(startTileColors + c) = *(currentTileColor + c);
        }
        startCharacterColor = *currentCharacterColor;
        
        isColorAnimating = YES;
    }
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_WIGGLE ||
        animation.type == ANIMATION_THROW ||animation.type == ANIMATION_MAKE_SHADOW_VISIBLE)
    {
        if (animation.type == ANIMATION_MOVE || animation.type == ANIMATION_THROW)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"TileFinishedMoving" object:nil];
            
        }
        
        [self updateShadow];
    }
    else if (animation.type == ANIMATION_SHOW_COLOR)
    {
        isColorAnimating = NO;
        isBondedColor = YES;
    }
    else if (animation.type == ANIMATION_HIDE_COLOR)
    {
        isColorAnimating = NO;
        isBondedColor = NO;
    }
}

-(void)showShadowFor:(CGFloat)duration afterDelay:(CGFloat)delay
{
    [animator addAnimationFor:self ofType:ANIMATION_MAKE_SHADOW_VISIBLE ofDuration:duration afterDelayInSeconds:delay];
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
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_MOVE ofDuration:duration afterDelayInSeconds:0];
    [animation setStartValue:&_centerPoint OfSize:sizeof(CGPoint)];
    [animation setEndValue:&newPoint OfSize:sizeof(CGPoint)];
}

-(void)moveToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{
    
    if (isBonded == 1)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TileBreakBond" object:self];
    }
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_MOVE ofDuration:duration afterDelayInSeconds:delay];
    [animation setStartValue:&_centerPoint OfSize:sizeof(CGPoint)];
    [animation setEndValue:&newPoint OfSize:sizeof(CGPoint)];
}

-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration
{
 //   startPoint = self.centerPoint;
   // endPoint = newPoint;
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_THROW
                                          ofDuration:duration afterDelayInSeconds:0];
    [animation setStartValue:&_centerPoint OfSize:sizeof(CGPoint)];
    [animation setEndValue:&newPoint OfSize:sizeof(CGPoint)];
}

-(void)throwToPoint:(CGPoint)newPoint inDuration:(CGFloat)duration afterDelay:(CGFloat)delay
{
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_THROW
                                          ofDuration:duration afterDelayInSeconds:delay];
    [animation setStartValue:&_centerPoint OfSize:sizeof(CGPoint)];
    [animation setEndValue:&newPoint OfSize:sizeof(CGPoint)];}

-(void)animateShowColorInDuration:(CGFloat)duration
{
    isBonded = YES;
    NSMutableArray *hideAnimations = [animator getRunningAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
    
    if (hideAnimations.count>0)
    {
        Animation *animation = hideAnimations[0];
        duration = [animation getAnimatedRatio]*duration;
        [animator removeRunningAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
    }
    [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
    [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    [animator removeRunningAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    
    [animator addAnimationFor:self ofType:ANIMATION_SHOW_COLOR ofDuration:duration afterDelayInSeconds:0];
}

-(void)animateHideColorInDuration:(CGFloat)duration
{
    NSMutableArray *showAnimations = [animator getRunningAnimationsForObject:self
                                                                      ofType:ANIMATION_SHOW_COLOR];
    
    isBonded = NO;
    if (showAnimations.count>0)
    {
        Animation *animation = showAnimations[0];
        duration = [animation getAnimatedRatio]*duration;
        [animator removeRunningAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    }
    [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_SHOW_COLOR];
    [animator removeQueuedAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
    [animator removeRunningAnimationsForObject:self ofType:ANIMATION_HIDE_COLOR];
    
    
    [animator addAnimationFor:self ofType:ANIMATION_HIDE_COLOR ofDuration:duration afterDelayInSeconds:0];
    
    
}

-(NSString *)description
{
    return character;
}

-(void)dealloc
{
    free(shadowColor);
    free(currentCharacterColor);
    free(currentTileColor);
    free(startTileColors);
    self.tilesArray = nil;
       [super dealloc];
}

@end
