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