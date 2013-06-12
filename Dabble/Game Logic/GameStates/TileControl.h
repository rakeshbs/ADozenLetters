//
//  TileControl.h
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "Tile.h"
#import "GLShaderManager.h"

@interface TileControl : GLElement
{
    NSMutableArray *tilesArray;
    
    NSString *charArray1[3];
    NSString *charArray2[4];
    NSString *charArray3[5];
    
    GLShaderProgram *colorShaderProgram;
    GLShaderProgram *textureShaderProgram;
    
    
    ColorVertexData *tileColorData;
    TextureVertexData *tileTextureVertexData[3];
    
}
@end
