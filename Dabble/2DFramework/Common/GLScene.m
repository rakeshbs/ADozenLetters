//
//  CanvasClass.m
//
//  Created by Rakesh on 17/08/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "GLScene.h"
#import "OpenGLESView.h"

@implementation GLScene

-(id)init
{
	if (self = [super init])
	{
		

	}
	return self;
}

-(CGRect)frame
{
    return CGRectMake(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height);
}

-(void)sceneMadeActive
{
    
}
-(void)sceneMadeInActive
{
    
}

-(void)dealloc
{
    [super dealloc];
 
}

@end
