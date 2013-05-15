//
//  GameScene.h
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Scene.h"
#import "Tile.h"
#import "NSArray+Additions.h"
#import "DabbleGCHelper.h"

@interface GameScene : Scene
{
    BOOL isServer;
    int currentRandomNumber;
    
    int numberOfWordsMade;
    int numberOfTripletsMade;
    int numberOfDoublesMade;
    int numberOfWordsPerLetter[3];
    
    NSString *charArray1[3];
    NSString *charArray2[4];
    NSString *charArray3[5];
    NSMutableString *resString[3];
    
    NSMutableArray *madeWords;
    NSMutableArray *madeDoubles;
    NSMutableArray *madeTriples;

    
    Texture2D *analyticsTexture;

    TextureRenderUnit *analyticsTextureRenderUnit;
    TextureRenderUnit *timerTextureRenderUnit;
    
    NSMutableArray *onBoardWords;
     int shouldHighlight[3];
    
    CGFloat remainingTime;
    int prevTimeLeft;
    CFTimeInterval lastUpdate;
    BOOL isTimerRunning;
    
    DabbleGCHelper *gcHelper;
    
}
@end
