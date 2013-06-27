//
//  Director.h
//  GameDemo
//
//  Created by Rakesh on 11/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenGLESView.h"
#import "OpenGLViewController.h"

#define deviceiPhoneNonRetina 1;
#define deviceiPhoneRetina 2;
#define deviceiPhone5 3;
#define deviceiPadNonRetina 4;
#define deviceiPadRetina 5;

@class GLScene;

@interface GLDirector : NSObject {
	NSObject *current_scene;
	UIWindow *window;
	OpenGLViewController *openGLViewController;
	OpenGLESView *openGLview;
	CGRect openGLframe;
	UIView *current_view;
	GLfloat interfaceRotateAngle;
	GLfloat interfaceTranslation_x;
	GLfloat interfaceTranslation_y;
	NSTimer *animationTimer;
    
    BOOL defaultShadersLoaded;
}

@property (nonatomic,retain) UIWindow *window;
@property (nonatomic,readonly) OpenGLESView *openGLview;
@property (nonatomic,readonly) OpenGLViewController *openGLViewController;
+(id)getSharedDirector;
-(void)presentScene:(NSObject *)scene;
-(void)setInterfaceOrientation:(UIInterfaceOrientation)orientation;
-(void)clearScene:(Color4B)_clear_color;
@end
