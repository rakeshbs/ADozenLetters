//
//  Animator.h
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animation.h"

@interface Animator : NSObject
{
    NSMutableArray *currentAnimations;
    NSMutableArray *queuedAnimations;
}
@property (nonatomic,retain) NSMutableArray *currentAnimations;
@property (nonatomic,retain) NSMutableArray *queuedAnimations;

+(Animator *)getSharedAnimator;
-(void)update;
-(Animation *)addAnimationFor:(NSObject<AnimationDelegate> *)obj ofType:(int)type ofDuration:(CGFloat)duration afterDelayInSeconds:(CGFloat)delay;
-(int)removeRunningAnimationsForObject:(NSObject<AnimationDelegate> *)obj;
-(int)removeQueuedAnimationsForObject:(NSObject<AnimationDelegate> *)obj;
-(int)removeRunningAnimationsForObject:(NSObject<AnimationDelegate> *)obj ofType:(int)type;
-(int)removeQueuedAnimationsForObject:(NSObject<AnimationDelegate> *)obj  ofType:(int)type;
-(int)getCountOfQueuedAnimationsForObject:(NSObject<AnimationDelegate> *) obj ofType:(int)type;
-(int)getCountOfRunningAnimationsForObject:(NSObject<AnimationDelegate> *) obj ofType:(int)type;
-(NSMutableArray *)getRunningAnimationsForObject:(NSObject<AnimationDelegate> *) obj ofType:(int)type;
@end
