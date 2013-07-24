//
//  RankingControl.h
//  Dabble
//
//  Created by Rakesh on 24/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"
#import "ScoreControl.h"
#import "GLLabel.h"

@interface RankingControl : GLElement<AnimationDelegate>
{
    ScoreControl *currentRankCounter;
    ScoreControl *totalRanksCounter;
    GLLabel *rankedLabel;
    GLLabel *outOfLabel;
    
    GLRenderer *stringTextureRenderer;
    
    CGRect rankedFrame;
    CGRect outOfFrame;
    

    Color4B textColor;
}

-(void)setColor:(Color4B)_textColor;
-(void)setFont:(NSString *)fontName withSize:(CGFloat)size;
-(void)setCurrentRank:(int)rank andTotalRanks:(int)totalRanks;
@end
