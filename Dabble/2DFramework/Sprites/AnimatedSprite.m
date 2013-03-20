//
//  AnimatedSprite.m
//  GameDemo
//
//  Created by Trucid on 10/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AnimatedSprite.h"


@implementation AnimatedSprite 
@synthesize delay,frame,data,location;

-(id)initWithSpriteSheet:(SpriteSheet *)s andDelay:(CGFloat)_delay
{
	if (self = [super init])
	{
		refreshTimeInterval = 0;
		sprite_sheet = s;
		delay = _delay;
		frame = 0;
	}
	return self;
}

-(void)nextFrame
{
	frame++;
	if (frame >= sprite_sheet.number_of_frames)
	{
		frame = sprite_sheet.number_of_frames - 1;
		if (target != nil)
			[target performSelector:animation_end_selector withObject:self];
	}
}

-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector
{
	target = _target;
	animation_end_selector = _selector;
}

-(void)draw
{
	currentTime = CFAbsoluteTimeGetCurrent();
	if (refreshTimeInterval == 0)
		refreshTimeInterval = currentTime;
	
	if (currentTime- refreshTimeInterval > delay)
	{
		refreshTimeInterval = currentTime;
		[self nextFrame];
	}
	[sprite_sheet drawFrame:frame atPoint:location];
}

-(void)drawAtPoint:(CGPoint)point
{
	currentTime = CFAbsoluteTimeGetCurrent();
	if (refreshTimeInterval == 0)
		refreshTimeInterval = currentTime;
	
	if (currentTime- refreshTimeInterval > delay)
	{
		refreshTimeInterval = currentTime;
		[self nextFrame];
	}
	[sprite_sheet drawFrame:frame atPoint:point];
}

@end
