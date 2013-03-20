//
//  SpriteSheet.h
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "GLCommon.h"

@interface SpriteSheet : NSObject {
	int frame;
	int number_of_frames;
	CGFloat frameheight;
	CGFloat framewidth;
	CGFloat totalheight;
	CGFloat totalwidth;
	CGFloat heightratio;
	CGFloat widthratio;
	CGFloat offset;
	Texture2D *sprite_sheet;
	TextureCoord texCoordinates[4];
	
}

@property (nonatomic) int number_of_frames;
@property (nonatomic) int frame;
@property (nonatomic) CGFloat frameheight;
@property (nonatomic) CGFloat framewidth;

-(id)initWithImageNamed:(NSString *)str
				 frames:(int)_number_of_frames
			 frameWidth:(CGFloat)_framewidth
			frameHeight:(CGFloat)_frameheight 
		 offsetDistance:(CGFloat)_offset;

-(void)drawFrame:(int)frame atPoint:(CGPoint)point;
@end
