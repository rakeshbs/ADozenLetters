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
#import "ElasticNumericCounter.h"

#define yOffset 75

#define totalTimePerGame 122

#define SCORE_PER_WORD 10
#define SCORE_PER_TRIPLET 100


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
        
        numberOfTripletsMade = 0;
        numberOfDoublesMade = 0;
        numberOfWordsMade = 0;
    
        madeWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
        remainingTime = totalTimePerGame;
        [self loadDictionary];
        
        ElasticNumericCounter *counter = [[ElasticNumericCounter alloc]
                                          initWithFrame:CGRectMake(135, 200, 50, 50)];
        [counter setFont:@"Lato" withSize:50];
        [counter setSequence:[NSMutableArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",
                              @"7",@"8",@"9",nil]];
        [self addElement:counter];
        
        [counter setValueCountUp:1];
        
        self.scaleInsideElement = 0.5;
        
        tileControl = [[TileControl alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged:)];
        
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0.1];
        [self performSelector:@selector(showTiles) withObject:nil afterDelay:5];
        
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

       
    }
    return  self;
}



-(void)showTiles
{
    [self hideActivityIndicator];
    [tileControl showTiles];
}

-(void)loadDictionary
{
    dictionary = [Dictionary getSharedDictionary];
}

-(void)tileRearranged:(TileControlEventData *)eventData
{
    if (eventData.scorePerMove == -1)
    {
        [self loadData];
        [self performSelector:@selector(showTiles) withObject:nil afterDelay:5];
        return;
    }
    
    currentRoundScore += eventData.scorePerMove * SCORE_PER_WORD;
    
    if (eventData.concatenatedString.length == 12)
        currentRoundScore += SCORE_PER_TRIPLET;
    
}



-(void)loadData
{
   
    currentRoundScore = 0;
    [tileControl createTiles:[dictionary generateDozenLetters]];

    remainingTime = totalTimePerGame;
    lastUpdate = CFAbsoluteTimeGetCurrent();
    prevTimeLeft=totalTimePerGame;
    isTimerRunning = YES;
    [self update];
}


-(void)draw{
    Color4B color;
	color.red =241;
	color.blue = 196;
	color.green = 15;
	color.alpha = 255;
    [director clearScene:color];
}

-(void)update
{
    if (!isTimerRunning)
        return;
}

-(void)updateAnalytics
{
    
  
}

NSMutableArray *tilesArray;

-(void)sceneMadeActive
{
    
};

-(void)sceneMadeInActive
{
    [super sceneMadeInActive];
    
}

-(BOOL)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    if (touch.tapCount == 2)
    {
        [tileControl hideTiles];
    }
    return YES;
}

-(void)dealloc
{
    [super dealloc];
    [tilesArray release];
}


@end
