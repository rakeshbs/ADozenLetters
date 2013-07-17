//
//  TileControl.m
//  Dabble
//
//  Created by Rakesh on 29/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TileControl.h"
#import "NSArray+Additions.h"
#import "GLActivityIndicator.h"
#import "EasingFunctions.h"

#define verticalOffset 20
#define horizontalOffset 0

#define TOP_HIDDEN_POSITION 1000
#define BOTTOM_HIDDEN_POSITION -1000

#define SCORE_PER_WORD 10
#define SCORE_PER_DOUBLE 100
#define SCORE_PER_TRIPLET 500

#define ANIMATION_HIDE_CONTROL 1
#define ANIMATION_SHOW_CONTROL 2

#define tileTextureSizeWithBorder 62.0f

@implementation TileControlEventData

-(void)dealloc
{
    self.concatenatedString = nil;
    [super dealloc];
}
@end

@implementation TileControl

@synthesize usedWordsPerTurn,wordsPerMove,concatenatedWords;
@synthesize newWordsPerMove;

static Texture2D *tileTextureImage = nil;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        [self initialize];
    }
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    return self;
}


-(void)initialize
{
    colorRenderer = [rendererManager getRendererWithVertexShaderName:@"InstancedColorShader" andFragmentShaderName:@"ColorShader"];
    
    textureRenderer = [rendererManager getRendererWithVertexShaderName:@"InstancedTextureShader" andFragmentShaderName:@"TextureShader"];
    
    stringTextureRenderer = [rendererManager getRendererWithVertexShaderName:@"InstancedTextureShader" andFragmentShaderName:@"StringTextureShader"];
    
    [self createTileTexture];
    generatedWords = [[NSMutableArray alloc]init];
    newWordsPerMove = [[NSMutableArray alloc]init];
    usedWordsPerTurn = [[NSMutableArray alloc]init];
    wordsPerMove = [[NSMutableArray alloc]init];
    
    [self performSelector:@selector(loadDictionary) withObject:nil];
    [self setupColors];
    [self setupGraphics];
    [self enableNotification];
    
    _allowedWords = [[NSMutableArray alloc]init];
    [self calculateThirteenLayout];
    [self calculateTwelveLayout];
    
    [self createTiles];
    
}

-(BOOL)touchable
{
    return NO;
}



-(void)createTileTexture
{
    
    if (tileTextureImage == nil)
    {
        CGRect imageRrect = CGRectMake(0, 0, tileTextureSizeWithBorder, tileTextureSizeWithBorder);
        
        CGFloat diff = (tileTextureSizeWithBorder - tileSquareSize)/2;
        UIGraphicsBeginImageContext( imageRrect.size );
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor]CGColor]);
        CGContextFillRect(context, CGRectMake(diff, diff, tileSquareSize, tileSquareSize));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        tileTextureImage = [[Texture2D alloc]initWithImage:image];
    }
}



