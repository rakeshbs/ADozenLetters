//
//  GLButton.h
//  MusiMusi
//
//  Created by Rakesh BS on 9/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "GLElement.h"

#define buttonType_singleClick 1
#define buttonType_doubleClick 2
#define buttonType_doubleState 3


@interface GLButton : GLElement {
	Texture2D *texture_btn;
	Texture2D *texture_high;
	int type;
	BOOL highlighted;
	CGPoint drawPoint;
	int tag;
	SEL selector_single_click;
	SEL selector_double_click;
	NSObject *target;
}

@property (nonatomic) int type;
@property (nonatomic) int tag;
@property (nonatomic) CGPoint drawPoint;
@property (nonatomic) BOOL highlighted;
@property (nonatomic,assign) Texture2D* texture_btn;
@property (nonatomic,assign) Texture2D* texture_high;


-(void)addTarget:(NSObject *)_target andSelectorSingleClick:(SEL)_selector;
-(void)addSelectorDoubleClick:(SEL)_selector;
-(id)initWithImage:(NSString *)img1 andHighlitedImage:(NSString *)img2;
-(void)draw;
-(BOOL)check_pressed:(CGPoint)p;
-(void)performSingleClick;
-(void)performDoubleClick;

@end
