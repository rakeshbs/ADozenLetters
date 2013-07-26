//
//  GameScene.h
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLScene.h"
#import "GLButton.h"
#import "Tile.h"
#import "NSArray+Additions.h"
#import "GCHelper.h"
#import "TileControl.h"
#import "CloseButton.h"
#import "ScoreControl.h"
#import "RankingControl.h"

@interface GameScene : GLScene <AnimationDelegate,CloseButtonDelegate,GCHelperDelegate,GLActivityIndicatorDelegate>
{
    GCHelper *gcHelper;
    
    int scoreCounter;
    int currentRoundScore;
    
    BOOL isTimerRunning;
    CGPoint startOriginPoint;
    
    GLButton *playButton;
    GLButton *scoreButton;
    TileControl *tileControl;
    CloseButton *closeButton;
    ScoreControl *scoreControl;
    ScoreControl *totalScoreControl;
    RankingControl *rankingControl;
    GLElement *fullScreenElement;
    
    GLActivityIndicator *activityIndictor;
    
    int currentState;
    CGFloat currentHue;
    CGFloat queuedHue;

}
@end
