//
//  TileControl.m
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TileControl.h"
#import "NSArray+Additions.h"

#define verticalOffset 20
#define horizontalOffset 0


@implementation TileControl

@synthesize usedWordsPerTurn,wordsPerTurn,concatenatedWords;
@synthesize newWordsPerTurn;
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
        
        
        generatedWords = [[NSMutableArray alloc]init];
        newWordsPerTurn = [[NSMutableArray alloc]init];
        usedWordsPerTurn = [[NSMutableArray alloc]init];
        wordsPerTurn = [[NSMutableArray alloc]init];
        
        [self performSelector:@selector(loadDictionary) withObject:nil];
        [self setupColors];
        [self setupGraphics];
        [self enableNotification];
    }
    return self;
}

-(BOOL)touchable
{
    return NO;
}

-(void)setupGraphics
{
    characterSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeAlphabetsUppercase withFont:@"Lato" andSize:40];
    
    scoreSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeNumbers
                                                               withFont:@"Lato" andSize:12];
    
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    tileTexture = [textureManager getTexture:@"tile" OfType:@"png"];
    
    shadowTexCoordinates = [shadowTexture getTextureCoordinates];
    tileTexCoordinates = [tileTexture getTextureCoordinates];
    

    
    CGFloat t = 1.0f;
    
    #define tileTextureSizeWithBorder 62.0f
    
    tileVertices[0] =  (Vector3D) {.x = -tileTextureSizeWithBorder/(2), .y = -tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    tileVertices[1] = (Vector3D)  {.x = tileTextureSizeWithBorder/(2), .y = - tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    tileVertices[2] = (Vector3D)  {.x = tileTextureSizeWithBorder/(2), .y =  tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    
    tileVertices[3] =  (Vector3D) {.x = -tileTextureSizeWithBorder/(2), .y = -tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    tileVertices[4] = (Vector3D)  {.x = -tileTextureSizeWithBorder/(2), .y = tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    tileVertices[5] =  (Vector3D) {.x = tileTextureSizeWithBorder/(2), .y = tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    
    shadowVertices[0] =  (Vector3D) {.x = -shadowSize/(2), .y = -shadowSize/(2), .z = 0.0f, .t = t};
    shadowVertices[1] = (Vector3D)  {.x = shadowSize/(2), .y = - shadowSize/(2), .z = 0.0f, .t = t};
    shadowVertices[2] = (Vector3D)  {.x = shadowSize/(2), .y =  shadowSize/(2), .z = 0.0f, .t = t};
    
    shadowVertices[3] =  (Vector3D) {.x = -shadowSize/(2), .y = -shadowSize/(2), .z = 0.0f, .t = t};
    shadowVertices[4] = (Vector3D)  {.x = -shadowSize/(2), .y = shadowSize/(2), .z = 0.0f, .t = t};
    shadowVertices[5] =  (Vector3D) {.x = shadowSize/(2), .y = shadowSize/(2), .z = 0.0f, .t = t};
    
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
        free(xMargins);
        free(tileColorData);
        free(shadowTextureData);
        free(characterTextureData);
        free(scoreTextureData);
        free(rearrangedCharacters);
    }
    
    tileColorData = malloc(sizeof(InstancedVertexColorData)* 6 * (dataStr.length-dataArray.count+1));
    tileTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * (dataStr.length-dataArray.count+1));
    shadowTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * (dataStr.length-dataArray.count+1));
    characterTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * (dataStr.length-dataArray.count+1));
    scoreTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * (dataStr.length-dataArray.count+1));
    [generatedWords removeAllObjects];
    
    tilesArray = [[NSMutableArray alloc]init];
    
    
    xMargins = malloc(sizeof(float)*dataArray.count);
    yMargin = (frame.size.height - (tileSquareSize) * (dataArray.count))/2;
    yMargin -= (verticalOffset * (dataArray.count - 1))/2;

    numberOfRows = dataArray.count;
    numberOfLettersPerRow = malloc(sizeof(int)*numberOfRows);
    lengthOfCharRow = (dataStr.length-dataArray.count+1);
    rearrangedCharacters = malloc(sizeof(char) * lengthOfCharRow * numberOfRows);
    
    for (int i = dataArray.count-1; i >=0;i--)
    {
        NSString *charArray = dataArray[i];
        numberOfLettersPerRow[i] = charArray.length;
        
        xMargins[i] = (frame.size.width - tileSquareSize * (charArray.length))/2;
        
        for (int j = 0; j < charArray.length; j++)
        {
            NSString *character = [charArray substringWithRange:NSMakeRange(j, 1)];
            
            Tile *tile = [[Tile alloc]initWithCharacter:character];
            tile.centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
            CGFloat anchorX = xMargins[i] + tileSquareSize * j + tileSquareSize/2.0;
            CGFloat anchorY = yMargin + tileSquareSize * i + verticalOffset * i;
            tile.anchorPoint = CGPointMake(anchorX,anchorY);
            tile.characterFontSprite = [characterSpriteSheet getFontSprite:character];
            tile.scoreTexture = [scoreSpriteSheet getFontSprite:[NSString stringWithFormat:@"%d",tile.score]];
           // NSLog(@"%@",[NSString stringWithFormat:@"%d",tile.score]);
            tile.colorIndex = j%2;
            
            [tilesArray addObject:tile];
            [self addElement:tile];
            tile.tilesArray = tilesArray;
            
            [tile setupColors];
            [tile release];
        }
    }
    
    CGFloat delay = 0.0;
    
    for (Tile *tile in [tilesArray reverseObjectEnumerator])
    {
        [tile throwToPoint:tile.anchorPoint inDuration:0.7 afterDelay:delay];
        [tile moveToBack];
        delay += 0.1;
    }
}



