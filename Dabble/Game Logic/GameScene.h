//
//  GameScene.h
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Scene.h"
#import "Square.h"
#import "GCHelper.h"
#import "NSArray+Additions.h"

@interface GameScene : Scene <GCHelperDelegate>
{
    GCHelper *gcHelper;
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
    StringTextureShader *analyticsShader;
    NSMutableArray *onBoardWords;
    
}
@end
