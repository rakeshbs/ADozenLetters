//
//  TimerControl.h
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "ElasticCounter.h"

@interface ScoreControl : GLElement
{
    CGFloat timeLeft;
    CGFloat *numberSizes;
    
    GLShaderProgram *textureShaderProgram;
    FontSpriteSheet *fontSpriteSheet;
    GLuint colorBuffer;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    GLRenderer *textureRenderer;
    
    GLRenderer *colorRenderer;
    
    NSMutableArray *counterControls;
    
    NSArray *numberArray;
    
    BOOL *running;
    
}

-(void)setFont:(NSString *)font withSize:(CGFloat)size;
-(void)setValue:(int)value;
-(void)stop;
-(void)setValue:(int)value inDuration:(CGFloat)time;

@property (nonatomic) Color4B color;

@end
