//
//  OpenGLViewController.m
//  GameDemo
//
//  Created by Rakesh on 12/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "OpenGLViewController.h"


@implementation OpenGLViewController

@synthesize interfaceOrientation;

-(id)initWithInterfaceOrientation:(UIInterfaceOrientation)_interfaceOrientation
{
	if (self = [super init])
	{
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
		interfaceOrientation = _interfaceOrientation;
		switch (interfaceOrientation){
			case UIInterfaceOrientationLandscapeLeft:
				NSLog(@"Setting Landscape");
				self.view = [[OpenGLESView alloc]initWithFrame:CGRectMake(0, 0, screen_height, screen_width)];
				break;
			case UIInterfaceOrientationPortrait:
				NSLog(@"Setting Portrait");
				self.view = [[OpenGLESView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];				
				break;
			case UIInterfaceOrientationLandscapeRight:
				NSLog(@"Setting Landscape");
				self.view = [[OpenGLESView alloc]initWithFrame:CGRectMake(0, 0, screen_height, screen_width)];
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				NSLog(@"Setting Portrait");
				self.view = [[OpenGLESView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
				break;
		}
	}
	return self;
}
	
-(OpenGLESView *)getOpenGLView
{
	return (OpenGLESView *)self.view;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)_interfaceOrientation {
    return (_interfaceOrientation == interfaceOrientation);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
