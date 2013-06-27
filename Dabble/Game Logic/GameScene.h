//
//  GameScene.h
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLScene.h"
#import "Tile.h"
#import "NSArray+Additions.h"
#import "GCHelper.h"
#import "TileControl.h"


@interface GameScene : GLScene
{
    BOOL isServer;
    int currentRandomNumber;
    
    int numberOfWordsMade;
    int numberOfTripletsMade;
    int numberOfDoublesMade;
    int numberOfWordsPerLetter[3];
    
    NSMutableString *resString[3];
    
    NSMutableArray *madeWords;
    NSMutableArray *madeDoubles;
    NSMutableArray *madeTriples;

    
    Texture2D *analyticsTexture;

    
    NSMutableArray *onBoardWords;
     int shouldHighlight[3];
    
    CGFloat remainingTime;
    int prevTimeLeft;
    CFTimeInterval lastUpdate;
    BOOL isTimerRunning;
    
    TileControl *tileControl;
    
    
}
@end
