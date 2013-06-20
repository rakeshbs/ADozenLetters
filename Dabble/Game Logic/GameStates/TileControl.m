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
        colorShaderProgram = [shaderManager getShaderByVertexShaderFileName:@"InstancedColorShader" andFragmentShaderFileName:@"ColorShader"];
        
        textureShaderProgram = [shaderManager getShaderByVertexShaderFileName:@"InstancedTextureShader" andFragmentShaderFileName:@"TextureShader"];
        
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
        [self setupColors];
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
    
    tileColorData = malloc(sizeof(VertexColorData)* 6 * (dataStr.length-dataArray.count+1));

    
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
            
            [tilesArray addObject:tile];
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
    [colorShaderProgram use];
    
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, tilesArray.count * 6 * sizeof(VertexColorData), tileColorData, GL_STREAM_DRAW);
    
    
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 0, 4, GL_FLOAT, 0, SIZE_INSTANCED_VCDATA, (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 1, 4, GL_FLOAT, 0, SIZE_INSTANCED_VCDATA, (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 2, 4, GL_FLOAT, 0, SIZE_INSTANCED_VCDATA, (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 3, 4, GL_FLOAT, 0, SIZE_INSTANCED_VCDATA, (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_COLOR_VERTEX);
    glVertexAttribPointer(ATTRIB_COLOR_VERTEX, 3, GL_FLOAT, 0, SIZE_INSTANCED_VCDATA, (GLvoid*)SIZE_MATRIX);
    glEnableVertexAttribArray(ATTRIB_COLOR_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, SIZE_INSTANCED_VCDATA,(GLvoid*)(SIZE_MATRIX+SIZE_VERTEX));
    
    glDrawArrays(GL_TRIANGLES, 0, tilesArray.count * 6);
    
    
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
        
        //[mvpMatrixManager translateInX:0 Y:0 Z:1];
        
      //  [self copyMVPMatrixToDestination:&((characterTextureData + i)->mvpMatrix)];
        
      //  setVertices(&((characterTextureData + i)->vertex), tileVertices, 6, sizeof(InstancedTextureVertexColorData));
      //  setUniformColor(&((characterTextureData + i)->color), tile.currentTileColor, 6, sizeof(InstancedVertexColorData));
        
         [mvpMatrixManager popModelViewMatrix];
        
    }
    
    [self drawColor];
}


-(void)tileFinishedMoving:(NSNotification *)notification
{
    /*
    for (Tile *sq in tilesArray)
    {
        int arrIndex = (sq.anchorPoint.y-yOffset-50)/80;
        int charIndex = -1;
        
        if (arrIndex == 0)
            charIndex = (sq.anchorPoint.x-40)/tileSquareSize;
        if (arrIndex == 1)
            charIndex = (sq.anchorPoint.x-70)/tileSquareSize;
        if (arrIndex == 2)
            charIndex = (sq.anchorPoint.x-100)/tileSquareSize;
        
        NSRange range  = NSMakeRange(charIndex, 1);
        [resString[arrIndex] replaceCharactersInRange:range withString:sq.character];
        
    }
    
    for (Tile *sq in tilesArray)
    {
        if (sq.touchesInElement.count != 0)
        {
            int arrIndex = (sq.anchorPoint.y-yOffset-50)/80;
            if (arrIndex == 0)
                resString[arrIndex] = [[NSMutableString alloc]initWithString:@"#####"];
            if (arrIndex == 1)
                resString[arrIndex] = [[NSMutableString alloc]initWithString:@"####"];
            if (arrIndex == 2)
                resString[arrIndex] = [[NSMutableString alloc]initWithString:@"###"];
            
        }
    }
    
    BOOL shouldUpdateTexture = NO;
    
    memset(shouldHighlight, 0, sizeof(shouldHighlight));
    [onBoardWords removeAllObjects];
    
    for (int i = 0;i<3;i++)
    {
        int result = [dictionary checkIfWordExists:resString[i]];
        if (result >= 0)
        {
            [madeWords addObject:resString[i]];
            shouldHighlight[i] = 1;
            numberOfWordsMade++;
            numberOfWordsPerLetter[resString[i].length-3]++;
            shouldUpdateTexture = 1;
            [onBoardWords addObject:resString[i]];
        }
        else if (result == -2)
        {
            shouldHighlight[i] = 2;
            [onBoardWords addObject:resString[i]];
        }
    }
    if (onBoardWords.count == 3)
    {
        NSString *concat = [NSString stringWithFormat:@"%@%@%@",onBoardWords[0],onBoardWords[1],onBoardWords[2]];
        if ([madeTriples indexOfString:concat] < 0)
        {
            [madeTriples addObject:concat];
            numberOfTripletsMade++;
            shouldUpdateTexture = YES;
        }
    }
    else if (onBoardWords.count == 2)
    {
        NSString *concat = [NSString stringWithFormat:@"%@%@",onBoardWords[0],onBoardWords[1]];
        if ([madeDoubles indexOfString:concat] < 0)
        {
            [madeDoubles addObject:concat];
            numberOfDoublesMade++;
            shouldUpdateTexture = YES;
        }
    }
    
    for (int i = 0;i<3;i++)
    {
        if (shouldHighlight[i]==1)
        {
            CGFloat anchorY = i*80 + 50 + yOffset;
            for (Tile *sq in tilesArray)
            {
                if (sq.anchorPoint.y == anchorY)
                {
                    [sq wiggleFor:1.0];
                    [sq animateShowColorInDuration:0.2];
                }
            }
        }
        else if (shouldHighlight[i] == 2)
        {
            CGFloat anchorY = i*80 + 50 + yOffset;
            for (Tile *sq in tilesArray)
            {
                if (sq.anchorPoint.y == anchorY)
                {
                    [sq animateShowColorInDuration:0.2];
                }
            }
            
        }
    }
    
    if (shouldUpdateTexture)
    {
        [self updateAnalytics];
    }
     */
    
}



@end
