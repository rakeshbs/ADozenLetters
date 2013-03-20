//
//  GLShader.m
//  OpenGLES2.0
//
//  Created by Rakesh on 11/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLShader.h"

@implementation GLShader
-(id)init
{
    if (self = [super init])
    {
        matrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        shaderManager = [GLShaderManager sharedGLShaderManager];
    }
    return self;
}

-(void)draw{}
@end
