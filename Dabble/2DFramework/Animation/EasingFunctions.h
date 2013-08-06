//
//  EasingFunctions.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EASINGTYPE_EASEIN 1
#define EASINGTYPE_EASEOUT 2
#define EASINGTYPE_EASEINEASEOUT 3

CGFloat getEaseIn(CGFloat start,CGFloat end,CGFloat ratio);
CGFloat getEaseOut(CGFloat start,CGFloat end,CGFloat ratio);
CGFloat getSineEaseOut(CGFloat start,CGFloat ratio,CGFloat maxAmplitude);
CGFloat getEaseOutBack(CGFloat start,CGFloat end,CGFloat ratio);
CGFloat getEaseInOutBack(CGFloat start,CGFloat end,CGFloat ratio);
CGFloat getEaseInBack(CGFloat start,CGFloat end,CGFloat ratio);
CGFloat getEaseOutElastic(CGFloat start,CGFloat end,CGFloat ratio,CGFloat duration);
CGFloat getSineEaseOutDamping(CGFloat start,CGFloat ratio,CGFloat maxAmplitude,CGFloat damping);
CGFloat getEaseInOut(CGFloat start,CGFloat end,CGFloat ratio,CGFloat duration);
CGFloat getSineEaseOutFrequceny(CGFloat start,CGFloat ratio,CGFloat maxAmplitude,CGFloat frequency);