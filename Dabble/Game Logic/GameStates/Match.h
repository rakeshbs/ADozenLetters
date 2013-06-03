//
//  Game.h
//  Dabble
//
//  Created by Rakesh on 24/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCHelper.h"

@interface Match : NSObject
{
    NSString *gcMatchID;
    NSMutableArray *rounds;
}
@property (nonatomic,retain)  NSString *gcMatchID;
@property (nonatomic,retain) NSMutableArray *rounds;

+(Match *)deserialize:(NSData *)data;
-(NSData *)serialize;


@end
