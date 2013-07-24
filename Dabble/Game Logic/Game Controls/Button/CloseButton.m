//
//  CloseButton.m
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "CloseButton.h"

@implementation CloseButton

#define ANIMATION_HIGHLIGHT 1
#define ANIMATION_NORMAL 2

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        textColor = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 255};
        backgroundColor = (Color4B){.red = 128,.green = 128,.blue = 128,.alpha = 85};
        
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
       
        buttonTextTexture = [textureManager getStringTexture:@"x" dimensions:CGSizeMake(self.frame.size.width, self.frame.size.height) horizontalAlignment:UITextAlignmentCenter verticalAlignment:UITextAlignmentMiddle fontName:@"Lato" fontSize:45];
        
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);
        
        Vertex3D *texVertices = [buttonTextTexture getTextureVertices];
        TextureCoord *texCoords = [buttonTextTexture getTextureCoordinates];
        for (int i = 0;i<6;i++)
        {
            textureVertexColorData[i].vertex = texVertices[i];
            textureVertexColorData[i].texCoord = texCoords[i];
            textureVertexColorData[i].color = textColor;
        }
        
    }
    return self;
}

-(int)numberOfLayers
{
    return 2;
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
        CGFloat alpha = getEaseOut(startColor->alpha, endColor->alpha, animationRatio);
        for (int i = 0;i<6;i++)
        {
            vertexColorData[i].color.red = red;
            vertexColorData[i].color.green = green;
            vertexColorData[i].color.blue = blue;
            vertexColorData[i].color.alpha = alpha;
        }
    }
    else if (animation.type == ANIMATION_NORMAL)
    {
        Color4B *startColor = [animation getStartValue];
        Color4B *endColor = [animation getEndValue];
        
        
        CGFloat red = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat green = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat blue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        CGFloat alpha = getEaseOut(startColor->alpha, endColor->alpha, animationRatio);
        for (int i = 0;i<6;i++)
        {
            vertexColorData[i].color.red = red;
            vertexColorData[i].color.green = green;
            vertexColorData[i].color.blue = blue;
            vertexColorData[i].color.alpha = alpha;
        }
    }
    
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_HIGHLIGHT)
    {
        [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_FINISHED];
        [self.touchesInElement removeAllObjects];
        
        Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
        [animation setStartValue:&vertexColorData[0].color OfSize:sizeof(Color4B)];
        [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
        
    }
}


-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:1.3 afterDelayInSeconds:0];
    [animation setStartValue:&vertexColorData[0].color OfSize:sizeof(Color4B)];
    [animation setEndValue:&textColor OfSize:sizeof(Color4B)];
    
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_STARTED];
}

-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{

    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&vertexColorData[0].color OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
   
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_CANCELLED];
}

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&vertexColorData[0] OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
    
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_CANCELLED];
    
}

-(void)draw
{
    [colorRenderer drawWithArray:vertexColorData andCount:6];
    [mvpMatrixManager translateInX:self.frame.size.width/2 Y:self.frame.size.height/2 Z:1];
    textureRenderer.texture = buttonTextTexture;
    [textureRenderer drawWithArray:textureVertexColorData andCount:6];
        [mvpMatrixManager translateInX:-self.frame.size.width/2 Y:-self.frame.size.height/2 Z:0];
}

-(void)dealloc
{
    self.delegate = nil;
    free(vertexColorData);
    free(textureVertexColorData);
    [super dealloc];
}

@end
