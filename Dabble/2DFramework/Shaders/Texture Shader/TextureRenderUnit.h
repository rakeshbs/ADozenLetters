//
//  TextureRenderUnit.h
//  Dabble
//
//  Created by Rakesh on 11/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCommon.h"
#import "TextureManager.h"
#import "FontSpriteSheetManager.h"
#import "MVPMatrixManager.h"

@interface TextureRenderUnit : NSObject
{
    MVPMatrixManager *matrixManager;
}
@property (nonatomic) Vector3D *vertices;
@property (nonatomic) TextureCoord *textureCoordinates;
@property (nonatomic,retain) Texture2D *texture;
@property (nonatomic) Color4B *textureColors;

@property (nonatomic) GLfloat *matrixIndices;
@property (nonatomic) int mvpMatrixCount;
@property (nonatomic) int count;

@property (nonatomic) GLfloat *mvpMatrices;

-(void)addVertices:(Vertex3D *)_cvertices andTextureCoords:(TextureCoord *)_ctextureCoordinates
          andColor:(Color4B)_ctextureColor andCount:(int)ccount;
-(void)addMatrix;

@end
