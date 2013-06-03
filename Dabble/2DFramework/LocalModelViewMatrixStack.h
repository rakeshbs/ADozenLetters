//
//  LocalModelViewMatrixManager.h
//  Dabble
//
//  Created by Rakesh on 03/06/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"

@interface LocalModelViewMatrixStack : NSObject
{
    Matrix3D modelViewStack[10];
    
    int currentModelViewMatrixIndex;
}
-(void)pushModelViewMatrix;
-(void)popModelViewMatrix;
-(void)rotateByAngleInDegrees:(CGFloat)degrees InX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
-(void)scaleByXScale:(CGFloat)xScale YScale:(CGFloat)yScale ZScale:(CGFloat)zScale;
-(void)translateInX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
-(void)applyTransformationToVertex:(Vertex3D *)vector resultVector:(Vertex3D *)result;
@end
