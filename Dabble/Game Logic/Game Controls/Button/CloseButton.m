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
        backgroundColor = (Color4B){.red = 0,.green = 0,.blue = 0,.alpha = 64};
        
        colorRenderer = [rendererManager getRendererWithVertexShaderName:@"ColorShader" andFragmentShaderName:@"ColorShader"];
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"TextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        self.frameBackgroundColor = backgroundColor;
        
        buttonTextTexture = [textureManager getTexture:@"close" OfType:@"png"];
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);
        
        Vertex3D *texVertices = [buttonTextTexture getTextureVertices];
        TextureCoord *texCoords = [buttonTextTexture getTextureCoordinates];
        for (int i = 0;i<6;i++)
        {
            textureVertexColorData[i].vertex = texVertices[i];
            textureVertexColorData[i].texCoord = texCoords[i];
            textureVertexColorData[i].color = textColor;
        }
        
        soundManager = [SoundManager sharedSoundManager];
    /*    [soundManager loadSoundWithKey:@"closeon" soundFile:@"close_button_highlight.aiff"];
        [soundManager loadSoundWithKey:@"closeoff" soundFile:@"close_button_unhighlight.aiff"];*/
        
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
        
        self.frameBackgroundColor = (Color4B){red,green,blue,alpha};
    }
    else if (animation.type == ANIMATION_NORMAL)
    {
        Color4B *startColor = [animation getStartValue];
        Color4B *endColor = [animation getEndValue];
        
        
        CGFloat red = getEaseOut(startColor->red, endColor->red, animationRatio);
        CGFloat green = getEaseOut(startColor->green, endColor->green, animationRatio);
        CGFloat blue = getEaseOut(startColor->blue, endColor->blue, animationRatio);
        CGFloat alpha = getEaseOut(startColor->alpha, endColor->alpha, animationRatio);
        
        self.frameBackgroundColor = (Color4B){red,green,blue,alpha};
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
        
        self.touchable = NO;
        
        Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
        [animation setStartValue:&frameBackgroundColor OfSize:sizeof(Color4B)];
        [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
        
    }
}


-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:1.3 afterDelayInSeconds:0];
    [animation setStartValue:&frameBackgroundColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&textColor OfSize:sizeof(Color4B)];
    
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_STARTED];
/*    [soundManager playSoundWithKey:@"closeon" gain:1.0f
                             pitch:0.0f
                          location:CGPointZero
                        shouldLoop:NO];*/
}

-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{

    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&frameBackgroundColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
   
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_CANCELLED];
}

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator removeRunningAnimationsForObject:self];
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    [animation setStartValue:&frameBackgroundColor OfSize:sizeof(Color4B)];
    [animation setEndValue:&backgroundColor OfSize:sizeof(Color4B)];
    
    [self.delegate closeButtonClick:CLOSEBUTTON_CLICK_CANCELLED];
}

-(void)draw
{
    [mvpMatrixManager translateInX:self.frame.size.width/2 Y:self.frame.size.height/2 Z:1];
    textureRenderer.texture = buttonTextTexture;
    [textureRenderer drawWithArray:textureVertexColorData andCount:6];
        [mvpMatrixManager translateInX:-self.frame.size.width/2 Y:-self.frame.size.height/2 Z:0];
}

-(void)dealloc
{
    self.delegate = nil;
    free(textureVertexColorData);
    [super dealloc];
}

@end
