//
//  GLActivityIndicator.h
//  Dabble
//
//  Created by Rakesh on 02/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLElement.h"

@interface GLActivityIndicator : GLElement <AnimationDelegate>
{
    GLShaderProgram *pointSpritesShader;
    
    GLuint UNIFORM_MVPMATRIX;
    GLuint ATTRIB_VERTEX;
    GLuint ATTRIB_COLOR;
    GLuint ATTRIB_POINTSIZE;
    
    
    NSMutableArray *activityPoints;
    PointVertexColorSize *pointsData;
    
    GLuint pointsVertexBuffer;
    
    float relativePosition;
    
    int cycleCount;
    BOOL cycleModeOpen;

}

-(void)show;
-(void)hide;

@end
