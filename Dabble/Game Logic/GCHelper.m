//
//  DabbleGCHelper.m
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

-(id)init
{
    if (self = [super init])
    {
        matches = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)authenticateUser
{
    
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [[GKLocalPlayer localPlayer]
         authenticateWithCompletionHandler:^(NSError * error)
        {
            isUserAuthenticated = YES;
        }
         ];
    }
    else
    {
        NSLog(@"Already authenticated!");
                    isUserAuthenticated = YES;
    }
}

-(void)addNewMatch:(Match *)match
{
    if (!isUserAuthenticated)
        return;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    
    request.maxPlayers = 2;
    request.minPlayers = 2;
    
    [matches addObject:match];
    
    [GKTurnBasedMatch findMatchForRequest:request withCompletionHandler:^(GKTurnBasedMatch *gcMatch, NSError *error)
     {
        
        if (error)
        {
            NSLog(@"%@", error.localizedDescription );
            
        } else
        {
            match.gcMatchID = gcMatch.matchID;
        }
    }];
}

-(void)loadMatches
{
    [matches removeAllObjects];
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:
     ^(NSArray *gcMatches, NSError *error)
     {
         for (GKTurnBasedMatch *gcMatch in gcMatches)
         {
             Match *m = [Match deserialize:gcMatch.matchData];
             [matches addObject:m];
         }
     }];
}

@end
