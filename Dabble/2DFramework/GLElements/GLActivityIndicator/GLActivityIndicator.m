//
//  GLActivityIndicator.m
//  Dabble
//
//  Created by Rakesh on 02/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLActivityIndicator.h"
#import "EasingFunctions.h"

#define ACTIVITY_POINTS_COUNT 12
#define NUMBER_POINTS_PER_SIDE 3
#define INITIAL_POSITION 1000.0f
#define ACTIVITY_INDICATOR_SQUARE_SIZE 20.0f
#define ACTIVITY_INDICATOR_SIZE 9.0f

#define ANIMATION_SHOW_ACTIVITY_INDICATOR 1
#define ANIMATION_HIDE_ACTIVITY_INDICATOR 2
#define ANIMATION_RUN_ACTIVITY_INDICATOR 3



@interface ActivityPoint : NSObject

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) int index;
@end

@implementation ActivityPoint

@end

@implementation GLActivityIndicator

-(BOOL)touchable
{
    return NO;
}

-(id)init
{
    if (self = [super init])
    {
        self.hidden = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                    selector:@selector(show) name:GLACTIVITYINDICATOR_SHOW_NOTIFY object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(hide) name:GLACTIVITYINDICATOR_HIDE_NOTIFY object:nil];
        
        pointSpritesShader = [shaderManager getShaderByVertexShaderFileName:@"PointSpritesShader" andFragmentShaderFileName:@"PointSpritesShader"];
        
        UNIFORM_MVPMATRIX = [pointSpritesShader uniformIndex:@"mvpmatrix"];
        ATTRIB_VERTEX = [pointSpritesShader attributeIndex:@"vertex"];
        ATTRIB_COLOR = [pointSpritesShader attributeIndex:@"color"];
        ATTRIB_POINTSIZE = [pointSpritesShader attributeIndex:@"size"];
        
        pointsData = calloc(ACTIVITY_POINTS_COUNT,sizeof(PointVertexColorSize));
        activityPoints = [[NSMutableArray alloc]init];
        
        for (int i = 0;i < ACTIVITY_POINTS_COUNT;i++)
        {
            ActivityPoint *activityPoint = [[ActivityPoint alloc]init];
            activityPoint.startPoint = CGPointMake(0,0);
            activityPoint.index = i;
            (pointsData + i)->color = (Color4B) {.red = 0 , .green = 0, .blue = 0, .alpha = 150};
            (pointsData + i)->size = ACTIVITY_INDICATOR_SIZE;
            [activityPoints addObject:activityPoint];
            [activityPoint release];
        }
        relativePosition = INITIAL_POSITION;
        glGenBuffers(1, &pointsVertexBuffer);
        cycleModeOpen = YES;
    }
    return self;
}

