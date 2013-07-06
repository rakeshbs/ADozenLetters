//
//  ElasticCounter.m
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ElasticNumericCounter.h"
#import "NSArray+Additions.h"

#define ANIMATION_COUNTUP 1

@implementation ElasticNumericCounter

@synthesize sequence,vertexData,vertexDataCount,fontSpriteSheet;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        
        
        currentValue = 0;
        
        maskedVertices = malloc(sizeof(Vertex3D) * 6);
        maskedTextureCoords = malloc(sizeof(TextureCoord) * 6);
        
        
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

-(void)setFont:(NSString *)font withSize:(CGFloat)size
{
    fontSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeNumbers withFont:font andSize:size];
}

-(void)setValueCountUp:(int)value
{
    int vIndex = [sequence indexOfString:[NSString stringWithFormat:@"%d",value]];
    destinationVerticalOffset = frame.size.height * vIndex;
    previousVerticalOffset = verticalOffset;
    while (verticalOffset > destinationVerticalOffset)
        destinationVerticalOffset += sequence.count * frame.size.height;
    
    currentValue = value;
    
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_COUNTUP ofDuration:0.5 afterDelayInSeconds:1];
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
        verticalOffset = getEaseOutBack(previousVerticalOffset, destinationVerticalOffset, animationRatio);
    }
    
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}
-(void)animationStarted:(Animation *)animation
{
    
}
-(void)animationEnded:(Animation *)animation
{
     if (animation.type == ANIMATION_COUNTUP)
     {
         
             [self setValueCountUp:currentValue+1];
     }
}



// Drawing Code
-(void)draw
{
    CGFloat totalLength = (sequence.count * self.frame.size.height);
    while (verticalOffset < 0)
        verticalOffset += totalLength;
    while (verticalOffset >= totalLength)
        verticalOffset -=totalLength;
    vertexDataCount = 0;
    
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:frame.size.width/2 Y: frame.size.height/2 Z:1];
    
    [self addSpriteAtIndex:-1];
    [self addSpriteAtIndex:0];
    [self addSpriteAtIndex:1];
    

}

-(void)addSpriteAtIndex:(int)sindex
{
    int currentIndex = floorf(verticalOffset/frame.size.height);
    int index = (currentIndex - sindex + sequence.count)%sequence.count;
    CGFloat offsetY = verticalOffset - currentIndex * frame.size.height;
    
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
    CGFloat topRatio = (topCoordinateFont - topYFont)/fontSprite.height;
    
    CGRect maskedTextureCoordCGRect = [self getMaskedTexCoordsForFontSprite:fontSprite andBottomRatio:bottomRatio andTopRatio:topRatio];
    
    CGRectToTextureCoord(maskedTextureCoordCGRect, maskedTextureCoords);
    
    Matrix3D result;
    [mvpMatrixManager getMVPMatrix:result];
    
    for (int j = 0;j<6;j++)
    {
        memcpy(&((vertexData + vertexDataCount)->mvpMatrix), result, sizeof(Matrix3D));
        (vertexData + vertexDataCount)->vertex = maskedVertices[j];
        (vertexData + vertexDataCount)->color =
        (Color4B) {.red=255,.green = 255,.blue = 255, .alpha = 255 };
        (vertexData + vertexDataCount)->texCoord = maskedTextureCoords[j];
        vertexDataCount++;
    }
    
}

-(CGRect)getMaskedTexCoordsForFontSprite:(FontSprite *)fontSprite
                          andBottomRatio:(CGFloat)bottomRatio andTopRatio:(CGFloat)topRatio
{
    CGRect texCoordRect = fontSprite.textureCoordinatesCGRect;
 
    CGFloat textureTop = texCoordRect.origin.y;
    CGFloat textureBottom = texCoordRect.origin.y + texCoordRect.size.height;
    
    textureTop -=  topRatio;
    textureBottom -= bottomRatio;
    
    return CGRectMake(texCoordRect.origin.x, textureTop,
                      texCoordRect.size.width, textureBottom - textureTop);
    
}

-(void)dealloc
{
    [super dealloc];
    free(vertexData);
    free(maskedVertices);
}


@end
