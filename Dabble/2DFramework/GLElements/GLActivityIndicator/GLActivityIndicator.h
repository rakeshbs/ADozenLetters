//
//  GLActivityIndicator.h
//  Dabble
//
//  Created by Rakesh on 02/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLElement.h"

@class GLActivityIndicator;

@protocol GLActivityIndicatorDelegate
@optional
-(void)activitiyIndicatorFinishedAnimating:(GLActivityIndicator *)activityIndicator;
-(void)activityIndicatorDidAappear:(GLActivityIndicator *)activityIndicator;
-(void)activityIndicatorDidDisappear:(GLActivityIndicator *)activityIndicator;
@end

@interface GLActivityIndicator : GLElement <AnimationDelegate>
{
    NSMutableArray *activityPoints;
    PointVertexColorSizeData *pointsData;
    
    float relativePosition;
    
    int iteration;
    
    int cycleCount;
    BOOL cycleModeOpen;
   
    GLRenderer *pointsRenderer;

}
@property (nonatomic,readonly)  int iteration;
@property (nonatomic,retain) NSObject<GLActivityIndicatorDelegate> *delegate;

-(void)animate;
-(void)show;
-(void)hide;

@end
