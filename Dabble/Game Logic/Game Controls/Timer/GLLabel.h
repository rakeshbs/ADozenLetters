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
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) UIFont *font;
@property (nonatomic) Color4B textColor;
@property (nonatomic) UITextAlignment textAlignment;

-(void)setText:(NSString *)text withAlignment:(UITextAlignment)textAlignment;
-(void)setFont:(NSString *)font andSize:(CGFloat)size;
-(void)setTextColor:(Color4B)textColor;

@end
