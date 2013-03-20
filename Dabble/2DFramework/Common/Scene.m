//
//  CanvasClass.m
//
//  Created by Trucid on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Scene.h"
#import "Scene+Private.h"
#import "OpenGLESView.h"

@implementation Scene
@synthesize view,director;

-(id)init
{
	if (self = [super init])
	{
		director = [Director getSharedDirector];
		view = director.openGLview;
        textureManager = [TextureManager getSharedTextureManager];
        touchesInScene = [[NSMutableArray alloc]init];
        animator = [Animator getSharedAnimator];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
	}
	return self;
}

-(void)drawScene
{
    [self update];
    [animator update];
	[self draw];
	[self drawElements];
  
}

-(void)draw{
    
	Color4f color;
	color.red = 1;
	color.blue = 1;
	color.green = 1;
	color.alpha = 1;
	[director clearScene:color];
}
-(void)redraw
{
    [(OpenGLESView *)self.view drawView];
}

-(void)update
{
    
}

-(void)addElement:(GLElement *)_element
{
	if (elements == nil)
		elements = [[NSMutableArray alloc]init];
    [_element setScene:self];
	[elements addObject:_element];
}

-(void)sceneMadeActive
{

};
-(void)sceneMadeInActive
{
   /* [touchesInScene removeAllObjects];
    for (GLElement *e in elements)
        [e.touchesInElement removeAllObjects];*/
}
;
-(void)drawElements{
	for(GLElement *e in elements)
		[e draw];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for (UITouch *touch in touches)
    {
        BOOL handled = NO;
        GLElement *touchedElement;
        for (GLElement *e in elements)
        {
            handled = [e touchBegan:touch withEvent:event];
            if (handled)
            {
                touchedElement = e;
                break;
            }
        }
        if (handled)
        {
            [touchedElement retain];
            [elements removeObject:touchedElement];
            [elements addObject:touchedElement];
            [touchedElement release];
        }
        else
        {
            [touchesInScene addObject:touch];
            [self touchBeganInScene:touch withIndex:[touchesInScene indexOfObject:touch] withEvent:event];
        }
    }

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        BOOL handled = NO;
        GLElement *touchedElement;
        for (GLElement *e in elements)
        {
            handled = [e touchMoved:touch withEvent:event];
            if (handled)
            {
                touchedElement = e;
                break;
            }
        }
        if (handled)
        {
            
        }
        else
        {
            if ([touchesInScene containsObject:touch])
                [self touchesMovedInScene:touch
                                withIndex:[touchesInScene indexOfObject:touch]
                                withEvent:event];
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches)
    {
        BOOL handled = NO;
        GLElement *touchedElement;
        for (GLElement *e in elements)
        {
            handled = [e touchEnded:touch withEvent:event];
            if (handled)
            {
              //  touchedElement = e;
                break;
            }
        }
        if (handled)
        {
          
        }
        else
        {
            if ([touchesInScene containsObject:touch])
            {
                [self touchesEndedInScene:touch
                                withIndex:[touchesInScene indexOfObject:touch]
                                withEvent:event];
                [touchesInScene removeObject:touch];
            }
        }
    }
}

-(void)moveElementToFront:(GLElement *)element
{
    int index = [elements indexOfObject:element];
    [elements addObject:element];
    [elements removeObjectAtIndex:index];
}

-(BOOL)touchBeganInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event{
	return YES;
}
-(BOOL)touchesMovedInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event{
	return YES;
}
-(BOOL)touchesEndedInScene:(UITouch *)touches withIndex:(int)index withEvent:(UIEvent *)event
{
    return YES;
}

@end
