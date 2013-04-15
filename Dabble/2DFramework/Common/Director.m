//
//  Director.m
//  GameDemo
//
//  Created by Trucid on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Director.h"
#import "Scene.h"
#import "ColorRenderer.h"
#import "TextureRenderer.h"

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

-(id)init
{
    if (self = [super init])
    {
        defaultShadersLoaded = NO;

    }
    return self;
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

-(void)clearScene:(Color4B)_clear_color
{
 //   glClearColor(1.0f,0.0f,0.0f,1.0f);
//    glClearColorx((GLfixed)0,(GLfixed)0,(GLfixed)0,(GLfixed)1);
	glClearColor(_clear_color.red/255.0f, _clear_color.blue/255.0f, _clear_color.green/255.0f, _clear_color.alpha/255.0f);
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
    
    if (!defaultShadersLoaded)
    {
        defaultShadersLoaded = YES;
        [self loadShaders];
    }
}

-(void)loadShaders
{
    ColorRenderer *shader1 = [[ColorRenderer alloc]init];
    [shader1 release];
    TextureRenderer *shader2 = [[TextureRenderer alloc]init];
    [shader2 release];
    
}

-(void)dealloc
{
	[super dealloc];
	[openGLViewController release];
	[window release];
}


@end
