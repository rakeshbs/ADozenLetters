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

@synthesize touchesInElement;

@synthesize frame,numberOfLayers,tag,parent;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super init])
    {
        parent = nil;
        director = [GLDirector getSharedDirector];
        self.openGLView = director.openGLview;
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        touchesInElement = [[NSMutableArray alloc]init];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
        fontSpriteSheetManager = [FontSpriteSheetManager getSharedFontSpriteSheetManager];
        self.frame = _frame;
    }
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        parent = nil;
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

-(BOOL)touchable
{
    return YES;
}

-(CGRect)absoluteFrame
{
    if (parent == nil)
        return self.frame;
    CGRect parentFrame = self.parent.absoluteFrame;
    CGRect eFrame = self.frame;
    CGRect absFrame = CGRectMake(parentFrame.origin.x+eFrame.origin.x, parentFrame.origin.y+eFrame.origin.y, eFrame.size.width, eFrame.size.height);
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
    [self draw];
    [mvpMatrixManager translateInX:0 Y:0 Z:self.numberOfLayers];
    
    for (GLElement *element in subElements)
    {
        if (!element.hidden)
            [element drawElement];
    }
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
    [super dealloc];
    NSLog(@"deallocating element");
    self.parent = nil;
    self.touchesInElement = nil;
}
@end
