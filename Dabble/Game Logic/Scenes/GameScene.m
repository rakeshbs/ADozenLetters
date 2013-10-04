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

#define SCORECONTROL_TAG 100

#define TOP_BUTTONS_SIZE 80

#define SCORE_PER_WORD 10
#define SCORE_PER_TRIPLET 100

#define ANIMATION_ZOOM_IN 1
#define ANIMATION_ZOOM_OUT 2
#define ANIMATION_HUE_CHANGE 3
#define ANIMATION_START_SCENE 4
#define ANIMATION_SCROLL_LEFT 5
#define ANIMATION_SCROLL_RIGHT 6
#define ANIMATION_SATURATION_CHANGE 7
#define ANIMATION_BRIGHTNESS_CHANGE 8


#define STATE_PLAYING 1
#define STATE_HOME 2
#define STATE_SPLASH 3


#define SCENE_SCALE 0.5f
#define SCENE_VERTICAL_OFFSET 160
#define SCENE_ZOOMEDIN_VERTICAL_OFFSET -20
#define SCENE_MORE_SCROLL_LEFT_LENGTH -320

#define NUMBER_OF_HUES 5

@interface GameScene (Private)
@end

@implementation GameScene

Color4B whiteColor4B = (Color4B){.red = 255, .green = 255, .blue = 255, .alpha=255};
Color4B blackColor4B = (Color4B){.red = 0, .green = 0, .blue = 0, .alpha=255};

CGFloat colorHues[NUMBER_OF_HUES] = {0.603889,0.761,0.013333,0.1230556,0.418889};
CGFloat colorSaturations[NUMBER_OF_HUES] = {0.73,0.553,0.749,0.75,0.904};
CGFloat colorBrightness[NUMBER_OF_HUES] = {0.957,0.851,0.859,0.941,0.616};

