//
//  OpenGLES2DView.m
//  GLFun
//
//  Created by Jeff LaMarche on 8/5/08.
//  Copyright 2008 msolidair. All rights reserved.
//

#import "OpenGLESView.h"
#import "Scene.h"
#import "Scene+Private.h"
#import "MVPMatrixManager.h"

@interface OpenGLESView (Private)

@end


@implementation OpenGLESView

@synthesize viewRenderbuffer, viewFramebuffer,context,view_delegate,isActive,animationTimer;

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

#pragma mark -
- (BOOL)createFramebuffer {
	
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
    
    
    glGenRenderbuffers(1, &depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
    
    
    /*
    //Multisampling
    
    glGenFramebuffers(1, &sampleFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, sampleFramebuffer);
    
    glGenRenderbuffers(1, &sampleColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleColorRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, sampleColorRenderbuffer);
    
    glGenRenderbuffers(1, &sampleDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleDepthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, sampleDepthRenderbuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    
    */
	
	return YES;
}
- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		// Get the layer
        
        if ([self respondsToSelector:@selector(contentScaleFactor)])
        {
            self.contentScaleFactor = [[UIScreen mainScreen] scale];
        }
        
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
		
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
        glViewport(0, 0, backingWidth, backingHeight);
		glEnable(GL_DEPTH_TEST);
        glDisable(GL_ALPHA_TEST);
        
        NSLog(@"%d %d %f %f",backingWidth,backingHeight,self.frame.size.width,self.frame.size.height);
        
        [[MVPMatrixManager sharedMVPMatrixManager] setOrthoProjection:-self.frame.size.width
                                            :0 :-self.frame.size.height
                                            :0 :-1 :1000];
		
        glClearColor(1, 1, 1, 1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
	
	self.multipleTouchEnabled = YES;
	return self;
}

-(void)drawView
{    
  //  glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
   // while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002, TRUE) == kCFRunLoopRunHandledSource){};
    currentZLayer = 1;
    
    [view_delegate drawScene];
    
 //   glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, viewFramebuffer);
 //   glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, sampleFramebuffer);
  //  glResolveMultisampleFramebufferAPPLE();
    
//    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}


-(void)setScene:(Scene *)scene
{
	if (view_delegate != nil)
		[view_delegate sceneMadeInActive];
	self.view_delegate = scene;
	scene.openGLView = self;
	refreshTimeInterval = CFAbsoluteTimeGetCurrent();
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
		[view_delegate touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [view_delegate touchesMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [view_delegate touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [view_delegate touchesEnded:touches withEvent:event];
}

-(void)pauseTimer
{
    [view_delegate sceneMadeInActive];
	isLoopRunning = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(drawView) object:nil];
    [self.displayLink invalidate];
    self.displayLink = nil;
}

-(void)resumeTimer
{
	if (!isLoopRunning)
	{
		isLoopRunning = YES;
		self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [view_delegate sceneMadeActive];
	}
}

-(void)bindBuffers
{
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	
}

- (void)dealloc {
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteFramebuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;

    glDeleteFramebuffersOES(1, &sampleFramebuffer);
	glDeleteFramebuffersOES(1, &sampleColorRenderbuffer);
    glDeleteFramebuffersOES(1, &sampleDepthRenderbuffer);
	glDeleteFramebuffersOES(1, &viewRenderbuffer);

	[super dealloc];
}


@end
