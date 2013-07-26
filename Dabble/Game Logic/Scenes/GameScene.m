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
#define ANIMATION_HUE_CHANGE 3
#define ANIMATION_START_SCENE 4

#define STATE_PLAYING 1
#define STATE_HOME 2
#define STATE_SPLASH 3


#define SCENE_SCALE 0.5f
#define SCENE_VERTICAL_OFFSET 160
#define SCENE_ZOOMEDIN_VERTICAL_OFFSET -20



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
        currentHue = 0;
        currentState = STATE_SPLASH;
        playButton.touchable = NO;
        
 //       self.scaleInsideElement = CGPointMake(SCENE_SCALE,SCENE_SCALE);
   //     self.originInsideElement = CGPointMake(0,SCENE_VERTICAL_OFFSET);
//        self.scaleInsideElement = CGPointMake(START_SCENCE_SCALE,START_SCENCE_SCALE);
  //      self.originInsideElement = CGPointMake(0,START_SCENE_OFFSET);
        
        [self loadDictionary];
        
        CGFloat screenHeight = [[UIScreen mainScreen]bounds].size.height;
        
        scoreControl = [[ScoreControl alloc]initWithFrame:CGRectMake(800, -SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE
                                                                     , TOP_BUTTONS_SIZE)];
        [scoreControl setFont:@"Lato-Black" withSize:30];
        [scoreControl setTextColor:(Color4B){255,255,255,255}];
        [scoreControl setFrameBackgroundColor:(Color4B){.red = 128,.green = 128, .blue =128,.alpha = 85}];
        [self addElement:scoreControl];
        [scoreControl release];
        
        tileControl = [[TileControl alloc]initWithFrame:CGRectMake(-160, 0,self.frame.size.width+320,self.frame.size.height)];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged:)];
        [tileControl release];
        
        scoreButton = [[GLButton alloc]initWithFrame:CGRectMake(-130, -200, 576, 220)];
        [scoreButton setTextColor:(Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 45}];
        [scoreButton setBackgroundColor:(Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 45}];
        [self addElement:scoreButton];
        [scoreButton release];
        
        playButton = [[GLButton alloc]initWithFrame:CGRectMake(-130, -520, 576, 250)];
        [playButton setText:@"play" withFont:@"Lato-Bold" andSize:120];
        [playButton addTarget:self andSelector:@selector(playButtonClicked)];
        [playButton setFrameBackgroundColor:(Color4B){0,0,0,128}];
        [self addElement:playButton];
        playButton.touchable = NO;
        [playButton release];
        
        
        totalScoreControl = [[ScoreControl alloc]initWithFrame:
                             CGRectMake(-120,-90,546,72)];
        [totalScoreControl setFont:@"Lato-Black" withSize:70];
        [totalScoreControl setFrameBackgroundColor:(Color4B){.red = 128,.green = 128, .blue =128,.alpha = 0}];
        [totalScoreControl setTextColor:(Color4B){.red = 0,.green = 0, .blue =0,.alpha = 150}];
        
        [self addElement:totalScoreControl];
        [totalScoreControl release];
        
        
        closeButton = [[CloseButton alloc]initWithFrame:CGRectMake(-800, -SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE,
                                                                   TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE)];
        [self addElement:closeButton];
        [closeButton release];
        closeButton.delegate = self;
        scoreCounter = 0;
        
        rankingControl = [[RankingControl alloc]initWithFrame:CGRectMake(-130, -150, 576, 32)];
        
        [rankingControl setFont:@"Lato-Bold" withSize:30];
        [rankingControl setColor:(Color4B){0,0,0,255}];
        [self addElement:rankingControl];
        [rankingControl release];
        
        
        fullScreenElement = [[GLElement alloc]initWithFrame:CGRectMake(-2000, -2000, 4000, 4000)];
        fullScreenElement.touchable = NO;
        fullScreenElement.frameBackgroundColor = (Color4B){0,0,0,255};
        [self addElement:fullScreenElement];
        [fullScreenElement release];
       
        
        [tileControl moveToFront];
        

        activityIndictor = [[GLActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, 320,
                                                                                screenHeight)];
        [self addElement:activityIndictor];
        activityIndictor.delegate = self;
        [activityIndictor show];
        
        gcHelper = [GCHelper getSharedGCHelper];
        gcHelper.delegate = self;
        if (gcHelper.totalRanks > 0)
            currentHue = (gcHelper.totalRanks - (gcHelper.currentRank - 1))/gcHelper.totalRanks *  0.55;
        else
            currentHue = 0;
    }
    return  self;
}


