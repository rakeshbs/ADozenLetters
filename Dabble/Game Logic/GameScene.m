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

@interface GameScene (Private)
-(void)createTiless;
@end

@implementation GameScene


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
                            initWithString:@"W : 0 (0,0,0) D : 0 T : 0"                                                 dimensions:CGSizeMake(320, 50)
                            horizontalAlignment:UITextAlignmentLeft
                            verticalAlignment:UITextAlignmentMiddle
                            fontName:@"Helvetica" fontSize:20];
        
        //analyticsShader.textureColor = ((Color4f) {.red = 1.0, .blue = 1.0, .green = 1.0, .alpha = 1.0});
        
        
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];
        onBoardWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
   //     [self performSelectorInBackground:@selector(loadDictionary) withObject:nil];
        
        [self loadData];
        
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
   // NSData *data = [NSData dataWithContentsOfURL:url];
   // NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //NSString *stringData = [dataDict[@"chars"] uppercaseString];
    //[self performSelectorOnMainThread:@selector(sendCharData:) withObject:stringData waitUntilDone:YES];
    
    [self performSelectorOnMainThread:@selector(createTiles:) withObject:@"ABCDEFGHIJKL" waitUntilDone:YES];
    
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
        [elements removeObjectsInArray:tilesArray];
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
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
   [mvpMatrixManager pushModelViewMatrix];
    [mvpMatrixManager translateInX:200 Y:380 Z:0];
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

-(void)tileFinishedMoving:(NSNotification *)notification
{
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
    /*
    [analyticsTexture release];
    analyticsTexture = [[Texture2D alloc]
                        initWithString:[NSString stringWithFormat:@"W : %d (%d, %d, %d) D : %d T : %d",numberOfWordsMade,numberOfWordsPerLetter[0],numberOfWordsPerLetter[1],numberOfWordsPerLetter[2],numberOfDoublesMade,numberOfTripletsMade]                                                 dimensions:CGSizeMake(320, 50)
                        horizontalAlignment:UITextAlignmentLeft
                        verticalAlignment:UITextAlignmentMiddle
                        fontName:@"Helvetica" fontSize:20];
     */
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
        [self performSelectorInBackground:@selector(loadData) withObject:nil];
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

//GameCenter Functions
- (void)matchStarted
{
    [self sendRandomNumber];
    
}
- (void)matchEnded
{
    NSLog(@"match Ended");
}
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    Message *message = (Message *) [data bytes];
    
    int messageType = message->messageType;
    
    NSLog(@"message recieved");
    
    if (messageType== kMessageTypeRandomNumber)
    {
        if (currentRandomNumber == 0)
            return;
        
        MessageRandomNumber * messRandom = (MessageRandomNumber *) [data bytes];
        if (currentRandomNumber > messRandom->randomNumber)
        {
            isServer = YES;
            [self performSelectorInBackground:@selector(loadData) withObject:nil];
            NSLog(@"is server");
        }
        else if (currentRandomNumber == messRandom->randomNumber)
        {
            currentRandomNumber =  arc4random()+1;
            [self sendRandomNumber];
        }
        else
        {
            isServer = NO;
            NSLog(@"is not server");
        }
    }
    else if (messageType == kMessageTypeCharData)
    {
        MessageCharData * messData = (MessageCharData *) [data bytes];
        
        NSString *stringData = [NSString stringWithCString:messData->charData encoding:NSUTF8StringEncoding];
        //          int k = 0;
        [self performSelectorOnMainThread:@selector(createTiless:) withObject:stringData waitUntilDone:YES];
    }
}
- (void)inviteReceived
{
    
}
- (void)localUserAuthenticated
{
    
    [gcHelper findMatchWithMinPlayers:2 maxPlayers:2 viewController:director.openGLViewController delegate:self];
}

-(void)sendRandomNumber
{
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = currentRandomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendDataToOthers:data];
}

-(void)sendCharData:(NSString *)stringData
{
    MessageCharData message;
    message.message.messageType = kMessageTypeCharData;
    const char *charArray = [stringData cStringUsingEncoding:NSUTF8StringEncoding];
    
    for (size_t idx = 0; idx < 12; ++idx) {
        message.charData[idx] = charArray[idx];
    }
    message.charData[12]='\0';
    
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageCharData)];
    [self sendDataToOthers:data];
}

-(void)sendDataToOthers:(NSData *)data
{
    [gcHelper.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:nil];
}


-(void)dealloc
{
    [super dealloc];
    [tilesArray release];
}


@end
