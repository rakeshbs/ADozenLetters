//
//  GLShader.h
//  OpenGLES2.0
//
//  Created by Rakesh on 11/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVPMatrixManager.h"
#import "GLShaderManager.h"

@interface GLRenderer : NSObject
{
    MVPMatrixManager *matrixManager;
    GLShaderManager *shaderManager;

}
-(void)draw;
@end
