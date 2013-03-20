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

@class Scene;

@interface GLElement : NSObject
{
    Scene *scene;
    CGRect frame;
    Animator *animator;
    TextureManager *textureManager;
    NSMutableArray *touchesInElement;
    MVPMatrixManager *mvpMatrixManager;
    
}
@property (nonatomic,retain) Scene *scene;
 @property (nonatomic)   CGRect frame;
@property (nonatomic,retain) NSMutableArray *touchesInElement;
-(void)draw;
-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)moveToFront;
@end
