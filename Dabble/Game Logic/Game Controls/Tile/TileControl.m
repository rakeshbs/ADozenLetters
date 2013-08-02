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

#define verticalOffset 25
#define horizontalOffset 0


#define SCORE_PER_WORD 10
#define SCORE_PER_DOUBLE 100
#define SCORE_PER_TRIPLET 500

#define tileTextureSizeWithBorder 62.0f

@implementation TileControlEventData

-(void)dealloc
{
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
    
    //generatedWords = [[NSMutableArray alloc]init];
   // newWordsPerMove = [[NSMutableArray alloc]init];
  //  usedWordsPerTurn = [[NSMutableArray alloc]init];
//    wordsPerMove = [[NSMutableArray alloc]init];
    
    
    [self performSelector:@selector(loadDictionary) withObject:nil];
    [self setupColors];
    [self setupGraphics];
    [self enableNotification];
    [self setupSounds];
    
    _allowedWords = [[NSMutableArray alloc]init];
    [self calculateThirteenLayout];
    [self calculateTwelveLayout];
    [self createTiles];
    
    
}

-(BOOL)touchable
{
    return NO;
}

-(int)numberOfLayers
{
    return 100;
}



-(void)setupGraphics
{
    tileSpriteSheet = [[TileSpriteSheet alloc]initWithFont:@"Lato-Bold" andSize:42];
    //[tileSpriteSheet generateMipMap];
    [tileSpriteSheet bindTexture];
    glGenerateMipmapOES(GL_TEXTURE_2D);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    
    tileSprite = [tileSpriteSheet getSpriteFromKey:@"tile"];
    
  /*  characterSpriteSheet = [textureManager getFontSpriteSheetOfFontName:@"Lato-Bold" andSize:42 andType:FontSpriteTypeAlphabetsUppercase];
    [characterSpriteSheet generateMipMap];
    */
    shadowTexture = [textureManager getTexture:@"shadow" OfType:@"png"];
    [shadowTexture generateMipMap];
    
    tileTextureImage = [textureManager getTexture:@"tile" OfType:@"png"];
    [tileTextureImage generateMipMap];
    
    shadowTexCoordinates = [shadowTexture getTextureCoordinates];
    tileTexCoordinates = [tileTextureImage getTextureCoordinates];
    
    CGFloat t = 1.0f;
    
    
    tileVertices[0] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[1] = (Vector3D)  {.x = tileSquareSize/(2), .y = - tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[2] = (Vector3D)  {.x = tileSquareSize/(2), .y =  tileSquareSize/(2), .z = 0.0f, .t = t};
    
    tileVertices[3] =  (Vector3D) {.x = -tileSquareSize/(2), .y = -tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[4] = (Vector3D)  {.x = -tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f, .t = t};
    tileVertices[5] =  (Vector3D) {.x = tileSquareSize/(2), .y = tileSquareSize/(2), .z = 0.0f, .t = t};
    
    CGFloat sizeWithBorder = tileTextureSizeWithBorder;
    //adjustments for non retina
    if ([UIScreen mainScreen].scale == 1)
        sizeWithBorder = tileTextureSizeWithBorder + 1;
    
    transparentVertices[0] =  (Vector3D) {.x = -sizeWithBorder/(2), .y = -sizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[1] = (Vector3D)  {.x = sizeWithBorder/(2), .y = - sizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[2] = (Vector3D)  {.x = sizeWithBorder/(2), .y =  sizeWithBorder/(2), .z = 0.0f, .t = t};
    
    transparentVertices[3] =  (Vector3D) {.x = -sizeWithBorder/(2), .y = -sizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[4] = (Vector3D)  {.x = -sizeWithBorder/(2), .y = sizeWithBorder/(2), .z = 0.0f, .t = t};
    transparentVertices[5] =  (Vector3D) {.x = sizeWithBorder/(2), .y = sizeWithBorder/(2), .z = 0.0f, .t = t};
    
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
    CGFloat yMargin =   (frame.size.height  - (tileSquareSize) * 3 - 2 * verticalOffset)/2;
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
    CGFloat yMargin =   (frame.size.height - (tileSquareSize) * 3 - 2 * verticalOffset)/2;
    
    twelveLayout[0] = CGPointMake(thirteenLayout[0].x, 700);
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
    collapsePoint = CGPointMake((twelveLayout[5].x+twelveLayout[6].x)/2, twelveLayout[4].y);
    
}


-(void)createTiles
{
    tileColorData = malloc(sizeof(InstancedVertexColorData)* 6 * 13 * 2);
    tileTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 13);
    shadowTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 13);
    characterTextureData = malloc(sizeof(InstancedTextureVertexColorData)* 6 * 10 * 13);
    
    tilesArray = [[NSMutableArray alloc]init];
    
    for (int j = 0; j < 13; j++)
    {
        Tile *tile = [[Tile alloc]init];
        
        tile.tag = j;
        tile.colorIndex = j%2;
        tile.characterCounter.fontSpriteSheet = tileSpriteSheet;
        CGPoint anchorPoint = thirteenLayout[tile.tag];
        tile.centerPoint = CGPointMake(anchorPoint.x, 1000);
        [tilesArray addObject:tile];
        [self addElement:tile];
        
        [tile setupColors];
        [tile release];
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
    Tile *e2 = (Tile *)[self getElementByTag:7];
    Tile *t2 = (Tile *)[self getElementByTag:8];
    Tile *t = (Tile *)[self getElementByTag:9];
    Tile *e3 = (Tile *)[self getElementByTag:10];
    Tile *r = (Tile *)[self getElementByTag:11];
    Tile *s = (Tile *)[self getElementByTag:12];
    
    
    t.anchorPoint = thirteenLayout[3];
    z.anchorPoint = twelveLayout[2];
    a.anchorPoint = twelveLayout[0];
    [t throwToPoint:t.anchorPoint inDuration:0.3 afterDelay:0];
    [z throwToPoint:z.anchorPoint inDuration:0.3 afterDelay:0.05];
    [a throwToPoint:a.anchorPoint inDuration:0.3 afterDelay:0.1];
    
    t.anchorPoint = thirteenLayout[9];
    [t throwToPoint:t.anchorPoint inDuration:0.3 afterDelay:0.2];
    
    
    [l throwToPoint:thirteenLayout[1] inDuration:0.3 afterDelay:0.1];
    [s throwToPoint:thirteenLayout[5] inDuration:0.3 afterDelay:0.15];
    
    d.anchorPoint = twelveLayout[1];
    n.anchorPoint = twelveLayout[3];
    [d throwToPoint:d.anchorPoint inDuration:0.3 afterDelay:0.2];
    [n throwToPoint:n.anchorPoint inDuration:0.3 afterDelay:0.25];
    
    l.anchorPoint = twelveLayout[4];
    s.anchorPoint = twelveLayout[7];
    o.anchorPoint = twelveLayout[5];
    e.anchorPoint = twelveLayout[6];
    
    [l throwToPoint:l.anchorPoint inDuration:0.3 afterDelay:0.3];
    [s throwToPoint:s.anchorPoint inDuration:0.3 afterDelay:0.3];
    [o throwToPoint:o.anchorPoint inDuration:0.3 afterDelay:0.3];
    [e throwToPoint:e.anchorPoint inDuration:0.3 afterDelay:0.3];
    
    e2.anchorPoint = thirteenLayout[7];
    e3.anchorPoint = thirteenLayout[8];
    t2.anchorPoint = thirteenLayout[10];
    r.anchorPoint = thirteenLayout[11];
    
    [e2 throwToPoint:e2.anchorPoint inDuration:0.3 afterDelay:0.3];
    [e3 throwToPoint:e3.anchorPoint inDuration:0.3 afterDelay:0.3];
    [t2 throwToPoint:t2.anchorPoint inDuration:0.3 afterDelay:0.3];
    [r throwToPoint:r.anchorPoint inDuration:0.3 afterDelay:0.3];
    
    [self performSelector:@selector(recolorTilesTwelveLayout) withObject:nil afterDelay:0.3 ];
    
    
}

-(void)recolorTilesTwelveLayout
{
    [self retagTilesWithTwelveLayout];
    
    for (Tile *t in tilesArray)
    {
        if (t.tag == 0)
            continue;
        else if (t.tag <= 3)
            t.colorIndex = (t.tag - 1)%2;
         else if (t.tag <= 7)
             t.colorIndex = (t.tag - 4)%2;
        else if (t.tag <= 12)
             t.colorIndex = (t.tag - 8)%2;
    }
}

-(void)recolorTilesThirteenLayout
{
    for (Tile *t in tilesArray)
    {
        if (t.tag == 0)
            t.colorIndex = 0;
        else if (t.tag <= 5)
            t.colorIndex = (t.tag - 1)%2;
         else if (t.tag <= 12)
            t.colorIndex = (t.tag - 6)%2;
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

-(void)enableIsPlayable
{
    isPlayable = YES;
        [self performSelectorInBackground:@selector(checkArrangementForWords) withObject:nil];
}


-(void)tileFinishedMoving:(NSNotification *)notification
{
    if (!isPlayable)
        return;
    [self checkArrangementForWords];
   
}

-(void)checkArrangementForWords
{
    if (generatedString != nil)
        [generatedString release];
    
    generatedString = [[NSMutableString alloc]initWithString:@"#############"];
    int count = 0;
    
    for (Tile *tile in tilesArray)
    {
        for (int i = 1;i<13;i++)
        {
            if (twelveLayout[i].x == tile.centerPoint.x && twelveLayout[i].y == tile.centerPoint.y)
            {
                tileSequence[i] = count;
                [generatedString replaceCharactersInRange:NSMakeRange(i, 1) withString:tile.character];
            }
        }
        count++;
    }
    
    if (concatenatedWords != nil)
        [concatenatedWords release];
    concatenatedWords = [[NSMutableString alloc]init];
    
    
    checkWord3 = [dictionary checkIfWordExists:[generatedString substringWithRange:NSMakeRange(1, 3)]];
    checkWord4 = [dictionary checkIfWordExists:[generatedString substringWithRange:NSMakeRange(4, 4)]];
    checkWord5 = [dictionary checkIfWordExists:[generatedString substringWithRange:NSMakeRange(8, 5)]];
    
    [self animateForArrangement];
}

-(void)animateForArrangement
{
    score = 0;
    
    if (checkWord3 != -1)
    {
        for (int i = 1;i<4;i++)
        {
            Tile *t = tilesArray[tileSequence[i]];
            if (checkWord3 >= 0)
                [t wiggleFor:1.0];
            [t animateShowColorInDuration:0.2];
        }
    }
    
    if (checkWord3 >= 0)
        score += 3;
    
    if (checkWord4 != -1)
    {
        for (int i = 4;i<8;i++)
        {
            Tile *t = tilesArray[tileSequence[i]];
            if (checkWord4 >= 0)
                [t wiggleFor:1.0];
            [t animateShowColorInDuration:0.2];
        }
    }
    
    if (checkWord4 >= 0)
        score += 4;
    
    
    if (checkWord5 != -1)
    {
        for (int i = 8;i<13;i++)
        {
            Tile *t = tilesArray[tileSequence[i]];
            if (checkWord5 >= 0)
                [t wiggleFor:1.0];
            [t animateShowColorInDuration:0.2];
        }
    }
    
    if (checkWord5 >= 0)
        score += 5;
    
    if (checkWord3 != -1 && checkWord4 != -1 && checkWord5 != -1)
    {
        [self togglePlayability:NO];
        if (target)
        {
            TileControlEventData *eventData = [[TileControlEventData alloc]init];
            eventData.eventState  = 1;
            [target performSelector:selector withObject:eventData];
            
        }
        return;
    }
    if (target)
    {
        TileControlEventData *eventData = [[TileControlEventData alloc]init];
        eventData.eventState  = 0;
        eventData.score = score;
        [target performSelector:selector withObject:eventData];
        
    }
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
    
    if (animationRatio>=1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    
}
-(void)animationEnded:(Animation *)animation
{
    
}

-(void)showTiles
{
    CGFloat delay = 0.0;
    int count = 0;
    self.originInsideElement = CGPointMake(0,0);
    
    for (Tile *tile in [tilesArray reverseObjectEnumerator])
    {
        CGPoint anchorPoint = thirteenLayout[tile.tag];
        tile.centerPoint = CGPointMake(anchorPoint.x, 1000);
        tile.anchorPoint = anchorPoint;
        [animator removeRunningAnimationsForObject:tile];
        [animator removeQueuedAnimationsForObject:tile];
        [tile setTileCharacter:[self getThirteenCharacterFromTag:tile.tag]];
        
        if (tile.tag == 0)
        {
            [tile moveToPoint:tile.anchorPoint inDuration:0.3 afterDelay:1.3];
        [self performSelector:@selector(playTileSound) withObject:nil afterDelay:1.3];
            continue;
        }
        [self performSelector:@selector(playTileSound) withObject:nil afterDelay:0.05 * count];
        [tile throwToPoint:tile.anchorPoint inDuration:0.3 afterDelay:0.05 * count];
        [tile moveToBack];
        delay += 0.08;
        count ++;
        
        [self recolorTilesThirteenLayout];
    }
}

-(void)playTileSound
{
    CGFloat p = (rand()%20+1)/20.0;
    [soundManager playSoundWithKey:@"place" gain:1.0f
                             pitch:0.0f+p
                          location:CGPointZero
                        shouldLoop:NO];

}

-(void)hideTiles
{
    CGFloat delay = 0.00;
    for (Tile *tile in [subElements reverseObjectEnumerator])
    {
        [tile moveToPoint:CGPointMake(thirteenLayout[tile.tag].x, 700) inDuration:1 afterDelay:delay];

        delay += 0.05;

    }
}

-(void)startHidingTiles
{
    [self retagTilesWithTwelveLayout];
    isPlayable = NO;
    CGFloat reduceDelay= 0.0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableIsPlayable) object:nil];
    
    for (Tile *t in tilesArray)
    {
        [animator removeRunningAnimationsForObject:t];
        [animator removeQueuedAnimationsForObject:t];
        t.wiggleAngle = 0;
        
        CGFloat dist = (t.centerPoint.x - collapsePoint.x) * (t.centerPoint.x - collapsePoint.x) + (t.centerPoint.y - collapsePoint.y) * (t.centerPoint.y - collapsePoint.y) ;
        
        if (dist <= 625)
        {
            reduceDelay -=0.05;
            continue;
        }
    }
    
   
    
    for (Tile *t in tilesArray)
    {
        if (t.tag == 0)
            continue;
        
         [t animateHideColorInDuration:0.2];
       
        CGFloat d = ([self calculateDelayFromTag:t.tag])-reduceDelay;
        if (d < 0)
            d = 0;
       [t moveToPoint:collapsePoint inDuration:0.3 afterDelay:d];
//        [self performSelector:@selector(playTileSound) withObject:nil afterDelay:d];
    }
}

-(void)setupSounds
{
    soundManager = [SoundManager sharedSoundManager];
    [soundManager loadSoundWithKey:@"pick" soundFile:@"on_tile_translate_to_position.aiff"];
    [soundManager loadSoundWithKey:@"place" soundFile:@"on_tile_translate_to_position.aiff"];
    
}


-(CGFloat)calculateDelayFromTag:(int)etag
{
    CGFloat delay = 0.05;
    CGFloat result = 2;
    
    if (etag == 5 || etag == 6)
        result = 0;
    else if (etag <= 3)
        result = delay * etag;
    else if (etag == 7)
        result = delay * 4;
    else if (etag > 7 && etag <= 13)
        result = delay * ((12 - etag) + 5);
    else if (etag == 4)
        result = delay * 10;
    
    return result;
}

-(void)cancelHidingTiles
{
    CGFloat delay = 0.0;
    for (Tile *t in tilesArray)
    {
        [animator removeRunningAnimationsForObject:t];
        [animator removeQueuedAnimationsForObject:t];
        
        if (t.tag == 5 || t.tag ==6)
            continue;
        
        if (t.centerPoint.x != t.anchorPoint.x || t.centerPoint.y !=  t.anchorPoint.y)
            delay += 0.05;
    }
    
    
    for (Tile *t in tilesArray)
    {
        if (t.tag == 0)
            continue;
        
        [animator removeRunningAnimationsForObject:t];
        [animator removeQueuedAnimationsForObject:t];
        
        if (t.centerPoint.x != t.anchorPoint.x || t.centerPoint.y !=  t.anchorPoint.y)
            [t throwToPoint:t.anchorPoint inDuration:0.3 afterDelay:(delay-[self calculateDelayFromTag:t.tag])/5.0];
        
    }
  //  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playTileSound) object:nil];
    
    [self performSelector:@selector(enableIsPlayable) withObject:nil afterDelay:0.2];
}

-(void)retagTilesWithTwelveLayout
{
    for (Tile *t in tilesArray)
    {
        for (int i = 1;i<=12;i++)
        {
            if (t.anchorPoint.x == twelveLayout[i].x && t.anchorPoint.y == twelveLayout[i].y)
            {
                t.tag = i;
            }
        }
    }
}

-(NSString *)getThirteenCharacterFromTag:(int)ttag
{
    switch (ttag) {
        case 0:
            return @"A";
            break;
        case 1:
            return @"D";
            break;
        case 2:
            return @"O";
            break;
        case 3:
            return @"Z";
            break;
        case 4:
            return @"E";
            break;
        case 5:
            return @"N";
            break;
        case 6:
            return @"L";
            break;
        case 7:
            return @"E";
            break;
        case 8:
            return @"T";
            break;
        case 9:
            return @"T";
            break;
        case 10:
            return @"E";
            break;
        case 11:
            return @"R";
            break;
        case 12:
            return @"S";
            break;
            
        default:
            break;
    }
    return @"";
}

-(void)loadDozenLetters:(NSString *)letters
{
    [self retagTilesWithTwelveLayout];
    
    for (Tile *t in tilesArray)
    {
        if (t.tag == 0)
            continue;
        
        NSString *character = [letters substringWithRange:NSMakeRange((t.tag - 1), 1)];
        [t setTileCharacter:character];
        [t animateHideColorInDuration:0.2];
        
    }
    [self togglePlayability:YES];
}

-(void)togglePlayability:(BOOL)ON
{
    if (ON)
    {
        for (Tile * t in tilesArray)
        {
            if (t.tag == 0)
                continue;
            t.tilesArray = tilesArray;
        }
    }
    else
    {
        for (Tile * t in tilesArray)
            t.tilesArray = nil;
    }
    isPlayable = ON;
}


-(void)drawBatchedElements
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
        
        
        
        if (isPlayable)
        {
        
        for (int j = 0;j<6;j++)
        {
                memcpy(&((characterTextureData + characterDataCount)->mvpMatrix), result, sizeof(Matrix3D));
                (characterTextureData + characterDataCount)->vertex = transparentVertices[j];
                (characterTextureData + characterDataCount)->color = *(tile.currentTileColor + tile.colorIndex);
                (characterTextureData + characterDataCount)->texCoord = tileSprite.textureCoordinates[j];
                characterDataCount++;
            }
        
        }
        else
        {
            for (int j = 0;j<6;j++)
            {
                memcpy(&((tileTextureData + i * 6 + j)->mvpMatrix), result, sizeof(Matrix3D));
                (tileTextureData + i * 6 + j)->vertex = transparentVertices[j];
                (tileTextureData + i * 6 + j)->color = *(tile.currentTileColor + tile.colorIndex);
                (tileTextureData + i * 6 + j)->texCoord = tileTexCoordinates[j];
                tileColorVerticesCount++;
            }
            
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
    
    if (!isPlayable)
    {
        stringTextureRenderer.texture = tileTextureImage;
        [stringTextureRenderer drawWithArray:tileTextureData andCount:tileColorVerticesCount];
    }
    
    stringTextureRenderer.texture = tileSpriteSheet;
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
    [tilesArray release];
    [super dealloc];
}



@end
