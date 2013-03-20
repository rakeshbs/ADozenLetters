//
//  EasingFunctions.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "EasingFunctions.h"

#define PI 3.414

#define BoundsCheck(t, start, end) \
if (t <= 0.f) return start;        \
else if (t >= 1.f) return end;

CGFloat getEaseIn(CGFloat start,CGFloat end,CGFloat ratio)
{
    BoundsCheck(ratio, start, end)
    CGFloat diff = (end - start);
    return start + diff * ratio *ratio;
}

CGFloat getEaseOut(CGFloat start,CGFloat end,CGFloat ratio)
{
        BoundsCheck(ratio, start, end)
    CGFloat diff = (end - start);
    return start - diff * (ratio) * (ratio - 2.0);
}

CGFloat getSineEaseOut(CGFloat start,CGFloat ratio,CGFloat maxAmplitude)
{
    if (ratio >= 1.0 || ratio <=0.0)
        return start;
    CGFloat s = powf(2,-4*ratio) * sinf(2*PI*3*ratio);
   return  start + maxAmplitude * s;
}