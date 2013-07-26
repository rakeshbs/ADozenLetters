//
//  AppDelegate.h
//  OpenGLES2.0
//
//  Created by Rakesh on 20/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLActivityIndicator.h"
#import "GameScene.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,GLActivityIndicatorDelegate>
{
    GameScene *gameScene;
}
@property (strong, nonatomic) UIWindow *window;

@end