-(void)enableNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileFinishedMoving:) name:@"TileFinishedMoving" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileBreakBond:)
                                                name:@"TileBreakBond" object:nil];
}

-(void)loadDictionary
{
    dictionary = [Dictionary getSharedDictionary];
}


-(void)tileFinishedMoving:(NSNotification *)notification
{
    [newWordsPerTurn removeAllObjects];
    [usedWordsPerTurn removeAllObjects];
    [wordsPerTurn removeAllObjects];
    
    if (concatenatedWords != nil)
        [concatenatedWords release];
    concatenatedWords = [[NSMutableString alloc]init];
    
    memset(rearrangedCharacters, '\0', sizeof(char)*lengthOfCharRow*numberOfRows);
    
    for (Tile *tile in tilesArray)
    {
        int row = (tile.anchorPoint.y - yMargin)/(verticalOffset + tileSquareSize);
        int col = (tile.anchorPoint.x - xMargins[row] - tileSquareSize/2.0)/tileSquareSize;
        
        const char *characterAt = [tile.character cStringUsingEncoding:NSUTF8StringEncoding];
        
        if(tile.touchesInElement.count > 0)
            *(rearrangedCharacters + row * lengthOfCharRow + col) = '#';
        else
            *(rearrangedCharacters + row * lengthOfCharRow + col) = *characterAt;
        
    }
    
    for (int i = numberOfRows;i>=0;i--)
    {
        NSString *string = [NSString stringWithUTF8String:(rearrangedCharacters + i * lengthOfCharRow)];
        int ind = [dictionary checkIfWordExists:string];
        
        if (ind >= 0)
        {
            for (Tile *tile in tilesArray)
            {
                int row = (tile.anchorPoint.y - yMargin)/(verticalOffset + tileSquareSize);
                if (row == i)
                {
                    [tile wiggleFor:1.0];
                    [tile animateShowColorInDuration:0.2];
                }
            }
            [newWordsPerTurn addObject:string];
            [generatedWords addObject:string];
            [wordsPerTurn addObject:string];
            [concatenatedWords appendFormat:@"%@",string];
        }
        else if (ind == -2)
        {
            [usedWordsPerTurn addObject:string];
            [wordsPerTurn addObject:string];
            [concatenatedWords appendFormat:@"%@",string];
            for (Tile *tile in tilesArray)
            {
                int row = (tile.anchorPoint.y - yMargin)/(verticalOffset + tileSquareSize);
                if (row == i)
                    [tile animateShowColorInDuration:0.2];
            }
        }
    }
    
    if (target)
        [target performSelector:selector];
    
}

-(void)tileBreakBond:(NSNotification *)notification
{
    Tile *tile = notification.object;
    CGFloat anchorY = tile.anchorPoint.y;
    for (Tile *t in tilesArray)
    {
        if (t.anchorPoint.y == anchorY)
        {
            [t animateHideColorInDuration:0.2];
        }
    }
}

-(void)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	
}
-(void)touchMovedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
	
}
-(void)touchEndedInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
}

-(void)addTarget:(NSObject *)_target andSelector:(SEL)_selector
{
    target = _target;
    selector = _selector;
}



//Drawing Code


-(void)drawColor
{
    [colorShaderProgram use];
    
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, tilesArray.count * 6 * sizeof(InstancedVertexColorData), tileColorData, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_COLOR_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_COLOR_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_COLOR_VERTEX);
    glVertexAttribPointer(ATTRIB_COLOR_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    glEnableVertexAttribArray(ATTRIB_COLOR_COLOR);
    glVertexAttribPointer(ATTRIB_COLOR_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D));
    
    glDrawArrays(GL_TRIANGLES, 0, tilesArray.count * 6);
    
    
}

-(void)drawTexture:(int)count
{
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 0);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 1);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 2);
    glEnableVertexAttribArray(ATTRIB_TEXTURE_MVPMATRIX + 3);
    
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 0, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)0);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 1, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)16);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 2, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)32);
    glVertexAttribPointer(ATTRIB_TEXTURE_MVPMATRIX + 3, 4, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData), (GLvoid*)48);
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_TEXCOORDS);
    glVertexAttribPointer(ATTRIB_TEXTURE_TEXCOORDS, 2, GL_FLOAT, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D));
    
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTURE_VERTEX, 3, GL_FLOAT, 0,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(TextureCoord));
    
    glEnableVertexAttribArray(ATTRIB_TEXTURE_COLOR);
    glVertexAttribPointer(ATTRIB_TEXTURE_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE,  sizeof(InstancedTextureVertexColorData),
                          (GLvoid*)sizeof(Matrix3D)+sizeof(Vertex3D)+sizeof(TextureCoord));
    
    
    glDrawArrays(GL_TRIANGLES, 0, count * 6);
    
}

