//
//  TimerControl.m
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ScoreControl.h"

#define marginX 9
#define marginY 0


@implementation ScoreControl

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        vertexData = NULL;
        
        textureRenderer = [rendererManager getRendererWithVertexShaderName:@"InstancedTextureShader" andFragmentShaderName:@"StringTextureShader"];
        
        colorRenderer = [rendererManager getRendererWithVertexShaderName:@"ColorShader" andFragmentShaderName:@"ColorShader"];
        
        glGenBuffers(1, &colorBuffer);
        
        counterControls = [[NSMutableArray alloc]init];
        
        NSString *fontStr =  @"0,1,2,3,4,5,6,7,8,9";;
        numberArray = [[fontStr componentsSeparatedByString:@","]retain];
        _color = (Color4B){.red = 255,.green = 255,.blue = 255, .alpha = 255};
        
        vertexColorData = malloc(sizeof(VertexColorData) * 6);
        vertexColorData[0].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        vertexColorData[1].vertex = (Vertex3D){.x = frame.size.width, .y = 0, .z = 0};
        vertexColorData[2].vertex = (Vertex3D){.x = frame.size.width, .y = frame.size.height, .z = 0};
        vertexColorData[3].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
        vertexColorData[4].vertex = (Vertex3D){.x = 0, .y = frame.size.height, .z = 0};
        vertexColorData[5].vertex = (Vertex3D){.x = frame.size.width, .y = frame.size.height, .z = 0};
        for (int i = 0;i<6;i++)
        {
            vertexColorData[i].color = (Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 0};
        }
        
        glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(VertexColorData) * 6, vertexColorData,GL_STATIC_DRAW);
    }
    return self;
}

-(void)setTimeLeft:(CGFloat)time
{
    timeLeft = time;
}


-(void)setBackgroundColor:(Color4B)color
{
    for (int i = 0;i<6;i++)
    {
        vertexColorData[i].color = color;
    }
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VertexColorData) * 6, vertexColorData,GL_STATIC_DRAW);
}

-(void)setTextColor:(Color4B)color
{
    _color = color;
    for (ElasticCounter *counter in counterControls)
        counter.color = color;
}

-(void)stop
{
    int prevvalue = 0;
    for (int i = counterControls.count - 1;i>=0 ;i--)
    {
        int ind = counterControls.count - i - 1;
        ElasticCounter * counter = counterControls[ind];
        prevvalue += counter.currentValue * powl(10, i);
        [counter stop];
    }

}

-(void)setValue:(int)value inDuration:(CGFloat)time
{
    int prevvalue = 0;
    CGFloat offsetTime = 0.05;
    for (int i = counterControls.count - 1;i>=0 ;i--)
    {
        int ind = counterControls.count - i - 1;
        ElasticCounter * counter = counterControls[ind];
        [counter stop];
        prevvalue += counter.currentValue * powl(10, i);
    }
    
    if (value > prevvalue)
    {
        BOOL start = NO;
        for (int i = counterControls.count - 1;i>=0 ;i--)
        {
            int ind = counterControls.count - i - 1;
            ElasticCounter * counter = counterControls[ind];
            
            int v = floorf((value/powl(10, i)));
            int pv = floorf((prevvalue/powl(10, i)));
            
            if (v-pv > 0)
            {
                if (!start)
                {
                    start = YES;
                    [counter setValueCountUp:v-pv withDuration:time];
                }
                else
                {
                    [counter setValueCountUp:v-pv withDuration:time + offsetTime * ind];
                }
                
            }
            
            if (start)
                [counter showInDuration:0.05];
        }
    }
    else if (value < prevvalue)
    {
        BOOL start = NO;
        BOOL previousHidden = YES;
        for (int i = counterControls.count - 1;i>=0 ;i--)
        {
            int ind = counterControls.count - i - 1;
            ElasticCounter * counter = counterControls[ind];
    
            int v = floorf((value/powl(10, i)));
            int pv = floorf((prevvalue/powl(10, i)));
            
            if (pv - v > 0)
            {
                if (!start)
                {
                    start = YES;
                    [counter setValueCountDown:pv - v withDuration:time];
                    if (i != 0)
                    {
                        if (v == 0 && previousHidden)
                            [counter hideInDuration:time];
                        else
                            previousHidden = NO;
                    }
                }
                else
                {
                    [counter setValueCountDown:pv - v withDuration:time + offsetTime * ind];
                    if (i != 0)
                    {
                        if (v == 0 && previousHidden)
                            [counter hideInDuration:1];
                        else
                            previousHidden = NO;
                    }
                }
                
            }
            

        }

    }
}


-(void)setFont:(NSString *)font withSize:(CGFloat)size
{
    fontSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeNumbers withFont:font andSize:size];
    
    if (vertexData != NULL)
        free(vertexData);
    
    [subElements removeAllObjects];
    [counterControls removeAllObjects];
    
    CGFloat maxWidth = 0;
    
    for (FontSprite *f in fontSpriteSheet.fontSpriteDictionary.objectEnumerator)
        maxWidth = (maxWidth < f.width)?f.width:maxWidth;
    
    maxWidth /=2;
    
    int num = floorf(((self.frame.size.width - marginX*2)/maxWidth));
    vertexData = malloc(sizeof(InstancedTextureVertexColorData) * num * 6 * 4);
    ElasticCounter *counter;
    for (int i = 0;i<num;i++)
    {
         counter = [[ElasticCounter alloc]
                                   initWithFrame:CGRectMake(frame.size.width - (marginX + ((num - i) * maxWidth)), marginY, maxWidth,
                                                            self.frame.size.height - 2 * marginY)];
        counter.fontSpriteSheet = fontSpriteSheet;
        [counter setSequence:numberArray];
        counter.color = _color;
        [self addElement:counter];
        counter.alpha = 0;
        [counterControls addObject:counter];
    }
    counter.alpha = 255;
}

-(void)draw
{  
    [colorRenderer drawWithVBO:colorBuffer andCount:6];
    int count = 0;
    for (ElasticCounter *counter in counterControls)
    {
        [mvpMatrixManager pushModelViewMatrix];
        [mvpMatrixManager translateInX:counter.frame.origin.x + counter.frame.size.width/2
                                     Y:counter.frame.origin.y + counter.frame.size.height/2 Z:1];
        counter.vertexData = (vertexData + count);
        [counter draw];
        count += counter.vertexDataCount;
        [mvpMatrixManager popModelViewMatrix];
    }
    [textureRenderer setTexture:fontSpriteSheet.texture];
    [textureRenderer drawWithArray:vertexData andCount:count];
    
}

-(void)dealloc
{
    [numberArray release];
    [counterControls release];
    [super dealloc];
}

@end
