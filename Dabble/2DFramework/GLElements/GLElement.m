//
//  GLNode.m
//  GameDemo
//
//  Created by Trucid on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLElement.h"
#import "Scene.h"

@interface GLElement (Private)
-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
@end

@implementation GLElement

@synthesize touchesInElement,triangleColorShader;

@synthesize scene,frame;

-(id)init
{
    if (self = [super init])
    {
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        touchesInElement = [[NSMutableArray alloc]init];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
    }
    return self;
}

-(void)draw{
    
}
-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint l = [touch locationInView:self.scene.view];
    if (CGRectContainsPoint(self.frame, l))
    {
        [touchesInElement addObject:touch];
        [self touchBeganInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        return YES;
    }
    
    return NO;
}
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touchesInElement containsObject:touch])
    {
        [self touchMovedInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        return YES;
    }
    return NO;
}
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touchesInElement containsObject:touch])
    {
        [self touchEndedInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        [touchesInElement removeObject:touch];
        return YES;
    }
    return NO;
}

-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	
}
-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	
}
-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	
}

-(void)moveToFront
{
    [self.scene moveElementToFront:self];
}


-(void)dealloc
{
    [super dealloc];
    self.scene = nil;
}
@end
