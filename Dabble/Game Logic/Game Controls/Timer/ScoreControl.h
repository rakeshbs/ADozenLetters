//
//  TimerControl.h
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "ElasticCounter.h"

@interface ScoreControl : GLElement <AnimationDelegate>
{
    CGFloat timeLeft;
    CGFloat *numberSizes;
    
    GLShaderProgram *textureShaderProgram;
    FontSpriteSheet *fontSpriteSheet;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    GLRenderer *textureRenderer;
    
    NSMutableArray *counterControls;
    
    NSArray *numberArray;
    
    BOOL *running;
    int visibleCount;
    CGFloat widthPerCounter;
    
    CGFloat offsetVisibleX;
    
    UITextAlignment textAlignment;
}

-(void)setTextAlignment:(UITextAlignment)_textAlignment;
-(void)setFont:(NSString *)font withSize:(CGFloat)size;
-(void)stop;
-(void)setValue:(long long)value inDuration:(CGFloat)time;
-(CGFloat)getVisibleWidth;

@property (nonatomic) Color4B textColor;

@end