Dictionary *dictionary;
-(id)init
{
    if (self = [super init])
    {
        moreScreenShown = NO;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        currentHueIndex = [prefs integerForKey:@"currentHueIndex"];
        firstTimeMadeActive = YES;
        currentHue = colorHues[currentHueIndex];
        currentSaturation = colorSaturations[currentHueIndex];
        currentBrightness = colorBrightness[currentHueIndex];
        
        soundManager = [SoundManager sharedSoundManager];
        [soundManager loadSoundWithKey:@"zoomin" soundFile:@"on_board_zoom_in.aiff"];
        [soundManager loadSoundWithKey:@"zoomout" soundFile:@"on_board_zoom_out.aiff"];
        [soundManager loadSoundWithKey:@"timertick" soundFile:@"timer_beat.aiff"];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeColorHue) name:@"shake" object:nil];
        
        currentState = STATE_SPLASH;
        
        [self performSelectorInBackground:@selector(loadDictionary) withObject:nil];
        
        screenHeight = [[UIScreen mainScreen]bounds].size.height;
        CGFloat moreOffsetY = -SCENE_VERTICAL_OFFSET+screenHeight - 80;
        if (screenHeight > 480)
            moreOffsetY = -SCENE_VERTICAL_OFFSET+screenHeight - 40;
            
        
        moreButton = [[GLImageButton alloc]initWithFrame:CGRectMake(-240, moreOffsetY , 160, 80)];
        moreButton.scaleOfElement = CGPointMake(2.0, 2.0);
        [moreButton setImage:@"more" ofType:@"png"];
        [moreButton setBackgroundColor:(Color4B){0,0,0,64}];
        [moreButton setBackgroundHightlightColor:(Color4B){255,255,255,64}];
        [moreButton setImageHighlightColor:(Color4B){255,255,255,255}];
        [moreButton addTarget:self andSelector:@selector(toggleMoreScreen)];
        [self addElement:moreButton];
        
        
        facebookButton = [[GLImageButton alloc]initWithFrame:CGRectMake(-455, (screenHeight/2) - 400 , 200, 200)];
        facebookButton.scaleOfElement = CGPointMake(2.0, 2.0);
        [facebookButton setImage:@"facebook" ofType:@"png"];
        [facebookButton setBackgroundColor:(Color4B){0,0,0,64}];
        [facebookButton setBackgroundHightlightColor:(Color4B){255,255,255,64}];
        [facebookButton setImageHighlightColor:(Color4B){255,255,255,255}];
        [facebookButton addTarget:self andSelector:@selector(facebookButtonClicked)];
        [self addElement:facebookButton];
        
        ratingButton = [[GLImageButton alloc]initWithFrame:CGRectMake(-695, (screenHeight/2) - 400 , 200, 200)];
        ratingButton.scaleOfElement = CGPointMake(2.0, 2.0);
        [ratingButton setImage:@"rate" ofType:@"png"];
        [ratingButton setBackgroundColor:(Color4B){0,0,0,64}];
        [ratingButton setBackgroundHightlightColor:(Color4B){255,255,255,64}];
        [ratingButton setImageHighlightColor:(Color4B){255,255,255,255}];
        [ratingButton addTarget:self andSelector:@selector(ratingButtonClicked)];
        [self addElement:ratingButton];
        
      /*  emailButton = [[GLImageButton alloc]initWithFrame:CGRectMake(-455, (screenHeight/2) - 265 , 200, 200)];
        emailButton.scaleOfElement = CGPointMake(2.0, 2.0);
        [emailButton setImage:@"email" ofType:@"png"];
        [emailButton setBackgroundColor:(Color4B){0,0,0,64}];
        [emailButton setBackgroundHightlightColor:(Color4B){255,255,255,64}];
        [emailButton setImageHighlightColor:(Color4B){255,255,255,255}];
        [emailButton addTarget:self andSelector:@selector(ratingButtonClicked)];
        [self addElement:emailButton];
        */
        
        logoButton = [[GLImageButton alloc]initWithFrame:CGRectMake(-580, - 560 , 200, 80)];
        logoButton.scaleOfElement = CGPointMake(2.0, 2.0);
        [logoButton setImage:@"logo" ofType:@"png"];
        [logoButton setBackgroundColor:(Color4B){0,0,0,0}];
        [logoButton setBackgroundHightlightColor:(Color4B){255,255,255,0}];
        [logoButton setImageColor:(Color4B){0,0,0,255}];
        [logoButton setImageHighlightColor:(Color4B){255,255,255,255}];
        [logoButton addTarget:self andSelector:@selector(qucentisButtonClicked)];
        [self addElement:logoButton];
        
        scoreControl = [[ScoreControl alloc]initWithFrame:CGRectMake(800, -SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE)];
        
        [scoreControl setFont:@"Lato-Black" withSize:32];
        [scoreControl setTextColor:(Color4B){255,255,255,255}];
        [scoreControl setBackgroundColor:(Color4B){.red = 0,.green = 0, .blue =0,.alpha = 64}];
        [scoreControl setBackgroundHighlightColor:(Color4B){.red = 255,.green = 255, .blue =255,.alpha = 64}];
        [self addElement:scoreControl];
        scoreControl.tag = SCORECONTROL_TAG;
        scoreControl.delegate = self;
        [scoreControl release];
         
        tileControl = [[TileControl alloc]initWithFrame:CGRectMake(-160, 0,self.frame.size.width+320,self.frame.size.height)];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged:)];
        [tileControl release];
        
        scoreButton = [[GLButton alloc]initWithFrame:CGRectMake(-130, -200, 576, 220)];
        [scoreButton setBackgroundColor:(Color4B){.red = 255,.green = 255,.blue = 255,.alpha = 64}];
        [scoreButton setBackgroundHightlightColor:(Color4B){0,0,0,64}];
        [scoreButton addTarget:self andSelector:@selector(enableGameCenter)];
        [self addElement:scoreButton];
        [scoreButton release];
        
        playButton = [[GLButton alloc]initWithFrame:CGRectMake(-130, -520, 576, 250)];
        [playButton setText:@"play" withFont:@"Lato-Bold" andSize:150];
        [playButton addTarget:self andSelector:@selector(playButtonClicked)];
        [playButton setTextColor:(Color4B){255,255,255,255}];
        [playButton setTextHighlightColor:(Color4B){255,255,255,255}];
        [playButton setBackgroundColor:(Color4B){0,0,0,64}];
        [playButton setBackgroundHightlightColor:(Color4B){255,255,255,64}];
        
        [self addElement:playButton];
        playButton.touchable = NO;
        playButton.originOfElement = CGPointMake(0,10);
        [playButton release];
        
        
        
        totalScoreControl = [[ScoreControl alloc]initWithFrame:
                             CGRectMake(-120,-90,546,72)];
        [totalScoreControl setFont:@"Lato-Black" withSize:70];
        [totalScoreControl setFrameBackgroundColor:(Color4B){.red = 128,.green = 128, .blue =128,.alpha = 0}];
        [totalScoreControl setTextColor:(Color4B){.red = 0,.green = 0, .blue =0,.alpha = 180}];
        totalScoreControl.touchable = NO;
        [self addElement:totalScoreControl];
        [totalScoreControl release];
        
        
        closeButton = [[CloseButton alloc]initWithFrame:CGRectMake(-1800, -SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE,
                                                                   TOP_BUTTONS_SIZE, TOP_BUTTONS_SIZE)];
        [self addElement:closeButton];
        [closeButton release];
        closeButton.delegate = self;
        scoreCounter = 0;
        
        rankingControl = [[RankingControl alloc]initWithFrame:CGRectMake(-130, -150, 576, 32)];
        
        [rankingControl setFont:@"Lato-Bold" withSize:30];
        [rankingControl setTextColor:(Color4B){0,0,0,0}];
        [self addElement:rankingControl];
        [rankingControl release];
        
        
        fullScreenElement = [[GLElement alloc]initWithFrame:CGRectMake(-2000, -2000, 4000, 4000)];
        fullScreenElement.touchable = NO;
        fullScreenElement.frameBackgroundColor = (Color4B){0,0,0,255};
        [self addElement:fullScreenElement];
        [fullScreenElement release];
       
        
        [tileControl moveToFront];
        

        activityIndicator = [[GLActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, 320,
                                                                                screenHeight)];
        [self addElement:activityIndicator];
        activityIndicator.delegate = self;
        [activityIndicator release];
        
        gcHelper = [GCHelper getSharedGCHelper];
        gcHelper.delegate = self;
        
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
        CGFloat s = getEaseInOut(SCENE_SCALE, 1.0, animationRatio,animation.duration);
        self.scaleOfElement = CGPointMake(s,s);
        CGFloat pos1 =  getEaseInOut(1800, 321 - scoreControl.frame.size.width, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos1,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos2 =  getEaseInOut(-1800,-2, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos2,closeButton.frame.origin.y,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(SCENE_VERTICAL_OFFSET,SCENE_ZOOMEDIN_VERTICAL_OFFSET,animationRatio,animation.duration);
        CGFloat x = self.originOfElement.x;
        self.originOfElement = CGPointMake(x, y);
        
    }
    else if (animation.type == ANIMATION_ZOOM_OUT)
    {
        CGFloat s = getEaseInOut(1, SCENE_SCALE, animationRatio,animation.duration);
        self.scaleOfElement = CGPointMake(s,s);
        CGFloat pos =  getEaseInOut(321 - scoreControl.frame.size.width, 1800, animationRatio,animation.duration);
        scoreControl.frame = CGRectMake(pos,scoreControl.frame.origin.y,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        CGFloat pos1 =  getEaseInOut(-2,-1800, animationRatio,animation.duration);
        closeButton.frame = CGRectMake(pos1,closeButton.frame.origin.y,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        
        CGFloat y = getEaseInOut(SCENE_ZOOMEDIN_VERTICAL_OFFSET
                                 ,SCENE_VERTICAL_OFFSET,animationRatio,animation.duration);
        CGFloat x = self.originOfElement.x;
        self.originOfElement = CGPointMake(x, y);
        
    }
    else if (animation.type == ANIMATION_HUE_CHANGE)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        currentHue = getEaseOut(*start, *end, animationRatio);
    }
    else if (animation.type == ANIMATION_SATURATION_CHANGE)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        currentSaturation = getEaseOut(*start, *end, animationRatio);
    }
    else if (animation.type == ANIMATION_BRIGHTNESS_CHANGE)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        currentBrightness = getEaseOut(*start, *end, animationRatio);
    }
    else if (animation.type == ANIMATION_SCROLL_LEFT)
    {
        CGFloat scrollX = getEaseOutBack(0, SCENE_MORE_SCROLL_LEFT_LENGTH, animationRatio);
        self.originOfElement = CGPointMake(-scrollX, self.originOfElement.y);
    }
    else if (animation.type == ANIMATION_SCROLL_RIGHT)
    {
        CGFloat scrollX = getEaseOutBack(SCENE_MORE_SCROLL_LEFT_LENGTH, 0, animationRatio);
        self.originOfElement = CGPointMake(-scrollX, self.originOfElement.y);
    }
    if (animationRatio > 1.0)
        return YES;
    return NO;
}

