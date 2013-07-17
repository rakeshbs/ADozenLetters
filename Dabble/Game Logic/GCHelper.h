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


@interface GCHelper : NSObject
{
    BOOL isUserAuthenticated;
    NSMutableArray *matches;
}

@end
