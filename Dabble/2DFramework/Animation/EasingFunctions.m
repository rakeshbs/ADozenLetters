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

CGFloat getEaseOutBack(CGFloat start,CGFloat end,CGFloat ratio)
{
    BoundsCheck(ratio, start, end)
    CGFloat s = 1.70158;
    CGFloat diff = end - start;
    CGFloat invRatio = ratio -1;
    
    return (powf(invRatio, 2) * ((s + 1.0)*invRatio + s) + 1.0)*diff + start;

}

CGFloat getEaseInBack(CGFloat start,CGFloat end,CGFloat ratio)
{
    BoundsCheck(ratio, start, end)
    CGFloat s = 1.70158;
    CGFloat diff = end - start;
    NSLog(@"%f",ratio);
    return (powf(ratio, 2.0) * ((s + 1.0) * ratio - s))*diff + start;
    
}


CGFloat getEaseOutBackInternal(CGFloat ratio)
{
    if (ratio >= 1.0)
        return 1;
    CGFloat s = 1.70158;
    CGFloat invRatio = ratio -1;
    return (powf(invRatio, 2) * ((s + 1.0)*invRatio + s) + 1.0);
    
}

CGFloat getEaseInBackInternal(CGFloat ratio)
{
    
    if (ratio >= 1.0)
        return 1;
    CGFloat s = 1.70158;
    return (powf(ratio, 2.0) * ((s + 1.0) * ratio - s));
    
}


CGFloat getEaseInOutBack(CGFloat start,CGFloat end,CGFloat ratio)
{
    CGFloat val = 0;
    CGFloat diff = end - start;
    
    if (ratio < 0.5)
        val = 0.5 * getEaseInBackInternal(ratio*2.0);
    else
        val = 0.5 * getEaseOutBackInternal((ratio-0.5)*2.0) + 0.5;
    
    return val * diff + start;
}

