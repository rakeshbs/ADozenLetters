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

@synthesize frame,numberOfLayers,tag,parent,frameBackgroundColor;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super init])
    {
        self.frame = _frame;
        self.parent = nil;
        scaleInsideElement = CGPointMake(1.0, 1.0);
        originInsideElement = CGPointMake(0, 0);
        self.touchable = YES;
        director = [GLDirector getSharedDirector];
        self.openGLView = director.openGLview;
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
        rendererManager = [GLRendererManager sharedGLRendererManager];
        touchesInElement = [[NSMutableArray alloc]init];
        [self setUpBackgroundColorData];
        self.frameBackgroundColor = (Color4B){0,0,0,0};
        
    }
    return self;
}

-(void)setUpBackgroundColorData
{
    backgroundColorRenderer = [rendererManager getRendererWithVertexShaderName:@"ColorShader" andFragmentShaderName:@"ColorShader"];

    frameColorData = malloc(sizeof(VertexColorData) * 6);

   
    frameColorData[0].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
    frameColorData[1].vertex = (Vertex3D){.x = self.frame.size.width, .y = 0, .z = 0};
    frameColorData[2].vertex = (Vertex3D){.x = self.frame.size.width, .y = self.frame.size.height, .z = 0};
    frameColorData[3].vertex = (Vertex3D){.x = 0, .y = 0, .z = 0};
    frameColorData[4].vertex = (Vertex3D){.x = 0, .y = self.frame.size.height, .z = 0};
    frameColorData[5].vertex = (Vertex3D){.x = self.frame.size.width, .y = self.frame.size.height, .z = 0};

    
}

-(id)init
{
    if (self = [super init])
    {
        self.parent = nil;
        scaleInsideElement = CGPointMake(1.0, 1.0);
        originInsideElement = CGPointMake(0, 0);
         self.touchable = YES;
        director = [GLDirector getSharedDirector];
        self.openGLView = director.openGLview;
        animator = [Animator getSharedAnimator];
        textureManager = [TextureManager getSharedTextureManager];
        touchesInElement = [[NSMutableArray alloc]init];
        mvpMatrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
        rendererManager = [GLRendererManager sharedGLRendererManager];
        [self setUpBackgroundColorData];
        self.frameBackgroundColor = (Color4B){0,0,0,0};
        
    }
    return self;
}

-(BOOL)drawable
{
    return YES;
}


-(CGPoint)absoluteScale
{
    CGPoint _absoluteScale = CGPointMake(1.0,1.0);
       GLElement *cparent = self.parent;
    while (cparent != nil)
    {
        _absoluteScale = CGPointMake(cparent.scaleInsideElement.x * _absoluteScale.x,
                                    cparent.scaleInsideElement.y * _absoluteScale.y);
    }
    return _absoluteScale;
}


-(CGRect)absoluteFrame
{
    if (self.parent == nil)
        return self.frame;
    
    
    CGPoint absoluteScale = CGPointMake(1.0,1.0);
    CGPoint absoluteOrigin = self.frame.origin;
    GLElement *cparent = self.parent;
    
    while (cparent != nil)
    {
        CGPoint scale = cparent.scaleInsideElement;
        CGPoint origin = cparent.originInsideElement;
        absoluteScale = CGPointMake(cparent.scaleInsideElement.x * absoluteScale.x,
                                    cparent.scaleInsideElement.y * absoluteScale.y);
        
        CGRect parentFrame = cparent.frame;
        
        absoluteOrigin = CGPointMake(1 *(parentFrame.size.width/2) +
                                  (scale.x * (absoluteOrigin.x - parentFrame.size.width/2)),
                                  1 *(parentFrame.size.height/2) +
                                   (scale.y * (absoluteOrigin.y - parentFrame.size.height/2)));
        
       
        absoluteOrigin = CGPointMake(absoluteOrigin.x + parentFrame.origin.x + origin.x   ,
                                     absoluteOrigin.y + parentFrame.origin.y + origin.y);
        
        cparent = cparent.parent;
    }
    
    
    return CGRectMake(absoluteOrigin.x, absoluteOrigin.y,
                      self.frame.size.width * absoluteScale.x,
                      self.frame.size.height * absoluteScale.y);
}

-(int)numberOfLayers
{
    return 1;
}

-(BOOL)isDrawable
{
    return YES;
}

-(void)draw{
    
    
}

-(void)drawBatchedElements
{
    
}

//To be accessed only by OpenGLViewController;

-(void)resetZCoordinate
{
    ZCoordinate = 0;
}

static CGFloat ZCoordinate;

-(void)drawElement
{
    [self update];
    
    CGFloat startZCoordinate = ZCoordinate;
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:self.frame.origin.x Y:self.frame.origin.y Z:ZCoordinate];

    if ([self isDrawable] && !self.hidden)
    {
        if (frameBackgroundColor.alpha > 0)
        {
            ZCoordinate++;
            [mvpMatrixManager translateInX:0 Y:0 Z:1];
            [backgroundColorRenderer drawWithArray:frameColorData andCount:6];
         }
        [self draw];
        
    }
    
    [mvpMatrixManager translateInX:0 Y:0 Z:-startZCoordinate];

    ZCoordinate += self.numberOfLayers;
    
    [mvpMatrixManager translateInX:self.frame.size.width/2+self.originInsideElement.x
                                 Y:self.frame.size.height/2+self.originInsideElement.y Z:0];

    
    [mvpMatrixManager scaleByXScale:self.scaleInsideElement.x  YScale:self.scaleInsideElement.y ZScale:1];
    
    [mvpMatrixManager translateInX:(-self.frame.size.width/2)
                                 Y:(-self.frame.size.height/2)
                                 Z:0];
    

    for (GLElement *element in subElements)
    {
        if (!element.hidden)
            [element drawElement];
    }
    
    [mvpMatrixManager translateInX:0 Y:0 Z:startZCoordinate];

    [self drawBatchedElements];
    
    [mvpMatrixManager translateInX:0 Y:0 Z:-startZCoordinate];

    [mvpMatrixManager popModelViewMatrix];
    
}
 
-(void)update
{
    
}

-(void)setFrameBackgroundColor:(Color4B)_backgroundColor
{
    frameBackgroundColor = _backgroundColor;
    for (int i = 0;i<6;i++)
    { 
        frameColorData[i].color = frameBackgroundColor;
    }
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
    CGRect absframe = self.absoluteFrame;
    if (l.x >= 0 && l.y >=0 && l.x <=absframe.size.width && l.y<=absframe.size.height)
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
        CGPoint touchPoint = [touch locationInGLElement:self];
        CGRect absframe = self.absoluteFrame;
        if (touchPoint.x >= 0 && touchPoint.y >= 0 &&
            touchPoint.x <= absframe.size.width && touchPoint.y <=absframe.size.height)
                [self touchEndedInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
        else
                [self touchCancelledInElement:touch withIndex:[touchesInElement indexOfObject:touch] withEvent:event];
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

-(void)touchCancelledInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    
}




-(void)dealloc
{
    free(frameColorData);
    [subElements release];
    self.parent = nil;
    self.touchesInElement = nil;
    [super dealloc];
}
@end
