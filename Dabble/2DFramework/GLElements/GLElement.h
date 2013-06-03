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
#import "BatchColorRenderer.h"
#import "BatchTextureRenderer.h"
#import "OpenGLESView.h"
#import "Director.h"
#import "UITouch+GLElement.h"

@interface GLElement : NSObject
{
    OpenGLESView *openGLView;
    Director *director;
    CGRect frame;
    GLElement *parent;
    
    
    int numberOfLayers;
    int tag;
    
    NSMutableArray *touchesInElement;
    NSMutableArray *subElements;
    
    TextureManager *textureManager;
    MVPMatrixManager *mvpMatrixManager;
    Animator *animator;
}


@property (nonatomic,readonly) CGRect absoluteFrame;
@property (nonatomic) int tag;
@property (nonatomic,readonly) int numberOfLayers;
@property (nonatomic,retain) OpenGLESView *openGLView;
@property (nonatomic) int indexOfElement;
@property (nonatomic,retain) GLElement *parent;

@property (nonatomic)   CGRect frame;
@property (nonatomic,retain) NSMutableArray *touchesInElement;
-(void)draw;
-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)moveToFront;
-(void)update;
@end
