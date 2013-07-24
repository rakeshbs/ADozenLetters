//
//  GLButton.h
//  Dabble
//
//  Created by Rakesh on 19/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface GLButton : GLElement <AnimationDelegate>
{
    GLRenderer *colorRenderer;
    GLRenderer *textureRenderer;
    
    TextureVertexColorData *textureVertexColorData;
    VertexColorData *vertexColorData;
    
    Texture2D *buttonTextTexture;
    
    Color4B backgroundColor;
    Color4B textColor;
}

@property (nonatomic,retain) NSObject *target;
@property (nonatomic) SEL selector;



-(void)setTextColor:(Color4B)_color;
-(void)setBackgroundColor:(Color4B)_color;
-(void)addTarget:(NSObject *)target andSelector:(SEL)selector;
-(void)setText:(NSString *)text withFont:(NSString *)font andSize:(CGFloat)size;
@end
