//
//  ElasticCounter.h
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface ElasticCounter : GLElement <AnimationDelegate>
{
      
    NSMutableArray *sequence;
    
    int currentValue;
    double verticalOffset;
    double previousVerticalOffset;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    Vertex3D *maskedVertices;
    TextureCoord *maskedTextureCoords;
    
    FontSpriteSheet *fontSpriteSheet;
    
    int loopCount;
    CGFloat maxAngle;
    CGFloat wiggleDistance;
    CGFloat loopRatio;
    int alpha;
    
    BOOL visible;
}

@property  (nonatomic) BOOL visible;
@property (nonatomic,readonly) int currentValue;
@property (nonatomic,readonly) NSArray *sequence;
@property (nonatomic) InstancedTextureVertexColorData *vertexData;
@property (nonatomic,readonly) int vertexDataCount;
@property (nonatomic,retain) FontSpriteSheet *fontSpriteSheet;
@property (nonatomic) Color4B color;
@property (nonatomic) int alpha;

-(void)setStringValueToCount:(NSString *)str inDuration:(CGFloat)duration;
-(void)setValueCountUp:(CGFloat)value withDuration:(CGFloat)duration;
-(void)setValueCountDown:(CGFloat)value withDuration:(CGFloat)duration;
-(void)setSequence:(NSArray *)sequence;
-(void)stop;
-(void)showInDuration:(CGFloat)t;
-(void)hideInDuration:(CGFloat)t;

@end
