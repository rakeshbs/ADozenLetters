//
//  DabbleGCHelper.h
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#import "Match.h"

@protocol GCHelperDelegate
-(void)userAuthenticated;
-(void)scoreDownloaded;
-(void)scoreUpdated;
-(void)userAuthenticationFailed;
-(void)defaultLeaderBoardLoaded;
@end

@interface GCHelper : NSObject
{
    BOOL isUserAuthenticated;
    NSMutableArray *matches;
    
    int64_t lastGameCenterScore;
    int64_t currentScore;
    int64_t currentRank;
    int64_t totalRanks;
}

@property (nonatomic,retain) NSString *leaderBoardID;
@property (nonatomic,readonly)     int64_t currentScore;
@property (nonatomic,assign) NSObject<GCHelperDelegate> *delegate;


+(GCHelper *)getSharedGCHelper;
-(void)loadDefaultLeaderBoard;
-(void)authenticateUser;
-(void)downloadScore;
- (void)updateScore;
-(void)downloadRank;
-(void)addScore:(int64_t)score;
@end
