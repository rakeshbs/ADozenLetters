//
//  Animator.m
//  Tiles
//
//  Created by Rakesh on 07/02/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Animator.h"

@implementation Animator

@synthesize currentAnimations,queuedAnimations;

+(Animator *)getSharedAnimator
{
    static Animator *animator;
    
    @synchronized(self)
    {
        if (animator == nil)
        {
            animator = [[Animator alloc]init];
        }
    }
    return animator;
}

-(void)update
{
    for (int i =0;i<queuedAnimations.count;i++)
    {
        Animation *animation = queuedAnimations[i];
        if ([animation canAnimationBeStarted])
        {
            [currentAnimations addObject:animation];
            [queuedAnimations removeObject:animation];
            
            animation.startTime = CFAbsoluteTimeGetCurrent();
            if ([animation.animatedObject respondsToSelector:@selector(animationStarted:)])
                [animation.animatedObject animationStarted:animation];

            i--;
        }
    }
    
    for (int i =0;i<currentAnimations.count;i++)
    {
        Animation *animation = currentAnimations[i];
        if ([animation.animatedObject update:animation])
        {
            [animation retain];
            [currentAnimations removeObject:animation];
            if ([animation.animatedObject respondsToSelector:@selector(animationEnded:)])
                [animation.animatedObject animationEnded:animation];
            [animation release];
            
            i--;
        }
    }
}

-(int)removeRunningAnimationsForObject:(NSObject<AnimationDelegate> *)obj
{
    int count = 0;
    for (int i =0;i<currentAnimations.count;i++)
    {
        Animation *animation = currentAnimations[i];
        if (animation.animatedObject == obj)
        {
            count++;
            [currentAnimations removeObject:animation];
            i--;
        }
        
    }
   
    return count;
}

-(int)removeQueuedAnimationsForObject:(NSObject<AnimationDelegate> *)obj
{
    int count = 0;
    for (int i =0;i<queuedAnimations.count;i++)
    {
        Animation *animation = queuedAnimations[i];
        if (animation.animatedObject == obj)
        {
             count++;
            [queuedAnimations removeObject:animation];
            i--;
        }
    }
    return count;
}

-(int)removeRunningAnimationsForObject:(NSObject<AnimationDelegate> *)obj ofType:(int)type
{
    int count = 0;
    for (int i =0;i<currentAnimations.count;i++)
    {
        Animation *animation = currentAnimations[i];
        if (animation.animatedObject == obj && animation.type == type)
        {
            count++;
            [currentAnimations removeObject:animation];
            i--;
        }
        
    }
    
    return count;
}
-(int)removeQueuedAnimationsForObject:(NSObject<AnimationDelegate> *)obj  ofType:(int)type
{
    int count = 0;
    for (int i =0;i<queuedAnimations.count;i++)
    {
        Animation *animation = queuedAnimations[i];
        if (animation.animatedObject == obj && animation.type == type)
        {
            count++;
            [queuedAnimations removeObject:animation];
            i--;
        }
    }
    return count;
}

-(int)getCountOfRunningAnimationsForObject:(NSObject<AnimationDelegate> *) obj ofType:(int)type
{
    int count = 0;
    for (int i =0;i<currentAnimations.count;i++)
    {
        Animation *animation = currentAnimations[i];
        if (animation.animatedObject == obj && animation.type == type)
        {
            count++;
         }
    }
    return count;
}

-(int)getCountOfQueuedAnimationsForObject:(NSObject<AnimationDelegate> *) obj ofType:(int)type
{
    int count = 0;
    for (int i =0;i<queuedAnimations.count;i++)
    {
        Animation *animation = queuedAnimations[i];
        if (animation.animatedObject == obj && animation.type == type)
        {
            count++;
        }
    }
    return count;
}

-(void)addAnimationFor:(NSObject<AnimationDelegate> *)obj ofType:(int)type ofDuration:(CGFloat)duration afterDelayInSeconds:(CGFloat)delay
{
    if (currentAnimations == nil)
    {
        currentAnimations = [[NSMutableArray alloc]init];
        queuedAnimations = [[NSMutableArray alloc]init];
    }
    
    Animation *animation = nil;
    BOOL chk = NO;
    
    for (Animation *anim in currentAnimations)
    {
        if (anim.animatedObject == obj && anim.type == type)
        {
            chk = YES;
            animation = anim;
            anim.startTime = CFAbsoluteTimeGetCurrent();
        }
    }
    
    for (Animation *anim in queuedAnimations)
    {
        if (anim.animatedObject == obj && anim.type == type)
        {
            chk = YES;
            animation = anim;
        }
    }
    
    if (animation == nil)
        animation = [[Animation alloc]init];
    animation.animatedObject = obj;
    animation.type = type;
    animation.duration = duration;
    animation.queuedTime = CFAbsoluteTimeGetCurrent();
    animation.startDelay = delay;
    if (!chk)
    {
        [queuedAnimations addObject:animation];
        [animation release];
    }
}

@end
