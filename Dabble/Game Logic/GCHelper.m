//
//  DabbleGCHelper.m
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

@synthesize currentScore,currentRank,totalRanks,isUserAuthenticated,gameCenterEnabled;

+(GCHelper *)getSharedGCHelper
{
    static GCHelper *sharedGCHelper;
    @synchronized(self)
    {
        if (sharedGCHelper == nil)
        {
            sharedGCHelper = [[GCHelper alloc]init];
        }
    }
    return sharedGCHelper;
}

-(id)init
{
    if (self = [super init])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        lastGameCenterScore = [prefs integerForKey:@"lastGameCenterScore"];
        currentScore = [prefs integerForKey:@"currentScore"];
        currentRank = [prefs integerForKey:@"currentRank"];
        totalRanks = [prefs integerForKey:@"totalRanks"];
        gameCenterEnabled = [prefs integerForKey:@"gameCenterEnabled"];
    }
    return self;
}

-(void)enableGameCenter:(BOOL)enabled
{
    gameCenterEnabled = enabled;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:gameCenterEnabled forKey:@"gameCenterEnabled"];
}

-(void)authenticateUserWithGameCenterRedirection
{
    redirectToGameCenter = YES;
    if (!gameCenterEnabled)
        return;
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer
         authenticateWithCompletionHandler:^(NSError * error)
        {
            if (error == nil)
            {
                isUserAuthenticated = YES;
                [self.delegate userAuthenticated];
            }
            else
            {
                [self.delegate userAuthenticationFailed];
                if (error.code == 2)
                {
                    if (redirectToGameCenter)
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
                }
                redirectToGameCenter = NO;
            }
        }
         ];
    }
    else
    {
        isUserAuthenticated = YES;
    }
}

-(void)authenticateUser
{
        NSLog(@"authenticateUser");
    if (!gameCenterEnabled)
        return;
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer
         authenticateWithCompletionHandler:^(NSError * error)
         {
             if (error == nil)
             {
                 isUserAuthenticated = YES;
                 [self.delegate userAuthenticated];
             }
             else
             {
                 NSLog(@"%@",error);
                 [self.delegate userAuthenticationFailed];
             }
         }
         ];
    }
    else
    {
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

-(void)loadDefaultLeaderBoard
{
    self.leaderBoardID = @"HighScore";
    [self.delegate defaultLeaderBoardLoaded];
}

- (void)updateScore
{
    if (!isUserAuthenticated)
        return;
    if (self.leaderBoardID == nil)
        return;
    
    NSLog(@"starting update score");
    
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, nil]]autorelease];
    leaderboardRequest.category = self.leaderBoardID;
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                
            }
            else{
                int64_t highscore = [leaderboardRequest.localPlayerScore value];
                GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:self.leaderBoardID]autorelease];
                scoreReporter.value = (highscore - lastGameCenterScore) + currentScore;
                NSLog(@"%lld %lld",scoreReporter.value,currentScore);
                scoreReporter.context = 0;
                    NSLog(@"getting updated score");
                
                [scoreReporter reportScoreWithCompletionHandler:^(NSError *error)
                {
                    if (error == nil)
                    {
                        currentScore = (highscore - lastGameCenterScore) + currentScore;
                        lastGameCenterScore = currentScore;
                        [self updatePrefs];
                        [self.delegate scoreUpdated];
                        NSLog(@"updated score");
                    }
                    else
                    {
                           NSLog(@"Leader Board Error %@",[error localizedDescription]);
                        [self.delegate scoreUpdated];
                    }
                    
                }];
            }
        }];
    }
    
   
}

-(void)downloadScore
{
    if (!isUserAuthenticated)
        return;
    if (self.leaderBoardID == nil)
        return;
    
                        NSLog(@"downloading updated score");
    
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, nil]]autorelease];
        leaderboardRequest.category = self.leaderBoardID;
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                    NSLog(@"Leader Board Error %@",[error localizedDescription]);
            }
            else{
                
                NSLog(@"downloaded updated score");
                int64_t highscore = [leaderboardRequest.localPlayerScore value];
                currentScore = (highscore - lastGameCenterScore) + currentScore;
                lastGameCenterScore = highscore;
                [self.delegate scoreUpdated];
                [self updatePrefs];
            }
        }];
    }
}

-(void)downloadRank
{
    if (!isUserAuthenticated)
        return;
    if (self.leaderBoardID == nil)
        return;
    
     NSLog(@"downloading rank");
    
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] init]autorelease];
    leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
    leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.category = self.leaderBoardID;
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                NSLog(@"Leader Board Error %@",[error localizedDescription]);
            }
            else{
                 NSLog(@"downloaded updated rank");
                totalRanks = leaderboardRequest.maxRange;
                currentRank = leaderboardRequest.localPlayerScore.rank;
                [self updatePrefs];
                [self.delegate rankDownloaded];
            }
        }];
    }
}

-(void)updatePrefs
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:currentScore forKey:@"currentScore"];
    [prefs setInteger:lastGameCenterScore forKey:@"lastGameCenterScore"];
    [prefs setInteger:totalRanks forKey:@"totalRanks"];
    [prefs setInteger:currentRank forKey:@"currentRank"];
}

-(void)addScore:(int64_t)score
{
    currentScore += score;
    [self updatePrefs];
}

-(void)dealloc
{
    self.leaderBoardID = nil;
    self.delegate = nil;
    [super dealloc];
}

@end
