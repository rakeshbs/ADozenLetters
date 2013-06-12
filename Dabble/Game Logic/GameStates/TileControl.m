//
//  TileControl.m
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TileControl.h"

@implementation TileControl

-(id)init
{
    if (self = [super init])
    {
        colorShaderProgram = [shaderManager initWithVertexShaderFilename:@"ColorShader" fragmentShaderFilename:@"ColorShader"];
        
        textureShaderProgram = [shaderManager initWithVertexShaderFilename:@"TextureShader" fragmentShaderFilename:@"TextureShader"];
        
        
    }
    return self;
}


-(void)createTiles:(NSString *)dataStr
{
    
    tileColorData = malloc(sizeof(ColorVertexData)*4*dataStr.length);
    for (int i = 0;i < 3;i++)
    {
        tileTextureVertexData[i] = malloc(sizeof(TextureVertexData)* 4 * dataStr.length);
    }
     
    int ind = 0;
    
    for (int i = 0; i < 3; i++)
    {
        charArray1[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    for (int i = 0; i < 4; i++)
    {
        charArray2[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    for (int i = 0; i < 5; i++)
    {
        charArray3[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    
    Tile *tile;
    if (tilesArray != nil)
    {
        [subElements removeObjectsInArray:tilesArray];
        [tilesArray release];
    }
    
    tilesArray = [[NSMutableArray alloc]init];
    
    for (int i = 0;i<3;i++)
    {
        tile = [[Tile alloc]initWithCharacter:charArray1[i]];
        tile.centerPoint = CGPointMake(160, 160);
        tile.anchorPoint = CGPointMake(100+60*i, 210);
        tile.colorIndex = i%2;
        [self addElement:tile];
        [tilesArray addObject:tile];
        tile.tilesArray  = tilesArray;
        [tile release];
    }
    
    
    for (int i = 0;i<4;i++)
    {
        tile = [[Tile alloc]initWithCharacter:charArray2[i]];
        tile.centerPoint = CGPointMake(160, 160);
        tile.anchorPoint = CGPointMake(70+60*i, 130);
        tile.colorIndex = i%2;
        [self addElement:tile];
        [tilesArray addObject:tile];
        tile.tilesArray  = tilesArray;
        [tile release];
    }
    
    for (int i = 0;i<5;i++)
    {
        tile = [[Tile alloc]initWithCharacter:charArray3[i]];
        tile.centerPoint = CGPointMake(160, 160);
        tile.anchorPoint = CGPointMake(40+60*i, 50);
        tile.colorIndex = i%2;
        [self addElement:tile];
        [tilesArray addObject:tile];
        tile.tilesArray  = tilesArray;
        [tile release];
    }
    
    CGFloat delay = 0.0;
    
    for (Tile *sq in [tilesArray reverseObjectEnumerator])
    {
        [sq throwToPoint:sq.anchorPoint inDuration:0.7 afterDelay:delay];
        delay += 0.1;
    }
    
    
    
}


@end
