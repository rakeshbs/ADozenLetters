//
//  GameScene.m
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GameScene.h"
#import "Dictionary.h"
#import "NSArray+Additions.h"

#define yOffset 75

#define totalTimePerGame 122

@interface GameScene (Private)
-(void)createTiless;
@end

@implementation GameScene

Color4B whiteColor4B = (Color4B){.red = 255, .green = 255, .blue = 255, .alpha=255};
Color4B blackColor4B = (Color4B){.red = 0, .green = 0, .blue = 0, .alpha=255};


Dictionary *dictionary;
-(id)init
{
    if (self = [super init])
    {
        
        
        currentRandomNumber =  arc4random()+1;
        
        numberOfTripletsMade = 0;
        numberOfDoublesMade = 0;
        numberOfWordsMade = 0;
        for (int i = 0;i<3;i++)
            numberOfWordsPerLetter[i] = 0;
        
        analyticsTexture = [[Texture2D alloc]
                            initWithString:@"W : 0 (0,0,0) D : 0 T : 0"                                                 dimensions:CGSizeMake(320, 30)
                            horizontalAlignment:UITextAlignmentLeft
                            verticalAlignment:UITextAlignmentMiddle
                            fontName:@"Lato" fontSize:30];
        
    
        //analyticsTextureRenderUnit = [textureRenderer getNewTextureRenderUnit];
       // timerTextureRenderUnit = [textureRenderer getNewTextureRenderUnit];
        analyticsTextureRenderUnit.texture = analyticsTexture;
        analyticsTextureRenderUnit.isFont = YES;
        timerTextureRenderUnit.isFont = YES;
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];
        onBoardWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
        remainingTime = totalTimePerGame;
        [self performSelectorInBackground:@selector(loadDictionary) withObject:nil];
        
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.0];
        
        
    }
    return  self;
}

-(void)loadDictionary
{
    dictionary = [Dictionary getSharedDictionary];
}

-(void)loadData
{
    
    NSURL *url = [NSURL URLWithString:@"http://qucentis.com/dabble.php"];

    
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *stringData = [dataDict[@"chars"] uppercaseString];
    //[self performSelectorOnMainThread:@selector(sendCharData:) withObject:stringData waitUntilDone:YES];
    
    remainingTime = totalTimePerGame;
    lastUpdate = CFAbsoluteTimeGetCurrent();
    prevTimeLeft=totalTimePerGame;
    isTimerRunning = YES;
    [self update];
    [self performSelectorOnMainThread:@selector(createTiles:) withObject:stringData waitUntilDone:YES];
    
}

-(void)createTiles:(NSString *)dataStr
{
    int ind = 0;
    
    [dictionary reset];
    
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
        tile.centerPoint = CGPointMake(160, 160+yOffset);
        tile.anchorPoint = CGPointMake(100+60*i, 210+yOffset);
        tile.colorIndex = i%2;
        [self addElement:tile];
        [tilesArray addObject:tile];
        tile.tilesArray  = tilesArray;
        [tile release];
    }
    
    
    for (int i = 0;i<4;i++)
    {
        tile = [[Tile alloc]initWithCharacter:charArray2[i]];
        tile.centerPoint = CGPointMake(160, 160+yOffset);
        tile.anchorPoint = CGPointMake(70+60*i, 130+yOffset);
        tile.colorIndex = i%2;
        [self addElement:tile];
        [tilesArray addObject:tile];
        tile.tilesArray  = tilesArray;
        [tile release];
    }
    
    for (int i = 0;i<5;i++)
    {
        tile = [[Tile alloc]initWithCharacter:charArray3[i]];
        tile.centerPoint = CGPointMake(160, 160+yOffset);
        tile.anchorPoint = CGPointMake(40+60*i, 50+yOffset);
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
    
    [self performSelector:@selector(enableNotification) withObject:nil afterDelay:0];
    
}

-(void)enableNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileFinishedMoving:) name:@"TileFinishedMoving" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileBreakBond:)
                                                name:@"TileBreakBond" object:nil];
    
    
}

-(void)draw{
	Color4B color;
	color.red =241;
	color.blue = 196;
	color.green = 15;
	color.alpha = 255;
    [director clearScene:color];
    
    
    
    [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:170 Y:340 Z:0];
    
    [analyticsTextureRenderUnit addDefaultTextureCoordinatesWithColor:whiteColor4B];
    [mvpMatrixManager translateInX:-40 Y:40 Z:0];
    
    [timerTextureRenderUnit addDefaultTextureCoordinatesWithColor:whiteColor4B];
    
    [mvpMatrixManager popModelViewMatrix];
    
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

-(void)update
{
    if (!isTimerRunning)
        return;
    
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    remainingTime-=(currentTime - lastUpdate);
    int currentTimeLeft = (int)remainingTime;
    if (currentTimeLeft< prevTimeLeft)
    {
        int minutes = currentTimeLeft/60;
        int seconds = currentTimeLeft%60;
        
        NSString *time = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
        
        Texture2D *timeTexture = [[Texture2D alloc]initWithString:time dimensions:CGSizeMake(140, 40) horizontalAlignment:UITextAlignmentCenter verticalAlignment:UITextAlignmentMiddle fontName:@"Lato" fontSize:30];
        timerTextureRenderUnit.texture = timeTexture;
        [timeTexture release];
        
    }
    if (currentTimeLeft <= 0)
        isTimerRunning = NO;
    prevTimeLeft = currentTimeLeft;
    lastUpdate = currentTime;
}

-(void)tileFinishedMoving:(NSNotification *)notification
{
    if (!isTimerRunning)
        return;
    
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
    
}

-(void)updateAnalytics
{
    
    [analyticsTexture release];
    analyticsTexture = [[Texture2D alloc]
                        initWithString:[NSString stringWithFormat:@"W : %d (%d, %d, %d) D : %d T : %d",numberOfWordsMade,numberOfWordsPerLetter[0],numberOfWordsPerLetter[1],numberOfWordsPerLetter[2],numberOfDoublesMade,numberOfTripletsMade]                                                 dimensions:CGSizeMake(320, 30)
                        horizontalAlignment:UITextAlignmentLeft
                        verticalAlignment:UITextAlignmentMiddle
                        fontName:@"Lato" fontSize:30];
    analyticsTextureRenderUnit.texture = analyticsTexture;
     
}

NSMutableArray *tilesArray;

-(void)sceneMadeActive
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
};

-(void)sceneMadeInActive
{
    [super sceneMadeInActive];
    
}

-(BOOL)touchBeganInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    if (touch.tapCount == 2)
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"TileFinishedMoving" object:nil];
        [self loadData];
        numberOfDoublesMade = 0;
        numberOfTripletsMade = 0;
        numberOfWordsMade = 0;
        for (int i = 0;i<3;i++)
            numberOfWordsPerLetter[i] = 0;
        [dictionary reset];
        [self updateAnalytics];
    }
    return YES;
}

-(void)dealloc
{
    [super dealloc];
    [tilesArray release];
}


@end
