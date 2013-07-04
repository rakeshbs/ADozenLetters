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
    int numberOfWordsMade;
    int numberOfTripletsMade;
    int numberOfDoublesMade;

    NSMutableArray *madeWords;
    NSMutableArray *madeDoubles;
    NSMutableArray *madeTriples;


    
    CGFloat remainingTime;
    int prevTimeLeft;
    CFTimeInterval lastUpdate;
    BOOL isTimerRunning;
    
    TileControl *tileControl;
    
    int currentRoundScore;
    
    
}
@end
