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
      
    NSMutableArray *sequence;
    
    int currentValue;
    
    CGFloat verticalOffset;
    CGFloat previousVerticalOffset;
    CGFloat destinationVerticalOffset;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    Vertex3D *maskedVertices;
    TextureCoord *maskedTextureCoords;
    
    FontSpriteSheet *fontSpriteSheet;
}

@property (nonatomic,readonly) NSMutableArray *sequence;
@property (nonatomic) InstancedTextureVertexColorData *vertexData;
@property (nonatomic,readonly) int vertexDataCount;
@property (nonatomic,retain) FontSpriteSheet *fontSpriteSheet;

-(void)setValueCountUp:(int)value;
-(void)setFont:(NSString *)font withSize:(CGFloat)size;
-(void)setSequence:(NSMutableArray *)sequence;

@end
