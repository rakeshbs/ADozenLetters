//
//  CanvasClass.h
//  MusiMusi
//
//  Created by Trucid on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Director.h"
#import "GLElement.h"
#import "TextureManager.h"
#import "Animator.h"
#import "MVPMatrixManager.h"
#import "ColorRenderer.h"
#import "TextureRenderer.h"

@interface Scene : NSObject {
	UIView *view;
	Director *director;
    TextureManager *textureManager;
    MVPMatrixManager *mvpMatrixManager;
	NSMutableArray *elements;
    Animator *animator;
    NSMutableArray *touchesInScene;
    ColorRenderer *triangleColorRenderer;
    TextureRenderer *textureRenderer;
}
@property (nonatomic,retain) UIView *view;
@property (nonatomic,retain) Director *director;
-(void)addElement:(GLElement *)_element;
-(void)sceneMadeActive;
-(void)sceneMadeInActive;
-(void)draw;
-(void)update;
-(void)drawElements;
-(void)redraw;
-(BOOL)touchBeganInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(BOOL)touchesMovedInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event;
-(BOOL)touchesEndedInScene:(UITouch *)touches withIndex:(int)index withEvent:(UIEvent *)event;

-(void)moveElementToFront:(GLElement *)element;
-(int)indexOfElement:(GLElement *)element;
@end
