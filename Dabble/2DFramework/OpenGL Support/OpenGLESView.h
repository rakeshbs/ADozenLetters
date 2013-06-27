//
//  OpenGLES2DView.h
//  GLFun
//
//  Created by Jeff LaMarche on 8/5/08.
//  Copyright 2008 msolidair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "GLCommon.h"
#import "Animator.h"

@class GLScene;

@interface OpenGLESView : UIView {

@protected
	EAGLContext *context;
	GLuint viewRenderbuffer, viewFramebuffer,depthBuffer,sampleFramebuffer,sampleColorRenderbuffer,sampleDepthRenderbuffer;
	GLint backingWidth, backingHeight;
	NSTimer *animationTimer;

	GLScene *view_delegate;
	BOOL isLoopRunning;
	CFTimeInterval refreshTimeInterval;
	CFTimeInterval currentTime;
	BOOL isActive;
    
    int currentZLayer;
    Animator *animator;
}

@property (nonatomic) int currentZLayer;
@property (nonatomic) GLuint viewRenderbuffer;
@property (nonatomic) GLuint  viewFramebuffer;
@property (nonatomic,retain) EAGLContext *context;
@property (nonatomic,retain) GLScene *view_delegate;
@property (nonatomic) BOOL isActive;
@property (nonatomic,retain) NSTimer *animationTimer;
@property (nonatomic,retain) CADisplayLink *displayLink;
-(void)bindBuffers;
-(void)setScene:(GLScene *)scene;
-(void)resumeTimer;
-(void)pauseTimer;
-(void)drawView;

@end
