//
//  Director.m
//  GameDemo
//
//  Created by Rakesh on 11/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "GLDirector.h"
#import "GLScene.h"

@interface GLDirector (Private)

@end


@implementation GLDirector

@synthesize window,openGLview,openGLViewController,current_scene;

+(id)getSharedDirector
{
	static GLDirector *dir;
	@synchronized(self)
	{
		if (dir == nil)
		{
			dir = [[GLDirector alloc]init];
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
	if ([scene isKindOfClass:[GLScene class]])
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
			[(GLScene *)scene setOpenGLView:openGLview];
			[openGLview setScene:(GLScene *)scene];
            current_scene = scene;
		}
	}
}

-(void)clearScene:(Color4B)_clear_color
{
	glClearColor(_clear_color.red/255.0f, _clear_color.blue/255.0f, _clear_color.green/255.0f, _clear_color.alpha/255.0f);
//	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
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
//    ColorRenderer *shader1 = [[ColorRenderer alloc]init];
  //  [shader1 release];
  /*  TextureRenderer *shader2 = [[TextureRenderer alloc]init];
    [shader2 release];
    */
}

-(void)dealloc
{

	[openGLViewController release];
	[window release];
    	[super dealloc];
}


@end