-(void)draw
{
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:0 Y:relativePosition Z:1];

    [pointSpritesShader use];
    
    glBindBuffer(GL_ARRAY_BUFFER, pointsVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, ACTIVITY_POINTS_COUNT * sizeof(PointVertexColorSize), pointsData, GL_DYNAMIC_DRAW);
    
    Matrix3D mvpMatrix;
    [mvpMatrixManager getMVPMatrix:mvpMatrix];
    
    glUniformMatrix4fv(UNIFORM_MVPMATRIX, 1, GL_FALSE, mvpMatrix);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0,  sizeof(PointVertexColorSize),0);
    
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(PointVertexColorSize),
                          (GLvoid*)sizeof(Vertex3D));
    
    glEnableVertexAttribArray(ATTRIB_POINTSIZE);
    glVertexAttribPointer(ATTRIB_POINTSIZE, 1, GL_FLOAT, 0,  sizeof(PointVertexColorSize),
                          (GLvoid*)(sizeof(Vertex3D)+sizeof(Color4B)));

    glDrawArrays(GL_POINTS, 0, ACTIVITY_POINTS_COUNT);
    
    [mvpMatrixManager popModelViewMatrix];
}

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {
        relativePosition = getEaseOutElastic(INITIAL_POSITION, 0, animationRatio,animation.duration);
    }
    if (animation.type == ANIMATION_RUN_ACTIVITY_INDICATOR)
    {
        ActivityPoint *actPoint = (ActivityPoint *)animation.animationData;
        int i =  actPoint.index;
        
        (pointsData + i)->vertex.x = getEaseOutBack(actPoint.startPoint.x, actPoint.endPoint.x, animationRatio);
        (pointsData + i)->vertex.y = getEaseOutBack(actPoint.startPoint.y, actPoint.endPoint.y, animationRatio);
    }
    else if (animation.type == ANIMATION_HIDE_ACTIVITY_INDICATOR)
    {
        relativePosition = getEaseOut(0, -INITIAL_POSITION, animationRatio);
    }
    
    if (animationRatio>=1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {
        self.hidden = NO;
    }
    
}
-(void)animationEnded:(Animation *)animation
{
    CGFloat divisions = ACTIVITY_INDICATOR_SQUARE_SIZE/NUMBER_POINTS_PER_SIDE;
    
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {
        
        for (int i = 0;i<ACTIVITY_POINTS_COUNT;i++)
        {
            
           Animation *animation =
            [animator addAnimationFor:self ofType:ANIMATION_RUN_ACTIVITY_INDICATOR ofDuration:0.5 afterDelayInSeconds:0.1*i+0.5];
            ActivityPoint *activityPoint = activityPoints[i];
            animation.animationData = activityPoint;
            

            CGFloat x =0;
            CGFloat y =0;

            int side = i/NUMBER_POINTS_PER_SIDE;
            
            if (side == 0)
            {
                x = -ACTIVITY_INDICATOR_SQUARE_SIZE/2 + divisions * (i%NUMBER_POINTS_PER_SIDE);
                y = ACTIVITY_INDICATOR_SQUARE_SIZE/2;
            }
            else if (side == 1)
            {
                y = ACTIVITY_INDICATOR_SQUARE_SIZE/2 - divisions * (i%NUMBER_POINTS_PER_SIDE);
                x = ACTIVITY_INDICATOR_SQUARE_SIZE/2;
            }
            else if (side == 2)
            {
                x = ACTIVITY_INDICATOR_SQUARE_SIZE/2 - divisions * (i%NUMBER_POINTS_PER_SIDE);
                y = -ACTIVITY_INDICATOR_SQUARE_SIZE/2;
            }
            else if (side == 3)
            {
                y = -ACTIVITY_INDICATOR_SQUARE_SIZE/2 + divisions * (i%NUMBER_POINTS_PER_SIDE);
                x = -ACTIVITY_INDICATOR_SQUARE_SIZE/2;
            }
            
            cycleCount ++;
            activityPoint.endPoint = CGPointMake(x, y);
            
        }
    }
    else if (animation.type == ANIMATION_RUN_ACTIVITY_INDICATOR)
    {
        cycleCount--;
        
       if (cycleCount == 0)
        {
            cycleModeOpen = !cycleModeOpen;
            
            for (int i = 0;i<ACTIVITY_POINTS_COUNT;i++)
            {
                Animation *animation =
                [animator addAnimationFor:self ofType:ANIMATION_RUN_ACTIVITY_INDICATOR  ofDuration:0.5 afterDelayInSeconds:0.1*i+0.5];
                ActivityPoint *activityPoint = activityPoints[i];
                animation.animationData = activityPoint;
                activityPoint.startPoint = activityPoint.endPoint;
                
                if (!cycleModeOpen)
                    activityPoint.endPoint = CGPointMake(0, 0);
                else
                {
                    CGFloat x =0;
                    CGFloat y =0;
                    
                    int side = i/NUMBER_POINTS_PER_SIDE;
                    
                    if (side == 0)
                    {
                        x = -ACTIVITY_INDICATOR_SQUARE_SIZE/2 + divisions * (i%NUMBER_POINTS_PER_SIDE);
                        y = ACTIVITY_INDICATOR_SQUARE_SIZE/2;
                    }
                    else if (side == 1)
                    {
                        y = ACTIVITY_INDICATOR_SQUARE_SIZE/2 - divisions * (i%NUMBER_POINTS_PER_SIDE);
                        x = ACTIVITY_INDICATOR_SQUARE_SIZE/2;
                    }
                    else if (side == 2)
                    {
                        x = ACTIVITY_INDICATOR_SQUARE_SIZE/2 - divisions * (i%NUMBER_POINTS_PER_SIDE);
                        y = -ACTIVITY_INDICATOR_SQUARE_SIZE/2;
                    }
                    else if (side == 3)
                    {
                        y = -ACTIVITY_INDICATOR_SQUARE_SIZE/2 + divisions * (i%NUMBER_POINTS_PER_SIDE);
                        x = -ACTIVITY_INDICATOR_SQUARE_SIZE/2;
                    }

                    activityPoint.endPoint = CGPointMake(x, y);
                }
                cycleCount++;
                
            }

        }
    }
    else if (animation.type == ANIMATION_HIDE_ACTIVITY_INDICATOR)
    {
        self.hidden = YES;
    }

}

-(void)show
{
    if (!self.hidden)
        return;
    
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    
    for (int i = 0;i < ACTIVITY_POINTS_COUNT;i++)
    {
        ActivityPoint *activityPoint = activityPoints[i];
        activityPoint.startPoint = CGPointMake(0,0);
        activityPoint.endPoint = CGPointMake(0,0);
        (pointsData + i)->vertex = (Vertex3D){.x = 0, .y = 0, .z=0 ,.t = 0};
    }
    cycleCount = 0;
    cycleModeOpen = YES;
    [animator addAnimationFor:self ofType:ANIMATION_SHOW_ACTIVITY_INDICATOR ofDuration:1.0 afterDelayInSeconds:0];
}

-(void)hide
{
    if (self.hidden)
        return;
    
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_HIDE_ACTIVITY_INDICATOR ofDuration:1.0 afterDelayInSeconds:0];
}

@end
