//
//  AppDelegate.m
//  Tiles
//
//  Created by Rakesh on 19/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "AppDelegate.h"
#import "GraphicsFrameWork.h"
#import "GameScene.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[GLDirector getSharedDirector]setWindow:self.window];
    [[GLDirector getSharedDirector]setInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    GLActivityIndicator *activityIndicator = [[GLActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    activityIndicator.hidden = NO;
    GLScene *scene = [[GLScene alloc]init];
    [scene addElement:activityIndicator];
    

    [[GLDirector getSharedDirector]presentScene:scene];
    [[[GLDirector getSharedDirector] openGLview]drawView];
    [activityIndicator show];
    activityIndicator.delegate = self;
    [[[GLDirector getSharedDirector] openGLview] resumeTimer];
    return YES;
}



-(void)activitiyIndicatorFinishedAnimating:(GLActivityIndicator *)activityIndicator
{
    if (activityIndicator.iteration == 1)
    {
        gameScene = [[GameScene alloc]init];
        [activityIndicator animate];
    }
    else if (activityIndicator.iteration == 2)
    {
        [[GLDirector getSharedDirector]presentScene:gameScene];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"backgrounding");
    GLDirector *director = [GLDirector getSharedDirector];
    [director.openGLview pauseTimer];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"backgrounding 2");
    GLDirector *director = [GLDirector getSharedDirector];
    [director.openGLview pauseTimer];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    GLDirector *director = [GLDirector getSharedDirector];
   [director.openGLview resumeTimer];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