-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animationRatio = [animation getAnimatedRatio];
    if (animation.type == ANIMATION_START_SCENE)
    {
        int alpha = getEaseOut(255, 0, animationRatio);
        fullScreenElement.frameBackgroundColor = (Color4B){0,0,0,alpha};
    }
    
    else if (animation.type == ANIMATION_ZOOM_IN)
    {
        CGFloat s = getEaseInOut(SCENE_SCALE, 1, animationRatio,animation.duration);
        self.scaleInsideElement = CGPointMake(s,s);
        CGFloat pos1 =  getEaseInOut(800, 321 - scoreControl.frame.size.width, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos1,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos2 =  getEaseInOut(-800,-2, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos2,closeButton.frame.origin.y,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(SCENE_VERTICAL_OFFSET,SCENE_ZOOMEDIN_VERTICAL_OFFSET,animationRatio,animation.duration);
        CGFloat x = self.originInsideElement.x;
        self.originInsideElement = CGPointMake(x, y);
        
    }
    else if (animation.type == ANIMATION_ZOOM_OUT)
    {
        CGFloat s = getEaseInOut(1, SCENE_SCALE, animationRatio,animation.duration);
        self.scaleInsideElement = CGPointMake(s,s);
        CGFloat pos =  getEaseInOut(321 - scoreControl.frame.size.width, 800, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos1 =  getEaseInOut(-2,-800, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos1,closeButton.frame.origin.y,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(SCENE_ZOOMEDIN_VERTICAL_OFFSET
                                 ,SCENE_VERTICAL_OFFSET,animationRatio,animation.duration);
        CGFloat x = self.originInsideElement.x;
        self.originInsideElement = CGPointMake(x, y);
        
    }
    else if (animation.type == ANIMATION_HUE_CHANGE)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        currentHue = getEaseOut(*start, *end, animationRatio);
    }
    
    if (animationRatio > 1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    startOriginPoint = self.originInsideElement;
    if (animation.type == ANIMATION_ZOOM_IN)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:gcHelper selector:@selector(downloadRank) object:nil];
        currentState = STATE_PLAYING;
    }
    else if (animation.type == ANIMATION_ZOOM_OUT)
    {
        currentState = STATE_HOME;
    }
}

-(void)animationEnded:(Animation *)animation
{
    if (animation.type == ANIMATION_START_SCENE)
    {
        [gcHelper loadDefaultLeaderBoard];
        [self showTiles];
        [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
        [rankingControl setCurrentRank:gcHelper.currentRank andTotalRanks:gcHelper.totalRanks];
    }
    if (animation.type == ANIMATION_ZOOM_OUT)
    {
        [self showTiles];
//        [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
        [gcHelper updateScore];
    }
    else if (animation.type == ANIMATION_ZOOM_IN)
    {
        [tileControl togglePlayability:YES];
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
    if (eventData.eventState == 1)
    {
        [gcHelper addScore:currentRoundScore];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
        return;
    }
    currentRoundScore += eventData.score*2;
}


-(void)loadData
{
    currentRoundScore = 0;
    [dictionary reset];
    [tileControl loadDozenLetters:[dictionary generateDozenLetters]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(setScore) object:nil];
    
    isTimerRunning = YES;
    currentRoundScore = 120;
    [scoreControl setValue:currentRoundScore inDuration:0.6];
    [self performSelector:@selector(setScore) withObject:nil afterDelay:1.6];
}

-(void)setScore
{
    currentRoundScore --;
    [scoreControl setValue:currentRoundScore inDuration:0.3];
    if (currentRoundScore <=0)
    {
        [self loadData];
        return;
    }
    [self performSelector:@selector(setScore) withObject:nil afterDelay:1.0];
}

-(void)draw{
    
    if (currentState == STATE_HOME)
    {
        CGFloat hue = 0;
        if (gcHelper.totalRanks > 0)
            hue = (gcHelper.totalRanks - (gcHelper.currentRank - 1))/gcHelper.totalRanks *  0.55;
        
        if (queuedHue != hue)
        {
            Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HUE_CHANGE ofDuration:1 afterDelayInSeconds:0];
            [animation setStartValue:&currentHue OfSize:sizeof(CGFloat)];
            [animation setEndValue:&hue OfSize:sizeof(CGFloat)];
            queuedHue = hue;
        }
    }
    else if (currentState == STATE_PLAYING)
    {
        CGFloat hue = (currentRoundScore/360.0) *  0.85;
        if (hue >= 0.85)
            hue = 0.85;
        
        if (queuedHue != hue)
        {
            Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HUE_CHANGE ofDuration:1 afterDelayInSeconds:0];
            [animation setStartValue:&currentHue OfSize:sizeof(CGFloat)];
            [animation setEndValue:&hue OfSize:sizeof(CGFloat)];
            queuedHue = hue;
        }
    }
    
    UIColor *uiColor = [UIColor colorWithHue:currentHue saturation:0.580551
                                  brightness:0.725500 alpha:1.0];
    
    CGFloat red,green,blue,alpha;
    [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    glClearColor(red,green,blue,alpha);
    
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
        currentState = STATE_HOME;
        playButton.touchable = NO;
        [tileControl hideTiles];
        [tileControl togglePlayability:NO];
        [animator addAnimationFor:self ofType:ANIMATION_ZOOM_OUT ofDuration:0.45 afterDelayInSeconds:0.4];
        [scoreControl setValue:0 inDuration:0.2];
        currentRoundScore = 0;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setScore) object:nil];
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
    [animator addAnimationFor:self ofType:ANIMATION_ZOOM_IN ofDuration:0.45 afterDelayInSeconds:0];
    currentRoundScore = 121;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
}

