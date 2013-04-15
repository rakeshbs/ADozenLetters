//
//  GLNode.h
//  GameDemo
//
//  Created by Trucid on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animator.h"
#import "TextureManager.h"
#import "MVPMatrixManager.h"
#import "ColorRenderer.h"
#import "TextureRenderer.h"

@class Scene;

@interface GLElement : NSObject
{
    Scene *scene;
    CGRect frame;
    Animator *animator;
    TextureManager *textureManager;
    NSMutableArray *touchesInElement;
    MVPMatrixManager *mvpMatrixManager;
    ColorRenderer *triangleColorRenderer;
    TextureRenderer *textureRenderer;
}
@property (nonatomic,retain) Scene *scene;
@property (nonatomic,retain) ColorRenderer *triangleColorRenderer;
@property (nonatomic,retain) TextureRenderer *textureRenderer;
 @property (nonatomic)   CGRect frame;
@property (nonatomic,retain) NSMutableArray *touchesInElement;
-(void)draw;
-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)moveToFront;
@end
