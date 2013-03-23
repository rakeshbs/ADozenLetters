//
//  main.m
//  OpenGLES2.0
//
//  Created by Rakesh on 20/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        int retVal = -1;
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException* exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
        return retVal;
    }
    
    
}
