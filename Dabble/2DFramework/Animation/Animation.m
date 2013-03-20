//
//  Animation.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Animation.h"

@implementation Animation


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

-(void)dealloc
{
    [super dealloc];
}

@end
