//
//  DabbleGCHelper.m
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

@synthesize currentScore;

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
        
        NSLog(@"score : synced %lld current %lld",lastGameCenterScore,currentScore);
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
            if (error == nil)
            {
                isUserAuthenticated = YES;
                [self.delegate userAuthenticated];
            }
            else
            {
                [self.delegate userAuthenticationFailed];
            }
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

-(void)loadDefaultLeaderBoard
{
    [[GKLocalPlayer localPlayer] loadDefaultLeaderboardCategoryIDWithCompletionHandler:((^(NSString *categoryID, NSError *error)
      {
          self.leaderBoardID = categoryID;
          [self.delegate defaultLeaderBoardLoaded];
      }))];
    
}

- (void)updateScore
{
    if (!isUserAuthenticated)
        return;
    if (self.leaderBoardID == nil)
        return;
    
    
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, nil]];
    leaderboardRequest.category = self.leaderBoardID;
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                
            }
            else{
                int64_t highscore = [leaderboardRequest.localPlayerScore value];
                GKScore *scoreReporter = [[GKScore alloc] initWithCategory:self.leaderBoardID];
                scoreReporter.value = (highscore - lastGameCenterScore) + currentScore;
                scoreReporter.context = 0;
                
                [scoreReporter reportScoreWithCompletionHandler:^(NSError *error)
                {
                    if (error == nil)
                    {
                        NSLog(@"%lld",highscore);
                        currentScore = (highscore - lastGameCenterScore) + currentScore;
                        lastGameCenterScore = currentScore;
                        [self updatePrefs];
                        [self.delegate scoreUpdated];
                    }
                    else
                    {
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
    
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObjects:[GKLocalPlayer localPlayer].playerID, nil]]autorelease];
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {

            }
            else{
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
    
    GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] init]autorelease];
    leaderboardRequest.playerScope = GKLeaderboardTimeScopeAllTime;
    
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                
            }
            else{
                int64_t highscore = [leaderboardRequest.localPlayerScore value];
                currentScore = (highscore - lastGameCenterScore) + currentScore;
                lastGameCenterScore = highscore;
                totalRanks = leaderboardRequest.scores.count;
                currentRank = leaderboardRequest.localPlayerScore.rank;
                [self updatePrefs];
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

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    currentScore += score;
    NSLog(@"round score %lld total %lld",score,currentScore);
    [prefs setInteger:currentScore forKey:@"currentScore"];
}

-(void)dealloc
{
    self.leaderBoardID = nil;
    self.delegate = nil;
    [super dealloc];
}

@end
