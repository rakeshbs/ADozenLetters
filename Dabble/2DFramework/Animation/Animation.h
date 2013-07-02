//
//  Animation.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Animation;

@protocol AnimationDelegate
-(BOOL)animationUpdate:(Animation *)animation;
@optional
-(void)animationStarted:(Animation *)animation;
-(void)animationEnded:(Animation *)animation;
@end

@interface Animation : NSObject
{
  
}
@property (nonatomic,retain) NSObject <AnimationDelegate> *animatedObject;

@property (nonatomic)  NSTimeInterval queuedTime;
@property (nonatomic)  NSTimeInterval  startTime;
@property (nonatomic) NSTimeInterval startDelay;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) int type;
@property (nonatomic,retain) NSObject *animationData;


-(CGFloat)getAnimatedRatio;
-(BOOL)canAnimationBeStarted;
@end
