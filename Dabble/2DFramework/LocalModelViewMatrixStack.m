//
//  LocalModelViewMatrixManager.m
//  Dabble
//
//  Created by Rakesh on 03/06/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "LocalModelViewMatrixStack.h"

@implementation LocalModelViewMatrixStack

-(id)init
{
    if (self = [super init])
    {
        currentModelViewMatrixIndex = 0;
        Matrix3DSetIdentity(modelViewStack[currentModelViewMatrixIndex]);
    }
    return  self;
}

-(void)pushModelViewMatrix
{
    currentModelViewMatrixIndex++;
    if (currentModelViewMatrixIndex>=10)
    {
        NSLog(@"Model View Matrix Stack Full");
        return;
    }
    
    for (int j = 0;j<16;j++)
    {
        modelViewStack[currentModelViewMatrixIndex][j]=modelViewStack[currentModelViewMatrixIndex-1][j];
    }
    
}

-(void)popModelViewMatrix
{
    currentModelViewMatrixIndex--;
}


-(void)rotateByAngleInDegrees:(CGFloat)degrees InX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    Vector3D vector;
    vector.x = x;
    vector.y = y;
    vector.z = z;
    Matrix3D rotationMatrix;
    Matrix3D resultMatrix;
    
    Matrix3DSetRotationByDegrees(rotationMatrix, degrees, vector);
    Matrix3DMultiply(rotationMatrix, modelViewStack[currentModelViewMatrixIndex], resultMatrix);
    Matrix3DCopyS(resultMatrix, modelViewStack[currentModelViewMatrixIndex]);
}

-(void)translateInX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
    Matrix3D translationMatrix;
    Matrix3D resultMatrix;
    
    Matrix3DSetTranslation(translationMatrix,x,y,z);
    Matrix3DMultiply(translationMatrix, modelViewStack[currentModelViewMatrixIndex], resultMatrix);
    Matrix3DCopyS(resultMatrix, modelViewStack[currentModelViewMatrixIndex]);
    
}

-(void)scaleByXScale:(CGFloat)xScale YScale:(CGFloat)yScale ZScale:(CGFloat)zScale
{
    Matrix3D scaleMatrix;
    Matrix3D resultMatrix;
    
    Matrix3DSetScaling(scaleMatrix,xScale,yScale,zScale);
    Matrix3DMultiply(scaleMatrix,  modelViewStack[currentModelViewMatrixIndex], resultMatrix);
    Matrix3DCopyS(resultMatrix,  modelViewStack[currentModelViewMatrixIndex]);
}

-(void)applyTransformationToVertex:(Vertex3D *)vector resultVector:(Vertex3D *)result
{
    MatrixVectorMultiply(modelViewStack[currentModelViewMatrixIndex], vector, result);
}


@end
