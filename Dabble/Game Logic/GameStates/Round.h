//
//  Round.h
//  Dabble
//
//  Created by Rakesh on 24/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerDataPerRound : NSObject
{
    NSString *playerID;
    NSMutableArray *playedWords;

    int score;
    int numberOfTriplets;
    int numberOfDoubles;
    int numberOfWords;
}

@property (nonatomic,retain) NSString *playerID;
@property (nonatomic,retain) NSMutableArray *playedWords;
@property (nonatomic) int score;
@property (nonatomic) int numberOfTriplets;
@property (nonatomic) int numberOfDoubles;
@property (nonatomic) int numberOfWords;

+(PlayerDataPerRound *)deserialize:(NSDictionary *)data;
-(NSMutableDictionary *)serialize;

@end

@interface Round : NSObject
{
    NSString *letters;
    PlayerDataPerRound *player1Data;
    PlayerDataPerRound *player2Data;
}

@property (nonatomic,retain) NSString *letters;
@property (nonatomic,retain) PlayerDataPerRound *player1Data;
@property (nonatomic,retain) PlayerDataPerRound *player2Data;

+(Round *)deserialize:(NSDictionary *)data;
-(NSMutableDictionary *)serialize;

@end
