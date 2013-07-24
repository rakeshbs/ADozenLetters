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
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"TextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        textureVertexColorData = malloc(sizeof(TextureVertexColorData) * 6);
        self.textColor = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 255};
        
        textureVertexColorData[0].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        textureVertexColorData[1].vertex = (Vertex3D){.x = _frame.size.width, .y = 0, .z = 0};
        textureVertexColorData[2].vertex = (Vertex3D){.x = _frame.size.width, .y = _frame.size.height, .z = 0};
        textureVertexColorData[3].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        textureVertexColorData[4].vertex = (Vertex3D){.x = 0, .y = _frame.size.height, .z = 0};
        textureVertexColorData[5].vertex = (Vertex3D){.x = _frame.size.width, .y = _frame.size.height, .z = 0};
        
        for (int i = 0;i<6;i++)
        {
            textureVertexColorData[i].color = self.textColor;
        }
        
    }
    return self;
}

-(void)setText:(NSString *)text withAlignment:(UITextAlignment)textAlignment
{
    self.text = text;
    self.textAlignment = textAlignment;
    [self setupLabel];
}

-(void)setFont:(NSString *)font andSize:(CGFloat)size
{
    self.font = [UIFont fontWithName:font size:size];
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

-(void)setupLabel
{
    if (texture)
    {
        [texture release];
    }
    
    texture = [textureManager getStringTexture:self.text dimensions:self.frame.size horizontalAlignment:self.textAlignment verticalAlignment:UITextAlignmentCenter fontName:self.font.fontName fontSize:self.font.pointSize];
    
    TextureCoord *texCoords = [texture getTextureCoordinates];
    for (int i = 0;i<6;i++)
    {
        textureVertexColorData[i].texCoord = texCoords[i];
    }
}


-(void)draw
{
    [mvpMatrixManager translateInX:0 Y:0 Z:1];
    [textureRenderer setTexture:texture];
    [textureRenderer drawWithArray:textureVertexColorData andCount:6];
    [mvpMatrixManager translateInX:0 Y:0 Z:-1];
}
@end