-(void)setupGraphics
{
    characterSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeAlphabetsUppercase withFont:@"Lato" andSize:42];
    [characterSpriteSheet.texture generateMipMap];
    
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    
    tileTextureImage = [textureManager getTexture:@"tile" OfType:@"png"];
    
    
    shadowTexCoordinates = [shadowTexture getTextureCoordinates];
    tileTexCoordinates = [tileTextureImage getTextureCoordinates];
    
    CGFloat t = 1.0f;
    
    
    tileVertices[0] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[1] = (Vector3D)  {.x = tileSquareSize/(2), .y = - tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[2] = (Vector3D)  {.x = tileSquareSize/(2), .y =  tileSquareSize/(2), .z = 0.0f, .t = t};
    
    tileVertices[3] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[4] = (Vector3D)  {.x = -tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[5] =  (Vector3D) {.x = tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f, .t = t};
    
    transparentVertices[0] =  (Vector3D) {.x = -tileTextureSizeWithBorder/(2), .y = -tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[1] = (Vector3D)  {.x = tileTextureSizeWithBorder/(2), .y = - tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[2] = (Vector3D)  {.x = tileTextureSizeWithBorder/(2), .y =  tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    
    transparentVertices[3] =  (Vector3D) {.x = -tileTextureSizeWithBorder/(2), .y = -tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[4] = (Vector3D)  {.x = -tileTextureSizeWithBorder/(2), .y = tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[5] =  (Vector3D) {.x = tileTextureSizeWithBorder/(2), .y = tileTextureSizeWithBorder/(2), .z = 0.0f, .t = t};
    
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

-(void)calculateThirteenLayout
{
    thirteenLayout = malloc(13 * sizeof(CGPoint));
    int rows[3]= {1,5,7};
    int index = 0;
    CGFloat yMargin = (frame.size.height - (tileSquareSize) * 3 - 2 * verticalOffset)/2;
    for (int i = 0;i<3;i++)
    {
        CGFloat xMargin = (frame.size.width - tileSquareSize * rows[i])/2;
        for (int j = 0;j<rows[i];j++)
        {
            thirteenLayout[index] = CGPointMake(xMargin + tileSquareSize/2 + tileSquareSize * j
                                                , frame.size.height - (yMargin + i * verticalOffset + i * tileSquareSize
                                                                       + tileSquareSize/2));
            index++;
        }
    }
}



-(void)calculateTwelveLayout
{
    twelveLayout = malloc(13 * sizeof(CGPoint));
    int rows[3]= {3,4,5};
    CGFloat yMargin = (frame.size.height - (tileSquareSize) * 3 - 2 * verticalOffset)/2;
    
    twelveLayout[0] = CGPointMake(thirteenLayout[0].x, 1000);
    int index = 1;
    for (int i = 0;i<3;i++)
    {
        CGFloat xMargin = (frame.size.width - tileSquareSize * rows[i])/2;
        for (int j = 0;j<rows[i];j++)
        {
            twelveLayout[index] = CGPointMake(xMargin + tileSquareSize/2 + tileSquareSize * j
                                              , frame.size.height - (yMargin + i * verticalOffset + i * tileSquareSize
                                                                     + tileSquareSize/2));
            index++;
        }
    }
    
    
}


-(void)createTiles
{
    NSString *dataStr = @"ADOZENLETTERS";
    
    if (tilesArray != nil)
    {
        free(tileColorData);
        //        free(tileTextureData);
        free(shadowTextureData);
        free(characterTextureData);
    }
    
    tileColorData = malloc(sizeof(InstancedVertexColorData)* 6 * 13 * 2);
    tileTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 13);
    shadowTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 13);
    characterTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 10 * 13);
    
    tilesArray = [[NSMutableArray alloc]init];
    
    for (int j = 0; j < dataStr.length; j++)
    {
        NSString *character = [dataStr substringWithRange:NSMakeRange(j, 1)];
        
        Tile *tile = [[Tile alloc]init];
        
        CGPoint anchorPoint = thirteenLayout[j];
        
        tile.centerPoint = CGPointMake(anchorPoint.x, 1000);
        tile.anchorPoint = anchorPoint;
        tile.tag = j;
        
        tile.colorIndex = j%2;
        tile.characterCounter.fontSpriteSheet = characterSpriteSheet;
        [tile setTileCharacter:character];
        [tilesArray addObject:tile];
        [self addElement:tile];
        tile.tilesArray = tilesArray;
        
        [tile setupColors];
        [tile release];
    }
    
}

-(void)showTiles
{
    CGFloat delay = 0.0;
    for (Tile *tile in [tilesArray reverseObjectEnumerator])
    {
        if (tile.tag == 0)
        {
            tile.centerPoint = CGPointMake(tile.centerPoint.x, 1000);
            [tile moveToPoint:tile.anchorPoint inDuration:0.3 afterDelay:2.5];
            continue;
        }
        [tile throwToPoint:tile.anchorPoint inDuration:0.3 afterDelay:delay];
        [tile moveToBack];
        delay += 0.1;
    }
}


-(void)rearrangeToTwelveLetters
{
    Tile *a = (Tile *)[self getElementByTag:0];
    
    Tile *d = (Tile *)[self getElementByTag:1];
    Tile *o = (Tile *)[self getElementByTag:2];
    Tile *z = (Tile *)[self getElementByTag:3];
    Tile *e = (Tile *)[self getElementByTag:4];
    Tile *n = (Tile *)[self getElementByTag:5];
    
    Tile *l = (Tile *)[self getElementByTag:6];
    Tile *t = (Tile *)[self getElementByTag:9];
    Tile *s = (Tile *)[self getElementByTag:12];
    
    
    t.anchorPoint = thirteenLayout[9];
    z.anchorPoint = twelveLayout[2];
    a.anchorPoint = twelveLayout[0];
    [t throwToPoint:z.anchorPoint inDuration:0.3 afterDelay:0];
    [z throwToPoint:z.anchorPoint inDuration:0.3 afterDelay:0.05];
    [a moveToPoint:a.anchorPoint inDuration:3 afterDelay:0.1];
    
    [t throwToPoint:t.anchorPoint inDuration:0.3 afterDelay:0.2];
    
    
    [l throwToPoint:d.anchorPoint inDuration:0.3 afterDelay:0.1];
    [l wiggleFor:10];
    [s throwToPoint:n.anchorPoint inDuration:0.3 afterDelay:0.1];
    
    d.anchorPoint = twelveLayout[1];
    n.anchorPoint = twelveLayout[3];
    [d throwToPoint:d.anchorPoint inDuration:0.3 afterDelay:0.2];
    [n throwToPoint:n.anchorPoint inDuration:0.3 afterDelay:0.2];
    
    l.anchorPoint = twelveLayout[4];
    s.anchorPoint = twelveLayout[7];
    o.anchorPoint = twelveLayout[5];
    e.anchorPoint = twelveLayout[6];
    [l throwToPoint:l.anchorPoint inDuration:0.3 afterDelay:0.3];
    [s throwToPoint:s.anchorPoint inDuration:0.3 afterDelay:0.3];
    [o throwToPoint:o.anchorPoint inDuration:0.3 afterDelay:0.3];
    [e throwToPoint:e.anchorPoint inDuration:0.3 afterDelay:0.3];
    
  //  for (Tile *t in tilesArray)
    //    [t showShadowFor:10 afterDelay:0];
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
    /*
     [newWordsPerMove removeAllObjects];
     [usedWordsPerTurn removeAllObjects];
     [wordsPerMove removeAllObjects];
     
     if (concatenatedWords != nil)
     [concatenatedWords release];
     concatenatedWords = [[NSMutableString alloc]init];
     
     memset(rearrangedCharacters, '\0', sizeof(char)*lengthOfCharRow*numberOfRows+1);
     memset(scorePerRow, 0, sizeof(int)*numberOfRows);
     scorePerMove = 0;
     
     for (Tile *tile in tilesArray)
     {
     int row = (tile.anchorPoint.y - yMargin)/(verticalOffset + tileSquareSize);
     int col = (tile.anchorPoint.x - xMargins[row] - tileSquareSize/2.0)/tileSquareSize;
     
     const char *characterAt = [tile.character cStringUsingEncoding:NSUTF8StringEncoding];
     
     if(tile.touchesInElement.count > 0)
     *(rearrangedCharacters + row * lengthOfCharRow + col) = '#';
     else
     {
     *(rearrangedCharacters + row * lengthOfCharRow + col) = *characterAt;
     scorePerRow[row] += tile.score;
     }
     
     }
     
     for (int i = numberOfRows;i>=0;i--)
     {
     NSString *string = [NSString stringWithUTF8String:(rearrangedCharacters + i * lengthOfCharRow)];
     int ind = -1;
     if (self.allowedWords == nil)
     {
     ind = [dictionary checkIfWordExists:string];
     }
     else
     {
     if ([self.allowedWords indexOfString:string]>=0)
     {
     ind = 0;
     }
     }
     
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
     scorePerMove += scorePerRow[i];
     [newWordsPerMove addObject:string];
     [generatedWords addObject:string];
     [wordsPerMove addObject:string];
     [concatenatedWords appendFormat:@"%@",string];
     }
     else if (ind == -2)
     {
     [usedWordsPerTurn addObject:string];
     [wordsPerMove addObject:string];
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
     {
     TileControlEventData *eventData = [[TileControlEventData alloc]init];
     eventData.concatenatedString = self.concatenatedWords;
     eventData.scorePerMove = scorePerMove;
     
     [target performSelector:selector withObject:eventData];
     [eventData release];
     }*/
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

//Animation Code

-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_SHOW_CONTROL)
    {
        
    }
    else if (animation.type == ANIMATION_HIDE_CONTROL)
    {
        
    }
    
    
    if (animationRatio>=1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    if (animation.type == ANIMATION_HIDE_CONTROL)
    {
        
    }
}
-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_SHOW_CONTROL)
    {
        
    }
    else if (animation.type == ANIMATION_HIDE_CONTROL)
    {
        if (target)
        {
            TileControlEventData *eventData = [[TileControlEventData alloc]init];
            eventData.concatenatedString = nil;
            eventData.scorePerMove = -1;
            
            [target performSelector:selector withObject:eventData];
            [eventData release];
        }
        
    }
}



-(void)draw
{
    characterDataCount = 0;
    shadowCount = 0;
    tileColorVerticesCount = 0;
    for (int i = 0;i<subElements.count;i++)
    {
        Tile *tile = subElements[i];
        [mvpMatrixManager pushModelViewMatrix];
        
        [mvpMatrixManager translateInX:tile.centerPoint.x Y:tile.centerPoint.y Z:tile.indexOfElement * 6 + 1];
        [mvpMatrixManager rotateByAngleInDegrees:tile.wiggleAngle InX:0 Y:0 Z:1];
        
        Matrix3D result;
        [mvpMatrixManager getMVPMatrix:result];
        
     /*
        for (int j = 0;j<6;j++)
        {
            memcpy(&((tileColorData  + tileColorVerticesCount)->mvpMatrix), result, sizeof(Matrix3D));
            (tileColorData + tileColorVerticesCount)->vertex = tileVertices[j];
            (tileColorData + tileColorVerticesCount)->color = *(tile.currentTileColor + tile.colorIndex);
            tileColorVerticesCount ++;
        }*/
        
        /*  for (int j = 0;j<6;j++)
         {
         memcpy(&((tileColorData + tileColorVerticesCount)->mvpMatrix), result, sizeof(Matrix3D));
         (tileColorData + tileColorVerticesCount)->vertex = transparentVertices[j];
         (tileColorData + tileColorVerticesCount)->color = (Color4B){.red = 0,.green = 0,
         .blue = 0,.alpha = 0};
         
         tileColorVerticesCount++;
         }*/
        
        
         for (int j = 0;j<6;j++)
         {
         memcpy(&((tileTextureData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
         (tileTextureData + i * 6 + j)->vertex = transparentVertices[j];
         (tileTextureData + i * 6 + j)->color = *(tile.currentTileColor + tile.colorIndex);
         (tileTextureData + i * 6 + j)->texCoord = tileTexCoordinates[j];
             tileColorVerticesCount++;
         }
        
        [mvpMatrixManager translateInX:0 Y:0 Z:1];
        
        tile.characterCounter.vertexData = (characterTextureData + characterDataCount);
        [tile.characterCounter draw];
        characterDataCount += tile.characterCounter.vertexDataCount;
        
        if (tile.shadowColor->alpha > 0)
        {
            [mvpMatrixManager translateInX:0 Y:0 Z:1];
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
    
    
    //[colorRenderer drawWithArray:tileColorData andCount:tileColorVerticesCount];
    stringTextureRenderer.texture = tileTextureImage;
    [stringTextureRenderer drawWithArray:tileTextureData andCount:tileColorVerticesCount];
    
    stringTextureRenderer.texture = characterSpriteSheet.texture;
    [stringTextureRenderer drawWithArray:characterTextureData andCount:characterDataCount];
    
    textureRenderer.texture = shadowTexture;
    [textureRenderer drawWithArray:shadowTextureData andCount:shadowCount * 6];
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}

-(void)dealloc
{
    free(tileColorData);
    free(shadowTextureData);
    free(characterTextureData);
    free(scoreTextureData);
    [super dealloc];
}



@end
