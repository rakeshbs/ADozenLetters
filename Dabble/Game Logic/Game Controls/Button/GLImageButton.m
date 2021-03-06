//
//  GLButton.m
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLImageButton.h"

#define ANIMATION_HIGHLIGHT 1
#define ANIMATION_NORMAL 2


@implementation GLImageButton

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        imageColor = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 255};
        backgroundColor = (Color4B){.red = 0,.green = 0,.blue = 0,.alpha = 128};
        backgroundHightlightColor = imageColor;
        imageHighlightColor = backgroundColor;
        
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"TextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);
        
        soundManager = [SoundManager sharedSoundManager];
        [soundManager loadSoundWithKey:@"button_highlight" soundFile:@"play_button_tap.aiff"];
        
        
    }
    return self;
}

-(void)setImage:(NSString *)imageName ofType:(NSString *)type
{
    buttonTexture = [textureManager getTexture:imageName OfType:type];
    [buttonTexture generateMipMap];
    
    TextureCoord *texCoord = [buttonTexture getTextureCoordinates];
    Vertex3D *vertices = [buttonTexture getTextureVertices];
    
    for (int i = 0;i < 6;i++)
    {
        textureVertexColorData[i].vertex = vertices[i];
        textureVertexColorData[i].texCoord = texCoord[i];
        textureVertexColorData[i].color = imageColor;
    }
}

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_HIGHLIGHT)
    {
        
        CGFloat red = getEaseOut(backgroundColor.red, backgroundHightlightColor.red, animationRatio);
        CGFloat green = getEaseOut(backgroundColor.green, backgroundHightlightColor.green, animationRatio);
        CGFloat blue = getEaseOut(backgroundColor.blue, backgroundHightlightColor.blue, animationRatio);
        CGFloat alpha = getEaseOut(backgroundColor.alpha, backgroundHightlightColor.alpha, animationRatio);
        
        
        
        CGFloat tred = getEaseOut(imageColor.red, imageHighlightColor.red, animationRatio);
        CGFloat tgreen = getEaseOut(imageColor.green, imageHighlightColor.green, animationRatio);
        CGFloat tblue = getEaseOut(imageColor.blue, imageHighlightColor.blue, animationRatio);
        
        
        Color4B intermediate = (Color4B){.red = red, .green = green, .blue = blue,.alpha =  alpha};
        Color4B tintermediate = (Color4B){.red = tred, .green = tgreen, .blue = tblue,.alpha = textureVertexColorData[0].color.alpha};
        
        for (int i = 0;i < 6;i++)
        {
            textureVertexColorData[i].color = tintermediate;
            
        }
        [self setFrameBackgroundColor:intermediate];
    }
    else if (animation.type == ANIMATION_NORMAL)
    {
        
        CGFloat red = getEaseOut(backgroundHightlightColor.red, backgroundColor.red, animationRatio);
        CGFloat green = getEaseOut(backgroundHightlightColor.green, backgroundColor.green, animationRatio);
        CGFloat blue = getEaseOut(backgroundHightlightColor.blue, backgroundColor.blue, animationRatio);
        CGFloat alpha = getEaseOut(backgroundHightlightColor.alpha, backgroundColor.alpha, animationRatio);
        
        
        
        CGFloat tred = getEaseOut(imageHighlightColor.red, imageColor.red, animationRatio);
        CGFloat tgreen = getEaseOut(imageHighlightColor.green, imageColor.green, animationRatio);
        CGFloat tblue = getEaseOut(imageHighlightColor.blue, imageColor.blue, animationRatio);
        
        
        Color4B intermediate = (Color4B){.red = red, .green = green, .blue = blue,.alpha =  alpha};
        Color4B tintermediate = (Color4B){.red = tred, .green = tgreen, .blue = tblue,.alpha = textureVertexColorData[0].color.alpha};
        
        for (int i = 0;i < 6;i++)
        {
            textureVertexColorData[i].color = tintermediate;
            
        }
        [self setFrameBackgroundColor:intermediate];
        
    }
    
    
    if (animationRatio >= 1.0)
        return YES;
    return NO;
}

-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator addAnimationFor:self ofType:ANIMATION_HIGHLIGHT ofDuration:0.2 afterDelayInSeconds:0];
    [soundManager playSoundWithKey:@"button_highlight" gain:1.0 pitch:1.0f location:CGPointZero shouldLoop:NO];
    
}

-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    
    [_target performSelector:_selector];
    [soundManager playSoundWithKey:@"button_highlight" gain:1.0 pitch:1.2f location:CGPointZero shouldLoop:NO];
    
}

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    [animator addAnimationFor:self ofType:ANIMATION_NORMAL ofDuration:0.2 afterDelayInSeconds:0];
    
    [soundManager playSoundWithKey:@"button_highlight" gain:1.0 pitch:1.2f location:CGPointZero shouldLoop:NO];
    
}

-(void)addTarget:(NSObject *)target andSelector:(SEL)selector
{
    self.target = target;
    self.selector = selector;
}

-(void)setBackgroundColor:(Color4B)_color
{
    backgroundColor = _color;
    self.frameBackgroundColor = _color;
}

-(void)setImageColor:(Color4B)_color
{
    imageColor = _color;
    for (int i = 0;i < 6;i++)
    {
        textureVertexColorData[i].color = imageColor;
    }
}

-(void)setBackgroundHightlightColor:(Color4B)_color
{
    backgroundHightlightColor = _color;
}
-(void)setImageHighlightColor:(Color4B)_color
{
    imageHighlightColor = _color;
}

-(void)drawSubElements
{
    [mvpMatrixManager translateInX:(self.frame.size.width/2) Y:(self.frame.size.height/2) Z:1];
    if (buttonTexture != nil)
    {
        textureRenderer.texture = buttonTexture;
        [textureRenderer drawWithArray:textureVertexColorData andCount:6];
    }
    [mvpMatrixManager translateInX:-(self.frame.size.width/2) Y:-(self.frame.size.height/2) Z:0];
}

-(void)dealloc
{
    self.target = nil;
    free(textureVertexColorData);
    [super dealloc];
}

@end
