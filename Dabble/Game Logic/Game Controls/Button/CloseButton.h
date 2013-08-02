//
//  CloseButton.h
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "SoundManager.h"
#define CLOSEBUTTON_CLICK_STARTED 1
#define CLOSEBUTTON_CLICK_CANCELLED 2
#define CLOSEBUTTON_CLICK_FINISHED 3

@protocol CloseButtonDelegate
-(void)closeButtonClick:(int)event;
@end

@interface CloseButton : GLElement <AnimationDelegate>
{
    SoundManager *soundManager;
    GLRenderer *colorRenderer;
    GLRenderer *textureRenderer;
    
    TextureVertexColorData *textureVertexColorData;
    
    Texture2D *buttonTextTexture;
    
    Color4B backgroundColor;
    Color4B textColor;
}

@property (nonatomic,retain) NSObject<CloseButtonDelegate> *delegate;

@end

