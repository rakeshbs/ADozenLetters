//
//  TimerControl.h
//  Dabble
//
//  Created by Rakesh on 03/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface TimerControl : GLElement
{
    CGFloat timeLeft;
    CGFloat *numberSizes;
    
}

-(void)setFontSize:(CGFloat)size;
-(id)initWithFrame:(CGRect)__frame;
-(void)setTimeLeft:(CGFloat)time;

@end
