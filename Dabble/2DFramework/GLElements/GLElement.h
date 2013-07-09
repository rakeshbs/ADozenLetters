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
#import "UITouch+GLElement.h"
#import "GLShaderManager.h"
#import "FontSpriteSheetManager.h"
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
    FontSpriteSheetManager *fontSpriteSheetManager;
    GLRendererManager *rendererManager;
    
    CGFloat scaleInsideElement;
    CGPoint originInsideElement;
    
}

@property (nonatomic) CGFloat scaleInsideElement;
@property (nonatomic) CGPoint originInsideElement;
@property (nonatomic) int tag;
@property (nonatomic) int indexOfElement;
@property (nonatomic)   CGRect frame;


@property (nonatomic,readonly) CGRect absoluteFrame;
@property (nonatomic,readonly) int numberOfLayers;
@property (nonatomic,readonly) BOOL touchable;
@property (nonatomic,readonly) BOOL drawable;
@property (nonatomic) BOOL hidden;

@property (nonatomic,retain) GLElement *parent;
@property (nonatomic,retain) OpenGLESView *openGLView;
@property (nonatomic,retain) NSMutableArray *touchesInElement;


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
@end