-(void)userAuthenticated
{
    if (currentState == STATE_SPLASH)
    {
        currentState = STATE_HOME;
        [activityIndictor animate];
    }

}
-(void)scoreDownloaded
{
    [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
    [gcHelper downloadRank];
}

-(void)rankDownloaded
{
    [rankingControl setCurrentRank:gcHelper.currentRank andTotalRanks:gcHelper.totalRanks];
    [gcHelper performSelector:@selector(downloadRank)
                   withObject:nil afterDelay:30];
}

-(void)scoreUpdated
{
    [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
    [gcHelper downloadRank];
}

-(void)userAuthenticationFailed
{
    if (currentState == STATE_SPLASH)
    {
        currentState = STATE_HOME;
        [activityIndictor animate];
    }

}

-(void)defaultLeaderBoardLoaded
{
    [gcHelper updateScore];
}

-(void)activitiyIndicatorFinishedAnimating:(GLActivityIndicator *)activityIndicator;
{
    if (activityIndictor.iteration == 1)
    {
        [gcHelper authenticateUser];
    }
    else if (activityIndictor.iteration == 2)
    {
        [activityIndictor hide];
    }
}
-(void)activityIndicatorDidAappear:(GLActivityIndicator *)activityIndicator
{
    
}
-(void)activityIndicatorDidDisappear:(GLActivityIndicator *)activityIndicator
{
    self.scaleInsideElement = CGPointMake(SCENE_SCALE,SCENE_SCALE);
    self.originInsideElement = CGPointMake(0,SCENE_VERTICAL_OFFSET);
    [animator addAnimationFor:self ofType:ANIMATION_START_SCENE ofDuration:1
          afterDelayInSeconds:0];
}


-(void)dealloc
{
    [gcHelper release];
    [tilesArray release];
    [super dealloc];
}


@end
