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
#define INITIAL_POSITION 1000
#define ACTIVITY_INDICATOR_RADIUS 8
#define ACTIVITY_INDICATOR_SIZE 4

#define ANIMATION_SHOW_ACTIVITY_INDICATOR 1
#define ANIMATION_HIDE_ACTIVITY_INDICATOR 2
#define ANIMATION_OPEN_ACTIVITY_INDICATOR 3
#define ANIMATION_CLOSE_ACTIVITY_INDICATOR 4


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
        relativePosition = getEaseOutBack(INITIAL_POSITION, 0, animationRatio);
    }
    if (animation.type == ANIMATION_OPEN_ACTIVITY_INDICATOR)
    {
        ActivityPoint *actPoint = (ActivityPoint *)animation.animationData;
        int i =  actPoint.index;
        
        (pointsData + i)->vertex.x = getEaseOutBack(actPoint.startPoint.x, actPoint.endPoint.x, animationRatio);
        (pointsData + i)->vertex.y = getEaseOutBack(actPoint.startPoint.y, actPoint.endPoint.y, animationRatio);
    }
    
    if (animationRatio>=1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    
}
-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {
        for (int i = 0;i<ACTIVITY_POINTS_COUNT;i++)
        {
           Animation *animation =
            [animator addAnimationFor:self ofType:ANIMATION_OPEN_ACTIVITY_INDICATOR ofDuration:0.5 afterDelayInSeconds:0.1*i+0.5];
            ActivityPoint *activityPoint = activityPoints[i];
            animation.animationData = activityPoint;
            CGFloat x = ACTIVITY_INDICATOR_RADIUS * cosf(2*i*3.14/ACTIVITY_POINTS_COUNT);
            CGFloat y = ACTIVITY_INDICATOR_RADIUS * sinf(2*i*3.14/ACTIVITY_POINTS_COUNT);
            cycleCount ++;
            activityPoint.endPoint = CGPointMake(x, y);

        }
    }
    else if (animation.type == ANIMATION_OPEN_ACTIVITY_INDICATOR)
    {
        cycleCount--;
        if (cycleCount == 0)
        {
            cycleModeOpen = !cycleModeOpen;
            
            for (int i = 0;i<ACTIVITY_POINTS_COUNT;i++)
            {
                Animation *animation =
                [animator addAnimationFor:self ofType:ANIMATION_OPEN_ACTIVITY_INDICATOR  ofDuration:0.5 afterDelayInSeconds:0.1*i+0.5];
                ActivityPoint *activityPoint = activityPoints[i];
                animation.animationData = activityPoint;
                activityPoint.startPoint = activityPoint.endPoint;
                
                if (!cycleModeOpen)
                    activityPoint.endPoint = CGPointMake(0, 0);
                else
                {
                    CGFloat x = ACTIVITY_INDICATOR_RADIUS * cosf(2*i*3.14/ACTIVITY_POINTS_COUNT);
                    CGFloat y = ACTIVITY_INDICATOR_RADIUS * sinf(2*i*3.14/ACTIVITY_POINTS_COUNT);
                    activityPoint.endPoint = CGPointMake(x, y);
                }
                cycleCount++;
                
            }

        }
    }

}

-(void)show
{
    [animator addAnimationFor:self ofType:ANIMATION_SHOW_ACTIVITY_INDICATOR ofDuration:1 afterDelayInSeconds:0];
}

-(void)hide
{
    
}

@end
