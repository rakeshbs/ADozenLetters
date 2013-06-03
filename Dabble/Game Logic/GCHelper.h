//
//  DabbleGCHelper.h
//  Dabble
//
//  Created by Rakesh on 07/05/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCTurnBasedMatchHelper.h"


@interface DabbleGCHelper : NSObject <GCTurnBasedMatchHelperDelegate>
{
    GCTurnBasedMatchHelper *gcHelper;
}

- (void)presentGCTurnViewController:(UIViewController *)parent;
@end
