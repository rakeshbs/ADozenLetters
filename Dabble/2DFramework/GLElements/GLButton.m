//
//  GLButton.m
//  MusiMusi
//
//  Created by Rakesh BS on 9/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLButton.h"
#import "TextureManager.h"

@implementation GLButton
@synthesize highlighted,tag,type,drawPoint,texture_btn,texture_high;

-(id)initWithImage:(NSString *)img1 andHighlitedImage:(NSString *)img2
{
	if (self = [super init])
	{
		TextureManager *manager = [TextureManager getSharedTextureManager];
		texture_btn = [manager getTexture:img1 OfType:@"png"];
		texture_high = [manager getTexture:img2  OfType:@"png"];
		type = buttonType_doubleClick;
	}
	return self;
}

-(void)addTarget:(NSObject *)_target andSelectorSingleClick:(SEL)_selector
{
	target = _target;
	selector_single_click = _selector;
}
-(void)addSelectorDoubleClick:(SEL)_selector
{
	selector_double_click = _selector;
}

-(void)draw
{

}

-(void)performSingleClick
{
	[target performSelector:selector_single_click withObject:self];
}

-(void)performDoubleClick
{
	[target performSelector:selector_double_click withObject:self];
}

-(BOOL)check_pressed:(CGPoint)p
{
	BOOL ch = CGRectContainsPoint(frame, p);
	if (ch)
	{
		switch (type) {
			case buttonType_singleClick:
				[target performSelector:selector_single_click withObject:self];
				highlighted = YES;
				break;
			default:
				if (self.highlighted)
					[target performSelector:selector_double_click withObject:self];
				else
					[target performSelector:selector_single_click withObject:self];
				if (type == buttonType_doubleState)
				{
					highlighted = !highlighted;
				}
				else
				{
					highlighted = YES;
				}
				break;
		}
		
	}
	return ch;
}

-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	return YES;
}
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	return YES;
}
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	return YES;
}

@end
