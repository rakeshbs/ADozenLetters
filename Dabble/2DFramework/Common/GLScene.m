//
//  CanvasClass.m
//
//  Created by Rakesh on 17/08/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "GLScene.h"
#import "OpenGLESView.h"

@implementation GLScene

static GLActivityIndicator *activityIndicator;

-(id)init
{
	if (self = [super init])
	{
        @synchronized(self)
        {
            if (activityIndicator == nil)
            {
                activityIndicator = [[GLActivityIndicator alloc]init];
            }
        }
//        [self addElement:activityIndicator];
	}
	return self;
}

-(CGRect)frame
{
    return CGRectMake(0, 0, director.openGLview.frame.size.width, director.openGLview.frame.size.height);
}

-(void)showActivityIndicator
{
    activityIndicator.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height/2, 0, 0);
    [activityIndicator moveToFront];
    [activityIndicator show];
}

-(void)hideActivityIndicator
{
    [activityIndicator hide];
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
