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
        
        
        
        tileControl = [[TileControl alloc]init];
        tileControl.frame = CGRectMake(0,100,320,300);
        [self addElement:tileControl];
        
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
    [tileControl createTiles:@"TEH,WROD,GAMRE"];
    
    remainingTime = totalTimePerGame;
    lastUpdate = CFAbsoluteTimeGetCurrent();
    prevTimeLeft=totalTimePerGame;
    isTimerRunning = YES;
    [self update];
//    [self performSelectorOnMainThread:@selector(createTiles:) withObject:stringData waitUntilDone:YES];
    
}

-(void)enableNotification
{
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileFinishedMoving:) name:@"TileFinishedMoving" object:nil];
  //  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tileBreakBond:)
    //                                            name:@"TileBreakBond" object:nil];
    
    
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
    /*
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
    lastUpdate = currentTime;*/
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
