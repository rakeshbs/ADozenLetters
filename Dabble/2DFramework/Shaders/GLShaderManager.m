//
//  GLShaderManager.m
//
//
//  Created by Rakesh on 10/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLShaderManager.h"
#import "GLShaderProgram.h"
#import "SynthesizeSingleton.h"

@implementation GLShaderManager

SYNTHESIZE_SINGLETON_FOR_CLASS(GLShaderManager)

-(id)init
{
    if (self = [super init])
    {
        shaders = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(GLShaderProgram *)getShaderByVertexShaderFileName:(NSString *)vertexShaderFilename andFragmentShaderFileName:(NSString *)fragmentShaderFilename
{
    NSString *key = [NSString stringWithFormat:@"%@&%@",vertexShaderFilename,fragmentShaderFilename];
    
    GLShaderProgram *shader;
    
    shader = shaders[key];
    
    if (shader == nil)
    {
        shader = [[GLShaderProgram alloc]initWithVertexShaderFilename:vertexShaderFilename
                                        fragmentShaderFilename:fragmentShaderFilename];
        shaders[key] = shader;
        [shader release];
    }
    return shader;
}

@end
