//
//  DabbleGCHelper.m
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "DabbleGCHelper.h"

@implementation DabbleGCHelper

-(id)init
{
    if (self = [super init])
    {
        gcHelper = [GCTurnBasedMatchHelper sharedInstance];
        gcHelper.delegate = self;
    }
    return self;
}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    
}
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    
}
- (void)takeTurn:(GKTurnBasedMatch *)match
{
    
}
- (void)recieveEndGame:(GKTurnBasedMatch *)match
{
    
}
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
    
}

- (void)presentGCTurnViewController:(UIViewController *)parent
{
    [gcHelper authenticateLocalUser];
    [gcHelper
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:parent];
}


@end
