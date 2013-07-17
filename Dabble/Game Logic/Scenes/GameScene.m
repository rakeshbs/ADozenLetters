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
#import "ElasticCounter.h"

#define yOffset 75

#define totalTimePerGame 122

#define SCORE_PER_WORD 10
#define SCORE_PER_TRIPLET 100

#define ANIMATION_ZOOM_TILES 1
#define ANIMATION_CENTER_TILES 2

@interface GameScene (Private)
@end

@implementation GameScene

Color4B whiteColor4B = (Color4B){.red = 255, .green = 255, .blue = 255, .alpha=255};
Color4B blackColor4B = (Color4B){.red = 0, .green = 0, .blue = 0, .alpha=255};

ScoreControl *scoreControl;
Dictionary *dictionary;
-(id)init
{
    if (self = [super init])
    {
        self.scaleInsideElement = CGPointMake(0.4,0.4);
        self.originInsideElement = CGPointMake(0,180);
        numberOfTripletsMade = 0;
        numberOfDoublesMade = 0;
        numberOfWordsMade = 0;
    
        madeWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
        remainingTime = totalTimePerGame;
        [self loadDictionary];
        
        scoreControl = [[ScoreControl alloc]initWithFrame:CGRectMake(180, 400, 150, 60)];
        [scoreControl setFont:@"Lato" withSize:40];
        [self addElement:scoreControl];
       
        
     //   [self performSelector:@selector(set) withObject:nil afterDelay:2];
    //    [scoreControl performSelector:@selector(stop) withObject:nil afterDelay:6];
//               [self performSelector:@selector(set1) withObject:nil afterDelay:4.0];
     
        
       tileControl = [[TileControl alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged:)];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

    }
    return  self;
}


-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_ZOOM_TILES)
    {
        CGFloat s = getEaseInOut(0.3, 1, animationRatio,animation.duration);
        self.scaleInsideElement = CGPointMake(s,s);
        
    }
    else if (animation.type == ANIMATION_CENTER_TILES)
    {
        CGFloat y = getEaseInOut(startOriginPoint.y,0,animationRatio,animation.duration);
        CGFloat x = getEaseInOut(startOriginPoint.x,0,animationRatio,animation.duration);
        self.originInsideElement = CGPointMake(x, y);
        
    }
    
    if (animationRatio > 1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    startOriginPoint = self.originInsideElement;
}

-(void)animationEnded:(Animation *)animation
{
    
}

-(void)showTiles
{
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
        return;
    }
    
    for (NSString *data in tileControl.newWordsPerMove)
    {
        int score = 0;
        switch (data.length) {
            case 3:
                score = 5;
                break;
            case 4:
                score = 10;
            default:
            case 5:
                score = 15;
                break;
        }
        
        currentRoundScore += score;
    }
    
    if (eventData.concatenatedString.length == 12)
    {
         [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setScore) object:nil];
        [tileControl performSelector:@selector(hideTiles) withObject:nil afterDelay:1.0];
    }
    
    [scoreControl setValue:currentRoundScore inDuration:0.3];
}



-(void)loadData
{
    currentRoundScore = 0;
    //[tileControl createTiles:[dictionary generateDozenLetters]];
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setScore) object:nil];
    remainingTime = totalTimePerGame;
    lastUpdate = CFAbsoluteTimeGetCurrent();
    prevTimeLeft=totalTimePerGame;
    isTimerRunning = YES;
    currentRoundScore = 100;
    [scoreControl setValue:currentRoundScore inDuration:0.3];
    [self performSelector:@selector(setScore) withObject:nil afterDelay:1.0];
    [self showTiles];
}

-(void)setScore
{
    currentRoundScore --;
    [scoreControl setValue:currentRoundScore inDuration:0.3];
    if (currentRoundScore <=0)
    {
        [tileControl rearrangeToTwelveLetters];
        return;
    }
    [self performSelector:@selector(setScore) withObject:nil afterDelay:1.0];
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
        [tileControl rearrangeToTwelveLetters];
        self.originInsideElement = CGPointMake(0,200);
        [animator addAnimationFor:self ofType:ANIMATION_ZOOM_TILES ofDuration:0.9 afterDelayInSeconds:0];
        [animator addAnimationFor:self ofType:ANIMATION_CENTER_TILES ofDuration:0.9 afterDelayInSeconds:0];

    }
    return YES;
}

-(void)dealloc
{

    [tilesArray release];
    [super dealloc];
}


@end
