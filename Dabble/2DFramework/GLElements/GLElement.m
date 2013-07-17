//
//  GLNode.m
//  GameDemo
//
//  Created by Rakesh on 11/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import "GLElement.h"
#import "GLScene.h"

@interface GLElement (Private)
-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;

-(void)reindexSubElements;
-(void)draw;
@end

@implementation GLElement

@synthesize touchesInElement,originInsideElement,scaleInsideElement;

@synthesize frame,numberOfLayers,tag,parent;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super init])
    {
        self.parent = nil;
        scaleInsideElement = CGPointMake(1.0, 1.0);
        originInsideElement = CGPointMake(0, 0);
        director = [GLDirector getSharedDirector];
        self.openGLView = director.openGLview;
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
        fontSpriteSheetManager = [FontSpriteSheetManager getSharedFontSpriteSheetManager];
        rendererManager = [GLRendererManager sharedGLRendererManager];
        self.frame = _frame;
        touchesInElement = [[NSMutableArray alloc]init];
    }
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        self.parent = nil;
        scaleInsideElement = CGPointMake(1.0, 1.0);
        originInsideElement = CGPointMake(0, 0);
        
        director = [GLDirector getSharedDirector];
        self.openGLView = director.openGLview;
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        touchesInElement = [[NSMutableArray alloc]init];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
        fontSpriteSheetManager = [FontSpriteSheetManager getSharedFontSpriteSheetManager];
    }
    return self;
}

-(BOOL)drawable
{
    return YES;
}

-(BOOL)touchable
{
    return YES;
}

-(CGPoint)absoluteScale
{
    if (self.parent == nil)
        return CGPointMake(1.0, 1.0);
    if (self.parent.parent == nil)
        return self.parent.scaleInsideElement;
    
    CGPoint parentAbsoluteScale = parent.scaleInsideElement;
    
    CGPoint parentParentAbsoluteScale = parent.parent.absoluteScale;
    
    return CGPointMake(parentAbsoluteScale.x * parentParentAbsoluteScale.x,
                       parentAbsoluteScale.y * parentParentAbsoluteScale.y);
}

-(CGRect)absoluteFrame
{
    if (parent == nil)
        return self.frame;
    CGRect parentFrame = self.parent.absoluteFrame;
    CGRect eFrame = self.frame;
    CGRect absFrame = CGRectMake(parentFrame.origin.x+eFrame.origin.x+self.originInsideElement.x, parentFrame.origin.y+eFrame.origin.y + parent.originInsideElement.y, eFrame.size.width, eFrame.size.height);
    return absFrame;
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

    [mvpMatrixManager translateInX:self.frame.origin.x Y:self.frame.origin.y Z:0];
    if (self.drawable)
        [self draw];
    [mvpMatrixManager translateInX:0 Y:0 Z:self.numberOfLayers];
    
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:self.frame.size.width/2 Y:self.frame.size.height/2 Z:0];
    
    [mvpMatrixManager scaleByXScale:scaleInsideElement.x  YScale:scaleInsideElement.y ZScale:1];
    
    [mvpMatrixManager translateInX:-self.frame.size.width/2 Y:-self.frame.size.height/2 Z:0];
    

    [mvpMatrixManager translateInX:self.originInsideElement.x/scaleInsideElement.x
                                 Y:self.originInsideElement.y/scaleInsideElement.y Z:0];

    for (GLElement *element in subElements)
    {
        if (!element.hidden)
            [element drawElement];
    }
    [mvpMatrixManager popModelViewMatrix];
    [mvpMatrixManager translateInX:-self.frame.origin.x Y:-self.frame.origin.y Z:0];
}
 
-(void)update
{
    
}



-(void)addElement:(GLElement *)e
{
    if (subElements == nil)
        subElements = [[NSMutableArray alloc]init];
    e.indexOfElement = subElements.count;
    e.parent = self;
    [subElements addObject:e];
    [e addedToParent];
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
    [e willRemoveFromParent];
    [subElements removeObject:e];
    [self reindexSubElements];
}

-(void)removeAllElements
{
    [subElements removeAllObjects];
}

-(void)moveToFront
{
    [self.parent moveElementToFront:self];
}
-(void)moveToBack
{
    [self.parent moveElementToBack:self];
}
-(void)moveToIndex:(int)index
{
    [self.parent moveElement:self toIndex:index];
}

-(void)removeFromParent
{
    [self.parent removeElement:self];
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

-(void)addedToParent
{
    
}

-(void)willRemoveFromParent
{
    
}

-(GLElement *)getElementByTag:(int)etag
{
    for (GLElement *e in subElements)
    {
        if (e.tag == etag)
            return e;
    }
    return nil;
}


-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint l = [touch locationInGLElement:self];
    if (l.x >= 0 && l.y >=0 && l.x <=self.frame.size.width && l.y<=self.frame.size.height)
    {
        for (GLElement *element in subElements.reverseObjectEnumerator)
        {
            if ([element touchBegan:touch withEvent:event])
                return YES;
        }
        
        if (!self.touchable)
            return NO;
        
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
        if ([element touchMoved:touch withEvent:event])
            return YES;
    }
    
    if (!self.touchable)
        return NO;
    
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
        if ([element touchEnded:touch withEvent:event])
            return YES;
    }
    
    if (!self.touchable)
        return NO;
    
    
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
    NSLog(@"deallocating element");
    [subElements release];
    [touchesInElement release];
    self.parent = nil;
    self.touchesInElement = nil;
    [super dealloc];
}
@end
