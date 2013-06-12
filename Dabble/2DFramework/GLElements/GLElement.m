//
//  GLNode.m
//  GameDemo
//
//  Created by Rakesh on 11/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "GLElement.h"
#import "Scene.h"

@interface GLElement (Private)
-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;

-(void)reindexSubElements;
@end

@implementation GLElement

@synthesize touchesInElement;

@synthesize frame,numberOfLayers,tag,openGLView,parent;

-(id)init
{
    if (self = [super init])
    {
        parent = nil;
        director = [Director getSharedDirector];
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        touchesInElement = [[NSMutableArray alloc]init];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
    }
    return self;
}

-(CGRect)absoluteFrame
{
    if (parent == nil)
        return self.frame;
    CGRect parentFrame = self.parent.absoluteFrame;
    CGRect eFrame = self.frame;
    return CGRectMake(parentFrame.origin.x+eFrame.origin.x, parentFrame.origin.y+eFrame.origin.y, eFrame.size.width, eFrame.size.height);
}

-(int)numberOfLayers
{
    return 1;
}

-(void)draw{
    
    
}


-(void)drawElement
{
    [self update];

    [mvpMatrixManager translateInX:self.frame.origin.x Y:self.frame.origin.y Z:self.openGLView.currentZLayer];
    [self draw];
    
    for (GLElement *element in subElements)
    {
        [element update];
        [element drawElement];
    }
    self.openGLView.currentZLayer += self.numberOfLayers;
    [mvpMatrixManager translateInX:-self.frame.origin.x Y:-self.frame.origin.y Z:0];
}

-(void)update
{
    
}


-(void)addElement:(GLElement *)e
{
    if (subElements == nil)
        subElements = [[NSMutableArray alloc]init];
    [subElements addObject:e];
    e.indexOfElement = subElements.count-1;
    e.openGLView = self.openGLView;
    e.parent = self;
}

-(void)moveElementToFront:(GLElement *)e
{
    [e retain];
    [subElements removeObject:e];
    [subElements addObject:e];
    [e release];
    
    [self reindexSubElements];
}

-(void)moveElementToBack:(GLElement *)e
{
    [e retain];
    [subElements removeObject:e];
    [subElements insertObject:e atIndex:0];
    [e release];
    
    [self reindexSubElements];
}

-(void)moveElement:(GLElement *)e toIndex:(int)index
{
    [e retain];
    [subElements removeObject:e];
    [subElements insertObject:e atIndex:index];
    [e release];
    
    [self reindexSubElements];
}

-(void)removeElement:(GLElement *)e
{
    [subElements removeObject:e];
    [self reindexSubElements];
}

-(void)removeAllElements
{
    [subElements removeAllObjects];
}


-(void)reindexSubElements
{
    int index = 0;
    for (GLElement *element in subElements)
    {
        element.indexOfElement = index;
        index++;
    }
}

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (GLElement *element in subElements.reverseObjectEnumerator)
    {
        if ([self touchBegan:touch withEvent:event])
            return YES;
    }
    
    CGPoint l = [touch locationInGLElement:self];
    if (l.x >= 0)
    {
        [touchesInElement addObject:touch];
        [self touchBeganInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        return YES;
    }
    
    return NO;
}
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (GLElement *element in subElements.reverseObjectEnumerator)
    {
        if ([self touchMoved:touch withEvent:event])
            return YES;
    }
    
    if ([touchesInElement containsObject:touch])
    {
        [self touchMovedInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        return YES;
    }
    return NO;
}
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (GLElement *element in subElements.reverseObjectEnumerator)
    {
        if ([self touchEnded:touch withEvent:event])
            return YES;
    }
    
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

-(void)dealloc
{
    [super dealloc];
    NSLog(@"deallocating element");
    self.parent = nil;
    self.openGLView = nil;
    self.touchesInElement = nil;
}
@end
