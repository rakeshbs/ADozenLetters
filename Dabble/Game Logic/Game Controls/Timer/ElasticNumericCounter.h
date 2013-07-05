//
//  ElasticCounter.h
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface ElasticNumericCounter : GLElement <AnimationDelegate>
{
      GLShaderProgram *textureShaderProgram;
    
    FontSpriteSheet *fontSpriteSheet;
    NSMutableArray *sequence;
    
    int currentValue;
    
    CGFloat verticalOffset;
    CGFloat previousVerticalOffset;
    CGFloat destinationVerticalOffset;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    Vertex3D *maskedVertices;
    TextureCoord *maskedTextureCoords;
    
    GLuint textureBuffer;
    
    
    GLuint ATTRIB_TEXTURE_MVPMATRIX;
    GLuint ATTRIB_TEXTURE_VERTEX;
    GLuint ATTRIB_TEXTURE_COLOR;
    GLuint ATTRIB_TEXTURE_TEXCOORDS;
    
}

@property (nonatomic,readonly) NSMutableArray *sequence;

-(void)setValue:(int)value;
-(void)setFont:(NSString *)font withSize:(CGFloat)size;
-(void)setSequence:(NSMutableArray *)sequence;

@end
