//
//  AnimatedSprite.h
//  GameDemo
//
//  Created by Trucid on 10/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteSheet.h"

@interface AnimatedSprite : NSObject {
	SpriteSheet *sprite_sheet;
	int frame;
	CGFloat delay;
	CFTimeInterval refreshTimeInterval;
	CFTimeInterval currentTime;
	NSObject *target;
	SEL animation_end_selector;
	CGPoint location;
	void *data;
	
}

@property (nonatomic) CGFloat delay;
@property (nonatomic) int frame;
@property (nonatomic) void *data;
@property (nonatomic) CGPoint location;

-(id)initWithSpriteSheet:(SpriteSheet *)s andDelay:(CGFloat)delay;
-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector;
-(void)drawAtPoint:(CGPoint)point;
-(void)draw;

@end
