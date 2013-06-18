//
//  TileControl.m
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TileControl.h"

#define verticalOffset 10
#define horizontalOffset 10


static Color4B transparentColor = (Color4B) {.red = 255, .blue = 255, .green = 255, .alpha = 0};


@implementation TileControl

-(id)init
{
    if (self = [super init])
    {
        colorShaderProgram = [shaderManager initWithVertexShaderFilename:@"InstancedColorShader" fragmentShaderFilename:@"ColorShader"];
        
        textureShaderProgram = [shaderManager initWithVertexShaderFilename:@"InstancedTextureShader" fragmentShaderFilename:@"TextureShader"];
        
        glGenBuffers(1, &colorBuffer);
        glGenBuffers(1, &textureBuffer);
        
        ATTRIB_COLOR_MVPMATRIX = [colorShaderProgram attributeIndex:@"mvpmatrix"];
        ATTRIB_COLOR_VERTEX = [colorShaderProgram attributeIndex:@"vertex"];
        ATTRIB_COLOR_COLOR = [colorShaderProgram attributeIndex:@"color"];
        
        
        ATTRIB_TEXTURE_MVPMATRIX = [textureShaderProgram attributeIndex:@"mvpmatrix"];
        ATTRIB_TEXTURE_VERTEX = [textureShaderProgram attributeIndex:@"vertex"];
        ATTRIB_TEXTURE_COLOR = [textureShaderProgram attributeIndex:@"textureColor"];
        ATTRIB_TEXTURE_TEXCOORDS = [textureShaderProgram attributeIndex:@"textureCoordinate"];
        
        [self setupGraphics];
    }
    return self;
}

-(void)setupGraphics
{
    characterSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeAlphabetsUppercase withFont:@"Lato" andSize:40];
    
    scoreSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeAlphabetsUppercase withFont:@"Lato" andSize:12];
    
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];

    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    
    tileVertices[0] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f};
    tileVertices[1] = (Vector3D)  {.x = tileSquareSize/(2), .y = - tileSquareSize/(2), .z = 0.0f};
    tileVertices[2] = (Vector3D)  {.x = tileSquareSize/(2), .y =  tileSquareSize/(2), .z = 0.0f};
    
    tileVertices[3] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f};
    tileVertices[4] = (Vector3D)  {.x = -tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f};
    tileVertices[5] =  (Vector3D) {.x = tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f};
    
    shadowVertices[0] =  (Vector3D) {.x = -shadowSize/(2), .y = -shadowSize/(2), .z = 0.0f};
    shadowVertices[1] = (Vector3D)  {.x = shadowSize/(2), .y = - shadowSize/(2), .z = 0.0f};
    shadowVertices[2] = (Vector3D)  {.x = shadowSize/(2), .y =  shadowSize/(2), .z = 0.0f};
    
    shadowVertices[3] =  (Vector3D) {.x = -shadowSize/(2), .y = -shadowSize/(2), .z = 0.0f};
    shadowVertices[4] = (Vector3D)  {.x = -shadowSize/(2), .y = shadowSize/(2), .z = 0.0f};
    shadowVertices[5] =  (Vector3D) {.x = shadowSize/(2), .y = shadowSize/(2), .z = 0.0f};
    
}

-(void)setupColors
{
    tileColors[0][0] = (Color4B) { .red = 255, .blue = 255 , .green = 255, .alpha = 230};
    
    tileColors[0][1] = (Color4B) { .red = 255, .blue = 255 , .green = 255, .alpha = 200};
    
    tileColors[1][0] = (Color4B) { .red = 0, .green = 0 , .blue = 0, .alpha = 230};
    
    tileColors[1][1] = (Color4B) { .red = 0, .green = 0 , .blue = 0, .alpha = 200};
    
}

-(Color4B)getColorForState:(int)state andColorIndex:(int)index
{
    return tileColors[state][index];
}


-(void)createTiles:(NSString *)dataStr
{
     NSArray *dataArray= [dataStr componentsSeparatedByString:@","];
    
    if (tilesArray != nil)
    {
        [subElements removeObjectsInArray:tilesArray];
        [tilesArray release];
    }
    
    tileColorData = malloc(sizeof(VertexColorData)* 4 * (dataStr.length-dataArray.count+1));

    
    tilesArray = [[NSMutableArray alloc]init];
    

    
    for (int i = 0; i <dataArray.count;i++)
    {
        NSString *charArray = dataArray[i];
        
        for (int j = 0; j < charArray.length; j++)
        {
            NSString *character = [charArray substringWithRange:NSMakeRange(j, 1)];
            
            
            CGFloat marginX = (frame.size.width - horizontalOffset * (charArray.length -1))/2;
            CGFloat marginY = (frame.size.height - verticalOffset * (dataArray.count - 1))/2;
            
            Tile *tile = [[Tile alloc]initWithCharacter:character];
            tile.centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
            CGFloat anchorX = marginX + tileSquareSize/2.0 + horizontalOffset * j;
            CGFloat anchorY = marginY + tileSquareSize/2.0 + verticalOffset * i;
            tile.anchorPoint = CGPointMake(anchorX,anchorY);
            
            tile.colorIndex = j%2;
            
            [self addElement:tile];
            tile.tilesArray = tilesArray;
            [tile release];
        }
    }
     
    CGFloat delay = 0.0;
    
    for (Tile *sq in [tilesArray reverseObjectEnumerator])
    {
        [sq throwToPoint:sq.anchorPoint inDuration:0.7 afterDelay:delay];
        delay += 0.1;
    }
}

-(void)drawColor
{
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(VertexColorData), dataBuffer, GL_STREAM_DRAW);
    
    
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 0, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 1, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 2, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_MVPMATRICES + 3, 4, GL_FLOAT, 0, STRIDE, (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_COLOR_VERTEX);
    glVertexAttribPointer(ATTRIB_COLOR_VERTEX, 3, GL_FLOAT, 0, sizeof(InstancedVertexColorData), (GLvoid*)sizeof(Matrix3D));
    glEnableVertexAttribArray(ATTRIB_COLOR_VERTEX);
    glVertexAttribPointer(ATTRIB_COLORS, 4, GL_UNSIGNED_BYTE, GL_TRUE, STRIDE, (GLvoid*)(sizeof(Matrix3D)+sizeof(Vertex3D)));
    
}

-(void)draw
{
    for (int i = 0;i<tilesArray.count;i++)
    {
        Tile *tile = tilesArray[i];
        
        [mvpMatrixManager pushModelViewMatrix];
        [mvpMatrixManager translateInX:tile.centerPoint.x Y:tile.centerPoint.y Z:i * 6+1];
        [mvpMatrixManager rotateByAngleInDegrees:tile.wiggleAngle InX:0 Y:0 Z:1];
        
        [self copyMVPMatrixToDestination:&((tileColorData + i)->mvpMatrix)];
        
        setVertices(&((tileColorData + i)->vertex), tileVertices, 6, sizeof(InstancedVertexColorData));
        setUniformColor(&((tileColorData + i)->color), tile.currentTileColor, 6, sizeof(InstancedVertexColorData));
        
        [mvpMatrixManager translateInX:0 Y:0 Z:1];
        
        [self copyMVPMatrixToDestination:&((characterTextureData + i)->mvpMatrix)];
        
        setVertices(&((characterTextureData + i)->vertex), tileVertices, 6, sizeof(InstancedTextureVertexColorData));
        setUniformColor(&((characterTextureData + i)->color), tile.currentTileColor, 6, sizeof(InstancedVertexColorData));
        
    }
}


@end
