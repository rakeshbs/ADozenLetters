//
//  Director.h
//  GameDemo
//
//  Created by Trucid on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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

@class Scene;

@interface Director : NSObject {
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
}

@property (nonatomic,retain) UIWindow *window;
@property (nonatomic,readonly) OpenGLESView *openGLview;
@property (nonatomic,readonly) OpenGLViewController *openGLViewController;
+(id)getSharedDirector;
-(void)presentScene:(NSObject *)scene;
-(void)setInterfaceOrientation:(UIInterfaceOrientation)orientation;
-(void)clearScene:(Color4f)_clear_color;
@end