-(void)animationStarted:(Animation *)animation
{
    startOriginPoint = self.originOfElement;
    if (animation.type == ANIMATION_ZOOM_IN)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:gcHelper selector:@selector(updateScore) object:nil];
        currentState = STATE_PLAYING;
        [soundManager playSoundWithKey:@"zoomin"];
        moreButton.touchable = NO;
    }
    else if (animation.type == ANIMATION_ZOOM_OUT)
    {
        currentState = STATE_HOME;
        [soundManager playSoundWithKey:@"zoomout"];
    }
    else if (animation.type == ANIMATION_SCROLL_RIGHT)
    {
        moreButton.touchable = NO;
    }
    else if (animation.type == ANIMATION_SCROLL_LEFT)
    {
        moreButton.touchable = NO;
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
        [self removeElement:fullScreenElement];
    }
    if (animation.type == ANIMATION_ZOOM_OUT)
    {
        [self showTiles];
        moreButton.touchable = YES;
        [tileControl setCharacterVisibility:YES];
        [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
        if (gcHelper.isUserAuthenticated)
            [gcHelper performSelector:@selector(updateScore) withObject:nil afterDelay:0.5];
        else
            [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
    }
    else if (animation.type == ANIMATION_ZOOM_IN)
    {
        
        scoreControl.frame = CGRectMake(321 - scoreControl.frame.size.width,-SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE,
                                        scoreControl.frame.size.width,scoreControl.frame.size.height);
        
        closeButton.frame = CGRectMake(-2,-SCENE_ZOOMEDIN_VERTICAL_OFFSET+screenHeight-TOP_BUTTONS_SIZE,
                                       closeButton.frame.size.width,closeButton.frame.size.height);
        self.scaleOfElement = CGPointMake(1.0,1.0);
        
        self.originOfElement = CGPointMake(self.originOfElement.x, SCENE_ZOOMEDIN_VERTICAL_OFFSET);
        
        [tileControl togglePlayability:YES]; 
        closeButton.touchable = YES;
    }
    else if (animation.type == ANIMATION_SCROLL_RIGHT)
    {
        moreButton.touchable = YES;
        playButton.touchable = YES;
    }
    else if (animation.type == ANIMATION_SCROLL_LEFT)
    {
        moreButton.touchable = YES;
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
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(decrementScore) object:nil];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0];
        return;
    }
    currentRoundScore += eventData.score*2;
}


