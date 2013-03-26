//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpriteSheet.h"
#import "TextureManager.h"

@interface SpriteSheet (Private)
-(void)setTextureCoordinates;
@end


@implementation SpriteSheet
@synthesize number_of_frames,frameheight,framewidth,frame;

-(id)initWithImageNamed:(NSString *)str
				 frames:(int)_number_of_frames
			 frameWidth:(CGFloat)_framewidth
			frameHeight:(CGFloat)_frameheight 
		 offsetDistance:(CGFloat)_offset
{
	if (self = [super init])
	{
		TextureManager *manager = [TextureManager getSharedTextureManager];
		sprite_sheet = [manager getTexture:str OfType:@"png"];
		framewidth = _framewidth;
		frameheight = _frameheight;
		number_of_frames = _number_of_frames ;
		totalwidth = number_of_frames * framewidth;
		heightratio = 1.0;
		widthratio = framewidth/totalwidth;
		offset = _offset * widthratio;
		frame = -1;
	}
	return self;
}

-(void)setTextureCoordinates
{
	texCoordinates[0].s = frame*widthratio - (frame)*offset;
	texCoordinates[0].t = heightratio;
	texCoordinates[1].s = (frame+1)*widthratio - (frame+1)*offset;
	texCoordinates[1].t = heightratio ;
	texCoordinates[2].s = frame*widthratio- (frame)*offset;
	texCoordinates[2].t = 0;
	texCoordinates[3].s = (frame+1)*widthratio - (frame+1)*offset;
	texCoordinates[3].t = 0;
}

-(void)drawFrame:(int)_frame atPoint:(CGPoint)point
{
	[sprite_sheet bindTexture];
	if (frame != _frame)
	{
		frame = _frame;
		frame %=number_of_frames;
	}
}

@end
