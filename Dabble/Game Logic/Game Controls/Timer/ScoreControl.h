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
    GLuint colorBuffer;
    
    InstancedTextureVertexColorData *vertexData;
    int vertexDataCount;
    
    VertexColorData *vertexColorData;
    
    GLRenderer *textureRenderer;
    
    GLRenderer *colorRenderer;
    
    NSMutableArray *counterControls;
    
    NSArray *numberArray;
    
    BOOL *running;
    int visibleCount;
    CGFloat widthPerCounter;
    
    CGFloat offsetVisibleX;
    
    UITextAlignment textAlignment;
}

-(void)setTextAlignment:(UITextAlignment)_textAlignment;
-(void)setBackgroundColor:(Color4B)color;
-(void)setFont:(NSString *)font withSize:(CGFloat)size;
-(void)stop;
-(void)setValue:(long long)value inDuration:(CGFloat)time;
-(void)setTextColor:(Color4B)textcolor;
-(CGFloat)getVisibleWidth;

@property (nonatomic) Color4B color;

@end
