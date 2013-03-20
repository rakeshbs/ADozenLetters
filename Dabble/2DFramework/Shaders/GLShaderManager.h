//
//  GLShaderManager.h
//  OpenGLES2.0
//
//  Created by Rakesh on 10/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLShaderProgram.h"
@interface GLShaderManager : NSObject
{
    NSMutableDictionary *shaders;
}
+(id)sharedGLShaderManager;
-(GLShaderProgram *)getShaderByVertexShaderFileName:(NSString *)vertexShaderFilename andFragmentShaderFileName:(NSString *)fragmentShaderFilename;
@end
