//
//  GLButton.m
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLButton.h"

#define ANIMATION_HIGHLIGHT 1
#define ANIMATION_NORMAL 2


@implementation GLButton

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        textColor = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 255};
        backgroundColor = (Color4B){.red = 0,.green = 0,.blue = 0,.alpha = 128};
        
        colorRenderer = [rendererManager getRendererWithVertexShaderName:@"ColorShader" andFragmentShaderName:@"ColorShader"];
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"TextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        vertexColorData = malloc(sizeof(VertexColorData) * 6);
        vertexColorData[0].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        vertexColorData[1].vertex = (Vertex3D){.x = _frame.size.width, .y = 0, .z = 0};
        vertexColorData[2].vertex = (Vertex3D){.x = _frame.size.width, .y = _frame.size.height, .z = 0};
        vertexColorData[3].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        vertexColorData[4].vertex = (Vertex3D){.x = 0, .y = _frame.size.height, .z = 0};
        vertexColorData[5].vertex = (Vertex3D){.x = _frame.size.width, .y = _frame.size.height, .z = 0};
        for (int i = 0;i<6;i++)
        {
            vertexColorData[i].color = backgroundColor;
        }
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);   
    }
    return self;
}

-(void)setText:(NSString *)text withFont:(NSString *)font andSize:(CGFloat)size
{
    UIFont *bFont = [UIFont fontWithName:font size:size];

    
    buttonTextTexture = [textureManager getStringTexture:text dimensions:[text sizeWithFont:bFont]
                                     horizontalAlignment:UITextAlignmentCenter
                                       verticalAlignment:UITextAlignmentMiddle
                                                fontName:font fontSize:size];
    [buttonTextTexture generateMipMap];
    
    TextureCoord *texCoord = [buttonTextTexture getTextureCoordinates];
    Vertex3D *vertices = [buttonTextTexture getTextureVertices];
    
    for (int i = 0;i < 6;i++)
    {
        textureVertexColorData[i].vertex = vertices[i];
        textureVertexColorData[i].texCoord = texCoord[i];
        textureVertexColorData[i].color = textColor;
    }
}

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_HIGHLIGHT)
    {
        Color4B *startColor = [animation getStartValue];
        Color4B *endColor = [animation getEndValue];
      
        CGFloat red = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat green = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat blue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        
        startColor =[animation getEndValue];
        endColor = [animation getStartValue];
        
        CGFloat tred = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat tgreen = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat tblue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        
        
        Color4B intermediate = (Color4B){.red = red, .green = green, .blue = blue,.alpha = vertexColorData[0].color.alpha};
        Color4B tintermediate = (Color4B){.red = tred, .green = tgreen, .blue = tblue,.alpha = textureVertexColorData[0].color.alpha};
        
        for (int i = 0;i < 6;i++)
        {
            textureVertexColorData[i].color = tintermediate;
            vertexColorData[i].color = intermediate;
        }
    }
    else if (animation.type == ANIMATION_NORMAL)
    {
        Color4B *startColor = [animation getStartValue];
        Color4B *endColor = [animation getEndValue];
        
        CGFloat red = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat green = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat blue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        
        startColor =[animation getEndValue];
        endColor = [animation getStartValue];
        
        CGFloat tred = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat tgreen = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat tblue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        
        
        Color4B intermediate = (Color4B){.red = red, .green = green, .blue = blue,.alpha = vertexColorData[0].color.alpha};
        Color4B tintermediate = (Color4B){.red = tred, .green = tgreen, .blue = tblue,.alpha = textureVertexColorData[0].color.alpha};
        
        for (int i = 0;i < 6;i++)
        {
            textureVertexColorData[i].color = tintermediate;
            vertexColorData[i].color = intermediate;
        }

    }
    
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}

-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&backgroundColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&textColor OfSize:sizeof(Color4B)];

}

-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&textColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
    
    [_target performSelector:_selector];
    
}

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&textColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
    
}

-(void)addTarget:(NSObject *)target andSelector:(SEL)selector
{
    self.target = target;
    self.selector = selector;
}

-(void)setBackgroundColor:(Color4B)_color
{
    backgroundColor = _color;
    for (int i = 0;i < 6;i++)
    {
        vertexColorData[i].color = textColor;
    }
}

-(void)setTextColor:(Color4B)_color
{
    textColor = _color;
    for (int i = 0;i < 6;i++)
    {
        textureVertexColorData[i].color = backgroundColor;
    }
}

-(void)draw
{
    [colorRenderer drawWithArray:vertexColorData andCount:6];
    [mvpMatrixManager translateInX:self.frame.size.width/2 Y:self.frame.size.height/2 Z:1];
    if (buttonTextTexture != nil)
    {
        textureRenderer.texture = buttonTextTexture;
        [textureRenderer drawWithArray:textureVertexColorData andCount:6];
    }
    [mvpMatrixManager translateInX:-self.frame.size.width/2 Y:-self.frame.size.height/2 Z:0];
}

-(void)dealloc
{
    self.target = nil;
    free(vertexColorData);
    free(textureVertexColorData);
    [super dealloc];
}

@end