-(void)loadData
{
    currentRoundScore = 0;
    [dictionary reset];
 //      [tileControl loadDozenLetters:@"TEHWROGDAMRE"];
    [tileControl loadDozenLetters:[dictionary generateDozenLetters]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(decrementScore) object:nil];
    
    isTimerRunning = YES;
    currentRoundScore = 120;
    [scoreControl setValue:currentRoundScore inDuration:0.6];
    secondStartTimeInterval = CFAbsoluteTimeGetCurrent();
    [self performSelector:@selector(decrementScore) withObject:nil afterDelay:1.6];
}

-(void)decrementScore
{
    secondStartTimeInterval = CFAbsoluteTimeGetCurrent();
    currentRoundScore --;
    [scoreControl setValue:currentRoundScore inDuration:0.3];
    if (currentRoundScore <=0)
    {
        [self loadData];
        return;
    }
    if (currentRoundScore < 10)
        [soundManager playSoundWithKey:@"timertick"];
    [self performSelector:@selector(decrementScore) withObject:nil afterDelay:1.0];
}

-(void)draw{
    
    
    if (currentHue > 0)
        currentHue -= (int)(floorf(currentHue));
    
    UIColor *uiColor = [UIColor colorWithHue:currentHue saturation:currentSaturation
                                  brightness:currentBrightness alpha:1.0];
    
    CGFloat red,green,blue,alpha;
    [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    glClearColor(red,green,blue,alpha);
    
}

NSMutableArray *tilesArray;

-(void)sceneMadeActive
{
    [super sceneMadeActive];
    if (firstTimeMadeActive)
    {
        [activityIndicator hide];
        if (gcHelper.gameCenterEnabled)
        {
            [rankingControl setGameCenterState:YES];
            [gcHelper performSelector:@selector(authenticateUser) withObject:nil afterDelay:5.0];
        }
        else
            [rankingControl setGameCenterState:NO];
    }
    else
    {
        if (gcHelper.gameCenterEnabled)
            [gcHelper authenticateUser];
    }
    firstTimeMadeActive = NO;
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
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(decrementScore) object:nil];
    }
}