-(void)draw
{
    shadowCount = 0;
    for (int i = 0;i<subElements.count;i++)
    {
        Tile *tile = subElements[i];
        [mvpMatrixManager pushModelViewMatrix];
        [mvpMatrixManager translateInX:tile.centerPoint.x Y:tile.centerPoint.y Z:tile.indexOfElement *
         6 + 1];
        [mvpMatrixManager rotateByAngleInDegrees:tile.wiggleAngle InX:0 Y:0 Z:1];
        
        
        Matrix3D result;
        [mvpMatrixManager getMVPMatrix:result];
        
      /*  for (int j = 0;j<6;j++)
        {
            memcpy(&((tileColorData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
            (tileColorData + i * 6 + j)->vertex = tileVertices[j];
            (tileColorData + i * 6 + j)->color = *(tile.currentTileColor + tile.colorIndex);
            
        }*/
        
        
        for (int j = 0;j<6;j++)
        {
            memcpy(&((tileTextureData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
            (tileTextureData + i * 6 + j)->vertex = tileVertices[j];
            (tileTextureData + i * 6 + j)->color = *(tile.currentTileColor + tile.colorIndex);
            (tileTextureData + i * 6 + j)->texCoord = tileTexCoordinates[j];
        }
        
        [mvpMatrixManager translateInX:0 Y:0 Z:1];
        [mvpMatrixManager getMVPMatrix:result];
        for (int j = 0;j<6;j++)
        {
            memcpy(&((characterTextureData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
            (characterTextureData + i * 6 + j)->vertex = tile.characterFontSprite.textureRect[j];
            (characterTextureData + i * 6 + j)->color = *tile.currentCharacterColor;
            (characterTextureData + i * 6 + j)->texCoord =  tile.characterFontSprite.textureCoordinates[j];
        }
        
        [mvpMatrixManager translateInX:21 Y:-15 Z:1];
        [mvpMatrixManager getMVPMatrix:result];
        for (int j = 0;j<6;j++)
        {
            memcpy(&((scoreTextureData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
            (scoreTextureData + i * 6 + j)->vertex = tile.scoreTexture.textureRect[j];
            (scoreTextureData + i * 6 + j)->color = *tile.currentCharacterColor;
            (scoreTextureData + i * 6 + j)->texCoord =  tile.scoreTexture.textureCoordinates[j];
        }
        
        if (tile.shadowColor->alpha > 0)
        {
            [mvpMatrixManager translateInX:-21 Y:15 Z:1];
            [mvpMatrixManager getMVPMatrix:result];
            
            for (int j = 0;j<6;j++)
            {
                memcpy(&((shadowTextureData + shadowCount * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
                (shadowTextureData + shadowCount * 6 + j)->vertex = shadowVertices[j];
                (shadowTextureData + shadowCount * 6 + j)->color = *tile.shadowColor;
                (shadowTextureData + shadowCount * 6 + j)->texCoord = shadowTexCoordinates[j];
            }
            shadowCount++;
        }
        [mvpMatrixManager popModelViewMatrix];
        
    }
    
 //   [self drawColor];
    
    [textureShaderProgram use];
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    glBindBuffer(GL_ARRAY_BUFFER, textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, tilesArray.count * 6 * sizeof(InstancedTextureVertexColorData), tileTextureData, GL_DYNAMIC_DRAW);
    [tileTexture bindTexture];
    [self drawTexture:tilesArray.count];
    
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);    
    glBindBuffer(GL_ARRAY_BUFFER, textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, tilesArray.count * 6 * sizeof(InstancedTextureVertexColorData), characterTextureData, GL_DYNAMIC_DRAW);
    [characterSpriteSheet.texture bindTexture];
    [self drawTexture:tilesArray.count];
    
    glBindBuffer(GL_ARRAY_BUFFER, textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, tilesArray.count * 6 * sizeof(InstancedTextureVertexColorData), scoreTextureData, GL_DYNAMIC_DRAW);
    [scoreSpriteSheet.texture bindTexture];
    [self drawTexture:tilesArray.count];
 

    [shadowTexture bindTexture];
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    glBufferData(GL_ARRAY_BUFFER, shadowCount * 6 * sizeof(InstancedTextureVertexColorData), shadowTextureData, GL_DYNAMIC_DRAW);

    [self drawTexture:shadowCount];
    
}

-(void)dealloc
{
    [super dealloc];
    
    free(xMargins);
    free(tileColorData);
    free(shadowTextureData);
    free(characterTextureData);
    free(scoreTextureData);
}



@end
