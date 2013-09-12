//
//  GLLabel.h
//  Dabble
//
//  Created by Rakesh on 24/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface GLLabel : GLElement
{
    GLRenderer *textureRenderer;
    Texture2D *texture;
    TextureVertexColorData *textureVertexColorData;
    GLuint vbo;
    CGFloat offset;
}

@property (nonatomic,readonly) NSString *text;
@property (nonatomic) CGFloat  textScale;
@property (nonatomic,readonly) UIFont *font;
@property (nonatomic,readonly) Color4B textColor;
@property (nonatomic) NSTextAlignment textAlignment;

-(void)setText:(NSString *)text withAlignment:(UITextAlignment)textAlignment;
-(void)setFont:(NSString *)font andSize:(CGFloat)size;
-(void)setTextColor:(Color4B)textColor;

@end