-(void)enablePlayButton
{
    playButton.touchable = YES;
    
}

-(void)toggleMoreScreen
{
    if (moreScreenShown)
    {
        [animator addAnimationFor:self ofType:ANIMATION_SCROLL_RIGHT ofDuration:0.5 afterDelayInSeconds:0];
    }
    else
    {
        playButton.touchable = NO;
        [animator addAnimationFor:self ofType:ANIMATION_SCROLL_LEFT ofDuration:0.5
              afterDelayInSeconds:0];
    }
    moreScreenShown = !moreScreenShown;
}



-(void)playButtonClicked
{
    playButton.touchable = NO;
    [tileControl rearrangeToTwelveLetters];
    self.originOfElement = CGPointMake(0,180);
    [animator addAnimationFor:self ofType:ANIMATION_ZOOM_IN ofDuration:0.45 afterDelayInSeconds:0];
    currentRoundScore = 121;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
}

-(void)enableGameCenter
{
    [gcHelper enableGameCenter:YES];
    [gcHelper authenticateUserWithGameCenterRedirection];
}

-(void)userAuthenticated
{
    [rankingControl setGameCenterState:YES];
    scoreButton.touchable = NO;
    [gcHelper downloadScore];
}

-(void)userAuthenticationFailed
{
    [gcHelper enableGameCenter:NO];
    [rankingControl setGameCenterState:NO];
    scoreButton.touchable = YES;
}

-(void)authenticateFromApp
{
    
}


