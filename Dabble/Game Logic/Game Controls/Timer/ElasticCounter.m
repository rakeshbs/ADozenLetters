//
//  ElasticCounter.m
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ElasticCounter.h"
#import "NSArray+Additions.h"

#define ANIMATION_COUNTUP 1
#define ANIMATION_WIGGLE 2
#define ANIMATION_COUNTDOWN 3
#define ANIMATION_SHOW 4
#define ANIMATION_HIDE 5

@implementation ElasticCounter

@synthesize sequence,vertexData,vertexDataCount,fontSpriteSheet,currentValue,alpha;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        previousVerticalOffset = 0;
        currentValue = 0;
        maskedVertices = malloc(sizeof(Vertex3D) * 6);
        maskedTextureCoords = malloc(sizeof(TextureCoord) * 6);
        alpha = 255;
        verticalOffset = 0;
    }
    return self;
}

-(BOOL)drawable
{
    return NO;
}

-(BOOL)touchable
{
    return NO;
}

-(void)setStringValueToCount:(NSString *)str inDuration:(CGFloat)duration
{
    int index = [sequence indexOfString:str];
    if (index > currentValue)
    {
        [self setValueCountUp:(index - currentValue)  withDuration:duration];
    }
    else
    {
        [self setValueCountDown:(currentValue - index) withDuration:duration];
    }
}

-(void)setValueCountUp:(CGFloat)value withDuration:(CGFloat)duration
{
    wiggleDistance = 0;
    [animator removeRunningAnimationsForObject:self];
    verticalOffset = currentValue * self.frame.size.height;
    loopCount = value;
    maxAngle = (1 + 0.01 * loopCount);
    if (maxAngle > 5)
        maxAngle = 5;
    previousVerticalOffset = verticalOffset;
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_COUNTUP ofDuration:duration afterDelayInSeconds:0];
}

-(void)setValueCountDown:(CGFloat)value withDuration:(CGFloat)duration
{
    wiggleDistance = 0;
    [animator removeRunningAnimationsForObject:self];
    
    verticalOffset = currentValue * self.frame.size.height;
    loopCount = value;
    maxAngle = -(1 + 0.01 * loopCount);
    if (maxAngle < -5)
        maxAngle = -5;
    previousVerticalOffset = verticalOffset;
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_COUNTDOWN ofDuration:duration afterDelayInSeconds:0];
}

-(void)showInDuration:(CGFloat)t
{
    [animator addAnimationFor:self ofType:ANIMATION_SHOW ofDuration:t afterDelayInSeconds:0];
}

-(void)hideInDuration:(CGFloat)t
{
    [animator addAnimationFor:self ofType:ANIMATION_HIDE ofDuration:0.05 afterDelayInSeconds:t-0.1];
}

-(void)setSequence:(NSMutableArray *)_sequence
{
    if (sequence)
    {
        [sequence release];
    }
    sequence = [_sequence retain];
    
}

//Animation Code

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_COUNTUP)
    {
        CGFloat c = loopCount * animationRatio;
        loopRatio = animationRatio;
        verticalOffset = previousVerticalOffset + c * (double)frame.size.height;
       [self calculateCurrentValue];
    }
    else if (animation.type == ANIMATION_COUNTDOWN)
    {
        CGFloat c = loopCount * animationRatio;
        loopRatio = animationRatio;
        verticalOffset = previousVerticalOffset - c * (double)frame.size.height;
       [self calculateCurrentValue];
    }
    else if (animation.type == ANIMATION_WIGGLE)
    {
        wiggleDistance = getSineEaseOutDamping(0, animationRatio, maxAngle,5);
    }
    else if (animation.type == ANIMATION_SHOW)
    {
        alpha = getEaseOut(0, 255.0, animationRatio);
    }
    else if (animation.type == ANIMATION_HIDE)
    {
        alpha = getEaseOut(255, 0.0, animationRatio);
    }
    
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}

-(void)stop
{
    [self calculateCurrentValue];
    verticalOffset = currentValue * self.frame.size.height;
    [animator removeRunningAnimationsForObject:self];
}
-(void)animationStarted:(Animation *)animation
{
    
}
-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_COUNTUP)
    {
        verticalOffset = previousVerticalOffset + loopCount * (double)frame.size.height;
        previousVerticalOffset = verticalOffset;
        [self calculateCurrentValue];
       [animator addAnimationFor:self ofType:ANIMATION_WIGGLE ofDuration:1.0 afterDelayInSeconds:0];
        
    }
    else if (animation.type == ANIMATION_COUNTDOWN)
    {
        verticalOffset = previousVerticalOffset - loopCount * (double)frame.size.height;
        previousVerticalOffset = verticalOffset;
        [self calculateCurrentValue];
        [animator addAnimationFor:self ofType:ANIMATION_WIGGLE ofDuration:1.0 afterDelayInSeconds:0];
        
    }
    else if (animation.type == ANIMATION_WIGGLE)
    {
        wiggleDistance = 0;
    }
}

