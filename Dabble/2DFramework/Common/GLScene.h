//
//  CanvasClass.h
//  MusiMusi
//
//  Created by Rakesh on 17/08/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGLDrawable.h>
#import "GLElement.h"


@interface GLScene : GLElement {

}

-(void)sceneMadeActive;
-(void)sceneMadeInActive;
@end
