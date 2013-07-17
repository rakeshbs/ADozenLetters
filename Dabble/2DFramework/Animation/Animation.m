//
//  Animation.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Animation.h"

@implementation Animation

-(id)init
{
    if (self = [super init])
    {
        startValue = NULL;
        endValue = NULL;

    }
    return self;
}


-(BOOL)canAnimationBeStarted
{
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    if (currentTime - _queuedTime > _startDelay)
    {
        return YES;
    }
    return NO;
}

-(CGFloat)getAnimatedRatio
{
    return (CFAbsoluteTimeGetCurrent() - _startTime)*1.0f/(_duration);
}

-(void *)getStartValue
{
    return startValue;
}
-(void *)getEndValue
{
    return endValue;
}


-(void)setStartValue:(void *)_startValue OfSize:(size_t)size;
{
    if (startValue == NULL)
        startValue = malloc(size);
    memcpy(startValue, _startValue, size);
}

-(void)setEndValue:(void *)_endValue OfSize:(size_t)size;
{
    if (endValue == NULL)
        endValue = malloc(size);
    memcpy(endValue, _endValue, size);
}

-(void)dealloc
{
    if (startValue != NULL)
        free(startValue);
    if (endValue != NULL)
        free(endValue);

    [super dealloc];
}

@end
