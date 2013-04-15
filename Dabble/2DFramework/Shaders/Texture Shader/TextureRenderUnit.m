//
//  TextureRenderUnit.m
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TextureRenderUnit.h"

#define NUMBEROFMATRICES 50
#define NUMBEROFVERTICES 500

@implementation TextureRenderUnit

-(id)init
{
    if (self = [super init])
    {
        _mvpMatrices = malloc(NUMBEROFMATRICES * sizeof(GLfloat)*16);
        _vertices = malloc(sizeof(Vector3D)*NUMBEROFVERTICES);
        _textureColors = malloc(sizeof(Color4B)*NUMBEROFVERTICES);
        _textureCoordinates = malloc(sizeof(TextureCoord)*NUMBEROFVERTICES);
        _matrixIndices = malloc(sizeof(GLubyte)*NUMBEROFVERTICES);

        matrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        _mvpMatrixCount = 0;
        _count = 0;
    }
    return self;
}

-(void)addMatrix
{
    Matrix3D mvpMatrix;
    [matrixManager getMVPMatrix:mvpMatrix];
    int ind = _mvpMatrixCount*16;
    Matrix3DCopyS(mvpMatrix, (_mvpMatrices+ind));
    _mvpMatrixCount++;
}

-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount
{
    for (int i = 0;i<ccount;i++)
    {
        *(_vertices+_count+i) = *(_cvertices+i);
        *(_textureColors + _count +i) = _ctextureColor;
        *(_matrixIndices+ _count +i) = _mvpMatrixCount-1;
        *(_textureCoordinates + _count + i) = *(_ctextureCoordinates+i);
    }
    _count+=ccount;
}


@end