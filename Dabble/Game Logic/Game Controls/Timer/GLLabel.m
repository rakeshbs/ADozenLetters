//
//  GLLabel.m
//  Dabble
//
//  Created by Rakesh on 24/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLLabel.h"

@implementation GLLabel

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        _textScale = 1.0;
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"TextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);
        self.textColor = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 255};
        
        for (int i = 0;i<6;i++)
        {
            textureVertexColorData[i].color = self.textColor;
        }
        
    }
    return self;
}

-(void)setText:(NSString *)text withAlignment:(UITextAlignment)textAlignment
{
    _text = text;
    self.textAlignment = textAlignment;
    [self setupLabel];
}

-(void)setFont:(NSString *)font andSize:(CGFloat)size
{
    _font = [UIFont fontWithName:font size:size];
    [self setupLabel];
}

-(void)setTextColor:(Color4B)textColor
{
    _textColor = textColor;
    for (int i = 0;i<6;i++)
    {
        textureVertexColorData[i].color = self.textColor;
    }
}

-(void)setTextScale:(CGFloat)textScale
{
    _textScale = textScale;
    [texture generateMipMap];
}

-(void)setupLabel
{
    if (texture)
    {
        [texture release];
    }
    
    texture = [textureManager getStringTexture:self.text dimensions:self.frame.size horizontalAlignment:self.textAlignment verticalAlignment:UITextAlignmentCenter fontName:self.font.fontName fontSize:self.font.pointSize];
    if (self.textScale != 1.0)
    {
        [texture generateMipMap];
    }

    Vertex3D *vertices = [texture getTextureVertices];
    TextureCoord *texCoords = [texture getTextureCoordinates];
    for (int i = 0;i<6;i++)
    {
        
        textureVertexColorData[i].vertex = vertices[i];
        textureVertexColorData[i].texCoord = texCoords[i];
    }
    
}


-(void)draw
{
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:self.frame.size.width/2 Y:self.frame.size.height/2 Z:1];
    
    [mvpMatrixManager scaleByXScale:self.textScale YScale:self.textScale ZScale:1];
    [textureRenderer setTexture:texture];
    [textureRenderer drawWithArray:textureVertexColorData andCount:6];
    [mvpMatrixManager popModelViewMatrix];
}
@end
