//
//  Round.m
//  Dabble
//
//  Created by Rakesh on 24/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Round.h"
#import "Dictionary.h"

@implementation PlayerDataPerRound

@synthesize playerID;
@synthesize playedWords;
@synthesize score;
@synthesize numberOfTriplets;
@synthesize numberOfDoubles;
@synthesize numberOfWords;

-(NSMutableDictionary *)serialize
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    
    [data setObject:playerID forKey:@"PlayerID"];
    [data setObject:playedWords forKey:@"PlayedWords"];
    [data setObject:[NSString stringWithFormat:@"%d",score] forKey:@"Score"];
    [data setObject:[NSString stringWithFormat:@"%d",numberOfTriplets] forKey:@"NumTriplets"];
    [data setObject:[NSString stringWithFormat:@"%d",numberOfDoubles] forKey:@"NumDoubles"];
    [data setObject:[NSString stringWithFormat:@"%d",numberOfWords] forKey:@"NumWords"];

    return data;
}

+(PlayerDataPerRound *)deserialize:(NSDictionary *)data
{
    PlayerDataPerRound *p = [[PlayerDataPerRound alloc]init];
    
    p.playerID = data[@"PlayerID"];
    p.playedWords = data[@"PlayedWords"];
    p.score = [data[@"Score"] intValue];
    p.numberOfTriplets = [data[@"NumTriplets"] intValue];
    p.numberOfDoubles = [data[@"NumDoubles"]  intValue];
    p.numberOfWords = [data[@"NumWords"] intValue];
    
    return p;
}


@end

@implementation Round

@synthesize player1Data,player2Data,letters;

-(NSMutableDictionary *)serialize
{
     NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    
    [data setObject:letters forKey:@"letters"];
    [data setObject:[player1Data serialize] forKey:@"Player1Data"];
    [data setObject:[player2Data serialize] forKey:@"Player2Data"];
    
    return data;
}

+(Round *)deserialize:(NSDictionary *)data
{
    Round *round = [[Round alloc]init];
    
    round.letters = data[@"letters"];
    round.player1Data = [PlayerDataPerRound deserialize:data[@"Player1Data"]];
    round.player2Data = [PlayerDataPerRound deserialize:data[@"Player2Data"]];
    
    return round;
}

-(void)startNewRound
{
    Dictionary *dictionary = [Dictionary getSharedDictionary];
    self.letters = [dictionary generateDozenLetters];
}

@end