-(void)scoreDownloaded
{
    [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
    [gcHelper updateScore];
}

-(void)rankDownloaded
{
    [rankingControl setCurrentRank:gcHelper.currentRank andTotalRanks:gcHelper.totalRanks];
    [gcHelper performSelector:@selector(updateScore)
                   withObject:nil afterDelay:30];
}

-(void)scoreUpdated
{
    [totalScoreControl setValue:gcHelper.currentScore inDuration:0.3];
    [gcHelper downloadRank];
}


-(void)defaultLeaderBoardLoaded
{
    [gcHelper updateScore];
}

-(void)activityIndicatorDidDisappear:(GLActivityIndicator *)_activityIndicator
{
    self.scaleOfElement = CGPointMake(SCENE_SCALE,SCENE_SCALE);
    self.originOfElement = CGPointMake(0,SCENE_VERTICAL_OFFSET);
    [animator addAnimationFor:self ofType:ANIMATION_START_SCENE ofDuration:1
          afterDelayInSeconds:0];
    [self removeElement:_activityIndicator];
    if (currentState == STATE_SPLASH)
    {
        currentState = STATE_HOME;
        
    }
}

-(void)scoreControl:(ScoreControl *)sender withEvent:(int)eventType
{
    if (currentState != STATE_PLAYING)
        return;
    if (sender.tag == SCORECONTROL_TAG)
    {
        if (eventType == SCORECONTROLEVENT_TOUCHDOWN)
        {
           
            double timeDiff = CFAbsoluteTimeGetCurrent() - secondStartTimeInterval;
            pauseResumeTime = 1.0 - timeDiff;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(decrementScore) object:nil];
            [tileControl setCharacterVisibility:NO];
                [tileControl togglePlayability:NO];
            
        }
        else
        {
            if (pauseResumeTime < 0)
                [self decrementScore];
            else
            [self performSelector:@selector(decrementScore) withObject:nil afterDelay:pauseResumeTime];
            [tileControl setCharacterVisibility:YES];
            [tileControl togglePlayability:YES];
        }
    }
}

-(void)changeColorHue
{
    if ([animator getCountOfRunningAnimationsForObject:self ofType:ANIMATION_HUE_CHANGE] > 0)
        return;
    
    currentHueIndex++;
    if (currentHueIndex >= NUMBER_OF_HUES)
        currentHueIndex = 0;
    
    CGFloat hue = colorHues[currentHueIndex];
    if (colorHues[currentHueIndex]<currentHue)
        hue+=1.0;
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_HUE_CHANGE ofDuration:1 afterDelayInSeconds:0];
    [animation setStartValue:&currentHue OfSize:sizeof(CGFloat)];
    [animation setEndValue:&hue OfSize:sizeof(CGFloat)];
    
    Animation *animation2 = [animator addAnimationFor:self ofType:ANIMATION_SATURATION_CHANGE ofDuration:1 afterDelayInSeconds:0];
    [animation2 setStartValue:&currentSaturation OfSize:sizeof(CGFloat)];
    [animation2 setEndValue:&colorSaturations[currentHueIndex] OfSize:sizeof(CGFloat)];
    
    Animation *animation3 = [animator addAnimationFor:self ofType:ANIMATION_BRIGHTNESS_CHANGE ofDuration:1 afterDelayInSeconds:0];
    [animation3 setStartValue:&currentBrightness OfSize:sizeof(CGFloat)];
    [animation3 setEndValue:&colorBrightness[currentHueIndex] OfSize:sizeof(CGFloat)];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:currentHueIndex forKey:@"currentHueIndex"];
}

-(void)facebookButtonClicked
{
    NSString* launchUrl = @"http://www.facebook.com/DozenLetters";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

-(void)ratingButtonClicked
{
    NSString* launchUrl = @"https://itunes.apple.com/us/app/a-dozen-letters/id698206350?ls=1&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

-(void)qucentisButtonClicked
{
    NSString* launchUrl = @"http://www.qucentis.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}


-(void)dealloc
{
    [gcHelper release];
    [tilesArray release];
    [super dealloc];
}


@end
