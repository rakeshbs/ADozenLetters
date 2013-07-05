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

@synthesize sequence;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        textureShaderProgram = [shaderManager getShaderByVertexShaderFileName:@"InstancedTextureShader" andFragmentShaderFileName:@"TextureShader"];
        
        
        ATTRIB_TEXTURE_MVPMATRIX = [textureShaderProgram attributeIndex:@"mvpmatrix"];
        ATTRIB_TEXTURE_VERTEX = [textureShaderProgram attributeIndex:@"vertex"];
        ATTRIB_TEXTURE_COLOR = [textureShaderProgram attributeIndex:@"textureColor"];
        ATTRIB_TEXTURE_TEXCOORDS = [textureShaderProgram attributeIndex:@"textureCoordinate"];
        
        
        currentValue = 0;
        vertexData = malloc(sizeof(InstancedTextureVertexColorData) * 6 * 6);
        maskedVertices = malloc(sizeof(Vertex3D) * 6);
        maskedTextureCoords = malloc(sizeof(TextureCoord) * 6);
        
        glGenBuffers(1, &textureBuffer);
        
        verticalOffset = 0;
    }
    return self;
}

-(void)setFont:(NSString *)font withSize:(CGFloat)size
{
    fontSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeNumbers withFont:font andSize:size];
}

-(void)setValue:(int)value
{
    int vIndex = [sequence indexOfString:[NSString stringWithFormat:@"%d",value]];
    destinationVerticalOffset = frame.size.height * vIndex;
    previousVerticalOffset = verticalOffset;
    while (verticalOffset > destinationVerticalOffset)
        destinationVerticalOffset += sequence.count * frame.size.height;
    
    currentValue = value;
    
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_COUNTUP ofDuration:2 afterDelayInSeconds:0];
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
        verticalOffset = getEaseOutElastic(previousVerticalOffset, destinationVerticalOffset, animationRatio,animation.duration);
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
         if (currentValue == 9)
         {
             [self setValue:5];
         }
         else
             [self setValue:9];
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
    
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    [textureShaderProgram use];
    
    glBindBuffer(GL_ARRAY_BUFFER, textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexDataCount * sizeof(InstancedTextureVertexColorData), vertexData, GL_DYNAMIC_DRAW);
    [fontSpriteSheet.texture bindTexture];
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_TEXCOORDS);
    glVertexAttribPointer(ATTRIB_TEXTURE_TEXCOORDS, 2, GL_FLOAT, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTURE_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(TextureCoord));
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_COLOR);
    glVertexAttribPointer(ATTRIB_TEXTURE_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D)+sizeof(TextureCoord));
    
    
    glDrawArrays(GL_TRIANGLES, 0, vertexDataCount);
    
    [mvpMatrixManager popModelViewMatrix];
    
    //verticalOffset++;
    
    glDisable(GL_TEXTURE_2D);

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
