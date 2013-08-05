//
//  GLButton.h
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "SoundManager.h"

@interface GLImageButton : GLElement <AnimationDelegate>
{
    GLRenderer *colorRenderer;
    GLRenderer *textureRenderer;
    
    TextureVertexColorData *textureVertexColorData;
    
    Texture2D *buttonTexture;
    
    Color4B backgroundColor;
    Color4B imageColor;
    Color4B backgroundHightlightColor;
    Color4B imageHighlightColor;
    
    SoundManager *soundManager;
}

@property (nonatomic,retain) NSObject *target;
@property (nonatomic) SEL selector;


-(void)setImage:(NSString *)imageName ofType:(NSString *)type;
-(void)setBackgroundColor:(Color4B)_color;
-(void)setBackgroundHightlightColor:(Color4B)_color;
-(void)setImageHighlightColor:(Color4B)_color;
-(void)setImageColor:(Color4B)_color;

-(void)addTarget:(NSObject *)target andSelector:(SEL)selector;
@end