-(void)calculateCurrentValue
{
    CGFloat totalLength = (sequence.count * self.frame.size.height);

    if (verticalOffset < 0)
    {
        verticalOffset -= floorf(verticalOffset/totalLength) * totalLength;
    }
    else
    {
        verticalOffset -= floorf(verticalOffset/totalLength) * totalLength;
    }
    currentValue = floorf(verticalOffset/self.frame.size.height);
    
}

// Drawing Code
-(void)draw
{
    vertexDataCount = 0;
    
    //[mvpMatrixManager pushModelViewMatrix];
    /*[mvpMatrixManager translateInX:frame.origin.x + frame.size.width/2
                                 Y:frame.origin.y + frame.size.height/2 Z:1];
    */
    
    [self addSpriteAtIndex:-1];
    [self addSpriteAtIndex:0];
    [self addSpriteAtIndex:1];
    
    //[mvpMatrixManager popModelViewMatrix];
    
}

-(void)addSpriteAtIndex:(int)sindex
{
    int currentIndex = floorf((verticalOffset+wiggleDistance)/frame.size.height);
    int index = (currentIndex - sindex + sequence.count)%sequence.count;
    CGFloat offsetY = (verticalOffset + wiggleDistance) - currentIndex * frame.size.height;
    
    FontSprite *fontSprite = [fontSpriteSheet getFontSprite:sequence[index]];
    
    CGFloat maxY = self.frame.size.height/2;
    CGFloat minY = -self.frame.size.height/2;
    
    CGFloat bottomYFont = offsetY - fontSprite.textureCGRect.size.height/2;
    CGFloat topYFont = offsetY + fontSprite.textureCGRect.size.height/2;
    
    bottomYFont += sindex * frame.size.height;
    topYFont += sindex * frame.size.height;
    
    CGFloat bottomCoordinateFont = bottomYFont;
    CGFloat topCoordinateFont = topYFont;
    
    
    if (!(bottomYFont > maxY || topYFont < minY))
    {
        if (bottomYFont < minY)
            bottomCoordinateFont = minY;
        
        if (topYFont > maxY)
            topCoordinateFont = maxY;
    }
    else
        return;
    
    CGRect maskedFontRect = CGRectMake(fontSprite.textureCGRect.origin.x, bottomCoordinateFont, fontSprite.textureCGRect.size.width, topCoordinateFont - bottomCoordinateFont);
    CGRectToVertex3D(maskedFontRect, maskedVertices);
    
    
    
    CGFloat bottomRatio = (bottomCoordinateFont - bottomYFont)/fontSprite.height;
    CGFloat topRatio = (topYFont - topCoordinateFont)/fontSprite.height;
    
    CGRect maskedTextureCoordCGRect = [self getMaskedTexCoordsForFontSprite:fontSprite andBottomRatio:bottomRatio andTopRatio:topRatio];
    
    CGRectToTextureCoord(maskedTextureCoordCGRect, maskedTextureCoords);
    
    Matrix3D result;
    [mvpMatrixManager getMVPMatrix:result];
    
    for (int j = 0;j<6;j++)
    {
        memcpy(&((vertexData + vertexDataCount)->mvpMatrix), result, sizeof(Matrix3D));
        (vertexData + vertexDataCount)->vertex = maskedVertices[j];
        (vertexData + vertexDataCount)->color = _color;
        (vertexData + vertexDataCount)->color.alpha = alpha;
        (vertexData + vertexDataCount)->texCoord = maskedTextureCoords[j];
        vertexDataCount++;
    }
    
}

-(CGRect)getMaskedTexCoordsForFontSprite:(FontSprite *)fontSprite
                          andBottomRatio:(CGFloat)bottomRatio andTopRatio:(CGFloat)topRatio
{
    CGRect texCoordRect = fontSprite.textureCoordinatesCGRect;
    
    CGFloat textureTop = texCoordRect.origin.y + 2 * topRatio * texCoordRect.size.height;
    CGFloat textureBottom = texCoordRect.origin.y + (1.0 - 2 * bottomRatio) * texCoordRect.size.height;
    
    return CGRectMake(texCoordRect.origin.x, textureTop,
                      texCoordRect.size.width, textureBottom - textureTop);
    
}


-(void)dealloc
{
 
    free(vertexData);
    free(maskedVertices);
       [super dealloc];
}


@end
