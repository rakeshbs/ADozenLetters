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
#define INITIAL_POSITION 0
#define ACTIVITY_INDICATOR_SQUARE_SIZE 20.0f
#define ACTIVITY_INDICATOR_SIZE 4.0f

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

@synthesize iteration;

-(BOOL)touchable
{
    return NO;
}

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        self.hidden = NO;
        pointsData = calloc(ACTIVITY_POINTS_COUNT,sizeof(PointVertexColorSizeData));
        activityPoints = [[NSMutableArray alloc]init];
        
        pointsRenderer = [rendererManager getRendererWithVertexShaderName:@"PointSpritesShader" andFragmentShaderName:@"PointSpritesShader"];
        
        for (int i = 0;i < ACTIVITY_POINTS_COUNT;i++)
        {
            ActivityPoint *activityPoint = [[ActivityPoint alloc]init];
            activityPoint.startPoint = CGPointMake(0,0);
            activityPoint.index = i;
            (pointsData + i)->color = (Color4B) {.red = 255 , .green = 255, .blue = 255, .alpha = 255};
            (pointsData + i)->size = ACTIVITY_INDICATOR_SIZE * [[UIScreen mainScreen]scale];
            [activityPoints addObject:activityPoint];
            [activityPoint release];
        }
        
        for (int i = 0;i < ACTIVITY_POINTS_COUNT;i++)
        {
            ActivityPoint *activityPoint = activityPoints[i];
            activityPoint.startPoint = CGPointMake(0,0);
            activityPoint.endPoint = CGPointMake(0,0);
            (pointsData + i)->vertex = (Vertex3D){.x = 0, .y = 0, .z=0 ,.t = 0};
        }
        relativePosition = INITIAL_POSITION;
        cycleModeOpen = YES;
    }
    return self;
}

-(void)draw
{
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:frame.size.width/2
                                 Y:frame.size.height/2 + relativePosition Z:1];
    [pointsRenderer drawWithArray:pointsData andCount:ACTIVITY_POINTS_COUNT];
    [mvpMatrixManager popModelViewMatrix];
}

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {

    }
    if (animation.type == ANIMATION_RUN_ACTIVITY_INDICATOR)
    {
        ActivityPoint *actPoint = (ActivityPoint *)animation.animationData;
        int i =  actPoint.index;
        
        (pointsData + i)->vertex.x = getEaseInOutBack(actPoint.startPoint.x, actPoint.endPoint.x, animationRatio);
        (pointsData + i)->vertex.y = getEaseInOutBack(actPoint.startPoint.y, actPoint.endPoint.y, animationRatio);
    }
    else if (animation.type == ANIMATION_HIDE_ACTIVITY_INDICATOR)
    {
        relativePosition = getEaseOut(0, -1000, animationRatio);
    }
    
    if (animationRatio>=1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    if (animation.type == ANIMATION_SHOW_ACTIVITY_INDICATOR)
    {
     //   self.hidden = NO;
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
        
        if ([self.delegate respondsToSelector:@selector(activityIndicatorDidAappear:)])
        {
            [self.delegate activityIndicatorDidAappear:self];
        }

    }
    else if (animation.type == ANIMATION_RUN_ACTIVITY_INDICATOR)
    {
        cycleCount--;
        
       if (cycleCount == 0)
        {
            iteration++;
            [self.delegate activitiyIndicatorFinishedAnimating:self];
        }
    }
    else if (animation.type == ANIMATION_HIDE_ACTIVITY_INDICATOR)
    {
        self.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(activityIndicatorDidDisappear:)])
        {
            [self.delegate activityIndicatorDidDisappear:self];
        }
    }

}

-(void)animate
{
    cycleModeOpen = !cycleModeOpen;
    CGFloat divisions = ACTIVITY_INDICATOR_SQUARE_SIZE/NUMBER_POINTS_PER_SIDE;
    
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


-(void)show
{
//    if (!self.hidden)
  //      return;
    self.hidden = NO;
    iteration = 0;
    
//    [animator removeQueuedAnimationsForObject:self];
  //  [animator removeRunningAnimationsForObject:self];
    /*
    for (int i = 0;i < ACTIVITY_POINTS_COUNT;i++)
    {
        ActivityPoint *activityPoint = activityPoints[i];
        activityPoint.startPoint = CGPointMake(0,0);
        activityPoint.endPoint = CGPointMake(0,0);
        (pointsData + i)->vertex = (Vertex3D){.x = 0, .y = 0, .z=0 ,.t = 0};
    }*/
    
    NSLog(@"Show Activity indicator");
    cycleCount = 0;
    cycleModeOpen = YES;
    [animator addAnimationFor:self ofType:ANIMATION_SHOW_ACTIVITY_INDICATOR ofDuration:0.0 afterDelayInSeconds:0];
    
}

-(void)hide
{
    if (self.hidden)
        return;
    iteration = 0;
    
    [animator removeQueuedAnimationsForObject:self];
    [animator removeRunningAnimationsForObject:self];
    [animator addAnimationFor:self ofType:ANIMATION_HIDE_ACTIVITY_INDICATOR ofDuration:1.0 afterDelayInSeconds:0];
}

-(void)dealloc
{
    NSLog(@"deallocating activity indicator");
    self.delegate = nil;
    free(pointsData);
    [activityPoints release];
    [super dealloc];
}

@end
