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


-(ShaderAttributeTypes)getAttributeType:(NSString *)vertexShaderName
{
    if ([vertexShaderName isEqualToString:@"ColorShader"])
    {
        return ShaderAttributeVertexColor;
    }
    else  if ([vertexShaderName isEqualToString:@"TextureShader"])
    {
        return ShaderAttributeVertexColorTexture;
    }
    else  if ([vertexShaderName isEqualToString:@"InstancedTextureShader"])
    {
        return ShaderAttributeMatrixVertexColorTexture;
    }
    else  if ([vertexShaderName isEqualToString:@"InstancedColorShader"])
    {
        return ShaderAttributeMatrixVertexColor;
    }
    
    return ShaderAttributeVertexColor;
}

-(void)addAttributesOfType:(ShaderAttributeTypes)attType toShader:(GLShaderProgram *)program
{
    if (attType == ShaderAttributeVertexColor)
    {
        [program addAttribute:@"vertex"];
        [program addAttribute:@"color"];
        
    }
    else if (attType == ShaderAttributeVertexColorTexture)
    {
        [program addAttribute:@"vertex"];
        [program addAttribute:@"textureColor"];
        [program addAttribute:@"textureCoordinate"];
    }
    else if (attType == ShaderAttributeMatrixVertexColor)
    {
        [program addAttribute:@"mvpmatrix"];
        [program addAttribute:@"vertex"];
        [program addAttribute:@"color"];
    }
    else if (attType == ShaderAttributeMatrixVertexColorTexture)
    {
        [program addAttribute:@"mvpmatrix"];
        [program addAttribute:@"vertex"];
        [program addAttribute:@"textureColor"];
        [program addAttribute:@"textureCoordinate"];
    }
}

-(GLShaderProgram *)getShaderByVertexShaderFileName:(NSString *)vertexShaderFilename andFragmentShaderFileName:(NSString *)fragmentShaderFilename
{
    NSString *key = [NSString stringWithFormat:@"%@&%@",vertexShaderFilename,fragmentShaderFilename];
    
    GLShaderProgram *shader;
    
    shader = shaders[key];
    
    ShaderAttributeTypes type = [self getAttributeType:vertexShaderFilename];
    
    if (shader == nil)
    {
        shader = [[GLShaderProgram alloc]initWithVertexShaderFilename:vertexShaderFilename
                                               fragmentShaderFilename:fragmentShaderFilename];
        shaders[key] = shader;
        [shader release];
    }
    
    [self addAttributesOfType:type toShader:shader];
    [shader link];
    
    return shader;
}

@end
