//
//  Game.m
//  Dabble
//
//  Created by Rakesh on 24/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Match.h"
#import "Round.h"

@implementation Match

@synthesize rounds,gcMatchID;

+(Match *)deserialize:(NSData *)data
{
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    Match *game = [[Match alloc]init];
    
    for (int i = 0;i < array.count;i++)
    {
        Round *r = [Round deserialize:array[i]];
        [game.rounds addObject:r];
    }
    
    return game;
}

-(NSData *)serialize
{
    NSMutableArray *data = [[NSMutableArray alloc]init];
    
    for (Round *r in rounds)
        [data addObject:[r serialize]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    return jsonData;
}


@end
