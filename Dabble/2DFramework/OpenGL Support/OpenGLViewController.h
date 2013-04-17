//
//  OpenGLViewController.h
//  GameDemo
//
//  Created by Rakesh on 12/11/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLESView.h"

@interface OpenGLViewController : UIViewController {
	UIInterfaceOrientation interfaceOrientation;
}
@property (nonatomic,readonly) UIInterfaceOrientation interfaceOrientation;

-(OpenGLESView *)getOpenGLView;
-(id)initWithInterfaceOrientation:(UIInterfaceOrientation)_interfaceOrientation;
@end
