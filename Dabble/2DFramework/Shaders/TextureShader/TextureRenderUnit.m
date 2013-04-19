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
        _vertices = malloc(sizeof(GLfloat)*3*NUMBEROFVERTICES);
        _textureColors = malloc(sizeof(GLubyte)*4*NUMBEROFVERTICES);
        _textureCoordinates = malloc(sizeof(GLfloat)*2*NUMBEROFVERTICES);
        _matrixIndices = malloc(sizeof(GLubyte)*NUMBEROFVERTICES);

        matrixManager = [MVPMatrixManager sharedMVPMatrixManager];
        _mvpMatrixCount = 0;
        _count = 0;
        _isFont = NO;
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
     //   NSLog(@"add vertices start %d",_count);
    for (int i = 0;i<ccount;i++)
    {
        *(_vertices+_count+i) = *(_cvertices+i);
        *(_textureColors + _count +i) = _ctextureColor;
        *(_matrixIndices+ _count +i) = _mvpMatrixCount-1;
        *(_textureCoordinates + _count + i) = *(_ctextureCoordinates+i);
    }
    _count+=ccount;
      //      NSLog(@"add vertices end %d",_count);
}

-(void)dealloc
{
    [super dealloc];
    NSLog(@"deallocating texture render unit");
    free(self.matrixIndices);
    free(self.mvpMatrices);
    free(self.textureCoordinates);
    free(self.textureColors);
    self.texture = nil;
    free(self.vertices);
}

@end
