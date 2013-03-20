//
//  Director.m
//  GameDemo
//
//  Created by Trucid on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Director.h"
#import "Scene.h"

@interface Director (Private)

@end


@implementation Director

@synthesize window,openGLview,openGLViewController;

+(id)getSharedDirector
{
	static Director *dir;
	@synchronized(self)
	{
		if (dir == nil)
		{
			dir = [[Director alloc]init];
		}
	}
	return dir;
}

-(void)presentScene:(NSObject *)scene
{
	if ([scene isKindOfClass:[Scene class]])
	{
		if (openGLview == nil)
		{
			[self setInterfaceOrientation:UIInterfaceOrientationPortrait];
		}
		if (openGLview != nil)
		{
			if (!openGLview.isActive)
			{
				if (current_view != nil)
					[current_view removeFromSuperview];
				[window addSubview:openGLview];
				[window bringSubviewToFront:openGLview];
				openGLview.isActive = YES;
			}
			[(Scene *)scene setView:openGLview];
			[openGLview setScene:(Scene *)scene];
			[openGLview resumeTimer];
		}
	}
}

-(void)clearScene:(Color4f)_clear_color
{
	glClearColor(_clear_color.red, _clear_color.blue, _clear_color.green, _clear_color.alpha);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

-(void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	if (openGLViewController != nil)
	{
		[openGLview removeFromSuperview];
		[openGLViewController release];
	}
	openGLViewController = [[OpenGLViewController alloc]initWithInterfaceOrientation:orientation];
	openGLview = [openGLViewController getOpenGLView];
    if ([window respondsToSelector:@selector(setRootViewController:)])
        [window setRootViewController:openGLViewController];
    else
        [window addSubview:openGLViewController.view];
	if (current_scene != nil)
		[self presentScene:current_scene];
	NSLog(@"Screen width %f",openGLview.frame.size.width);
}

-(void)dealloc
{
	[super dealloc];
	[openGLViewController release];
	[window release];
}


@end
