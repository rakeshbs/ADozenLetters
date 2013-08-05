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
    Color4B textColor;
    Color4B backgroundHightlightColor;
    Color4B textHighlightColor;
    
    SoundManager *soundManager;
}

@property (nonatomic,retain) NSObject *target;
@property (nonatomic) SEL selector;


-(void)setTextColor:(Color4B)_color;
-(void)setBackgroundColor:(Color4B)_color;
-(void)setBackgroundHightlightColor:(Color4B)_color;
-(void)setTextHighlightColor:(Color4B)_color;

-(void)addTarget:(NSObject *)target andSelector:(SEL)selector;
-(void)setImage:(NSString *)imageName;
@end
