//
//  TimerControl.m
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TimerControl.h"

@implementation TimerControl

-(id)initWithFrame:(CGRect)__frame
{
    if (self = [super init])
    {
        self.frame = __frame;
    }
    return self;
}

-(void)setTimeLeft:(CGFloat)time
{
    timeLeft = time;
}

-(void)update
{
    
}

@end
