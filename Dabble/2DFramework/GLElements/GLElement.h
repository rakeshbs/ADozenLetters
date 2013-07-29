//
//  GLNode.h
//  GameDemo
//
//  Created by Rakesh on 11/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animator.h"
#import "TextureManager.h"
#import "MVPMatrixManager.h"
#import "OpenGLESView.h"
#import "GLDirector.h"
#import "SpriteSheet.h"
#import "FontSpriteSheet.h"
#import "UITouch+GLElement.h"
#import "GLShaderManager.h"
#import "GLRendererManager.h"
#import "EasingFunctions.h"

@interface GLElement : NSObject
{
    CGRect frame;
    GLElement *parent;
    
    int tag;
    int numberOfLayers;
    
    NSMutableArray *touchesInElement;
    NSMutableArray *subElements;
    
    GLDirector *director;
    Animator *animator;
    TextureManager *textureManager;
    MVPMatrixManager *mvpMatrixManager;
    GLShaderManager *shaderManager;
    GLRendererManager *rendererManager;
    
    CGPoint scaleInsideElement;
    CGPoint originInsideElement;
    
    VertexColorData *frameColorData;
    GLRenderer *backgroundColorRenderer;
    
    Color4B frameBackgroundColor;
}

@property (nonatomic) BOOL hidden;
@property (nonatomic) int tag;
@property (nonatomic) int indexOfElement;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint scaleInsideElement;
@property (nonatomic) CGPoint originInsideElement;

@property (nonatomic,readonly) CGPoint absoluteScale;
@property (nonatomic,readonly) CGRect absoluteFrame;
@property (nonatomic,readonly) int numberOfLayers;
@property (nonatomic,assign) BOOL touchable;


@property (nonatomic,retain) GLElement *parent;
@property (nonatomic,retain) OpenGLESView *openGLView;
@property (nonatomic,retain) NSMutableArray *touchesInElement;
@property (nonatomic) Color4B frameBackgroundColor;


-(void)drawElement;
-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
-(void)update;
-(void)draw;

-(id)initWithFrame:(CGRect)_frame;
-(void)addElement:(GLElement *)e;
-(void)moveElementToFront:(GLElement *)e;
-(void)moveElementToBack:(GLElement *)e;
-(void)moveElement:(GLElement *)e toIndex:(int)index;
-(void)removeElement:(GLElement *)e;
-(void)removeAllElements;
-(void)moveToFront;
-(void)moveToBack;
-(void)moveToIndex:(int)index;
-(GLElement *)getElementByTag:(int)etag;

-(void)addedToParent;
-(void)willRemoveFromParent;

//To be accessed only by OpenGLViewController;
-(void)resetZCoordinate;
@end
