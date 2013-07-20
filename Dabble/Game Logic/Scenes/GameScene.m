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

#define TOP_BUTTONS_SIZE 75

#define SCORE_PER_WORD 10
#define SCORE_PER_TRIPLET 100

#define ANIMATION_ZOOM_IN 1
#define ANIMATION_ZOOM_OUT 2

#define SCENE_SCALE 0.4f
#define SCENE_VERTICAL_OFFSET 180


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
                playButton.touchable = NO;
        self.scaleInsideElement = CGPointMake(SCENE_SCALE,SCENE_SCALE);
        self.originInsideElement = CGPointMake(0,SCENE_VERTICAL_OFFSET);
        numberOfTripletsMade = 0;
        numberOfDoublesMade = 0;
        numberOfWordsMade = 0;
        
        madeWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
        remainingTime = totalTimePerGame;
        [self loadDictionary];
        
        scoreControl = [[ScoreControl alloc]initWithFrame:CGRectMake(800, 480-TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE)];
        [scoreControl setFont:@"Lato" withSize:30];
        [scoreControl setBackgroundColor:(Color4B){.red = 255,.green = 255, .blue =255,.alpha = 85}];
        [self addElement:scoreControl];
        
        
        tileControl = [[TileControl alloc]initWithFrame:CGRectMake(-120,0,self.frame.size.width+240,self.frame.size.height)];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged:)];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
        [tileControl release];
        
        playButton = [[GLButton alloc]initWithFrame:CGRectMake(-200, -750, 720, 300)];
        [playButton setText:@"play" withFont:@"Lato" andSize:120];
        [playButton addTarget:self andSelector:@selector(playButtonClicked)];
        [self addElement:playButton];
        [playButton release];
        
        closeButton = [[CloseButton alloc]initWithFrame:CGRectMake(-800, 480-TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE)];
        [self addElement:closeButton];
        [closeButton release];
        closeButton.delegate = self;
    }
    return  self;
}


-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_ZOOM_IN)
    {
        CGFloat s = getEaseInOut(SCENE_SCALE, 1, animationRatio,animation.duration);
        self.scaleInsideElement = CGPointMake(s,s);
        CGFloat pos =  getEaseInOut(800, 320 - scoreControl.frame.size.width, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos1 =  getEaseInOut(-800,0, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos1,closeButton.frame.origin.y,
                                        closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(SCENE_VERTICAL_OFFSET,0,animationRatio,animation.duration);
        CGFloat x = self.originInsideElement.x;
        self.originInsideElement = CGPointMake(x, y);
        
    }
    else if (animation.type == ANIMATION_ZOOM_OUT)
    {
        CGFloat s = getEaseInOut(1, 0.4, animationRatio,animation.duration);
        self.scaleInsideElement = CGPointMake(s,s);
        CGFloat pos =  getEaseInOut(320 - scoreControl.frame.size.width, 800, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos1 =  getEaseInOut(0,-800, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos1,closeButton.frame.origin.y,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(0,SCENE_VERTICAL_OFFSET,animationRatio,animation.duration);
        CGFloat x = self.originInsideElement.x;
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
    if (animation.type == ANIMATION_ZOOM_OUT)
    {
        [self showTiles];
    }
}

-(void)showTiles
{
    [tileControl showTiles];
    [self performSelector:@selector(enablePlayButton) withObject:nil afterDelay:1.5];
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
    currentRoundScore = 120;
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

-(void)closeButtonClick:(int)event
{
    if (event == CLOSEBUTTON_CLICK_STARTED)
    {
        [tileControl startHidingTiles];
    }
    else if (event == CLOSEBUTTON_CLICK_CANCELLED)
    {
        [tileControl cancelHidingTiles];
    }
    else if (event == CLOSEBUTTON_CLICK_FINISHED)
    {
        playButton.touchable = NO;
        [tileControl hideTiles];
         [animator addAnimationFor:self ofType:ANIMATION_ZOOM_OUT ofDuration:0.7 afterDelayInSeconds:0.0];
    }
}

-(void)enablePlayButton
{
    playButton.touchable = YES;
}

-(void)playButtonClicked
{
    [tileControl rearrangeToTwelveLetters];
    self.originInsideElement = CGPointMake(0,180);
    [animator addAnimationFor:self ofType:ANIMATION_ZOOM_IN ofDuration:0.7 afterDelayInSeconds:0];
    currentRoundScore = 121;
}

-(void)dealloc
{
    
    [tilesArray release];
    [super dealloc];
}


@end
