//
//  RankingControl.m
//  Dabble
//
//  Created by Rakesh on 24/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "RankingControl.h"

#define ANIMATION_ALIGN 1
#define ANIMATION_CENTER 2

@implementation RankingControl

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        textColor = (Color4B){255,255,255,255};
    }
    return self;
}

-(int)numberOfLayers
{
    return 1;
}

-(void)setColor:(Color4B)_textColor
{
    textColor = _textColor;
    [totalRanksCounter setTextColor:_textColor];
    [rankedLabel setTextColor:_textColor];
    [currentRankCounter setTextColor:_textColor];
    [outOfLabel setTextColor:_textColor];
}

-(void)setFont:(NSString *)fontName withSize:(CGFloat)size
{
    if (subElements.count > 0)
    {
        [subElements removeAllObjects];
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGSize rankedSize = [@"ranked  " sizeWithFont:font];
    CGSize outOfSize = [@"  out of " sizeWithFont:font];
    
    CGFloat widthLeft = self.frame.size.width - (rankedSize.width + outOfSize.width);
    
    currentRankCounter = [[ScoreControl alloc]initWithFrame:CGRectMake(rankedSize.width, 0, widthLeft/2, frame.size.height)];
    
    [currentRankCounter setFont:fontName withSize:size];
    [currentRankCounter setTextAlignment:UITextAlignmentRight];
    [currentRankCounter setTextColor:textColor];
    
    totalRanksCounter = [[ScoreControl alloc]initWithFrame:
                         CGRectMake(frame.size.width - widthLeft/2, 0,widthLeft/2,frame.size.height)];
    [totalRanksCounter setFont:fontName withSize:size];
    [totalRanksCounter setTextAlignment:UITextAlignmentLeft];
    [totalRanksCounter setTextColor:textColor];
    
    [self addElement:currentRankCounter];
    [self addElement:totalRanksCounter];
    [currentRankCounter release];
    [totalRanksCounter release];
    
    [currentRankCounter setValue:0 inDuration:0];
    
    CGFloat width = [currentRankCounter getVisibleWidth];
    CGFloat posx = currentRankCounter.frame.origin.x + currentRankCounter.frame.size.width - width;
    posx -= rankedSize.width ;

    rankedLabel = [[GLLabel alloc]initWithFrame:
                   CGRectMake(posx, -3,rankedSize.width,rankedSize.height)];
    [rankedLabel setFont:fontName andSize:size];
    [rankedLabel setText:@"ranked  " withAlignment:UITextAlignmentLeft];
    [rankedLabel setTextColor:textColor];
    [self addElement:rankedLabel];
    [rankedLabel release];
    
    outOfLabel = [[GLLabel alloc]initWithFrame:
                   CGRectMake(self.frame.size.width - widthLeft/2 - outOfSize.width, -3,
                              outOfSize.width,                                                           outOfSize.height)];
    [outOfLabel setFont:fontName andSize:size];
    [outOfLabel setText:@"  out of " withAlignment:UITextAlignmentRight];
    [outOfLabel setTextColor:textColor];
    [self addElement:outOfLabel];
    [outOfLabel release];
    
    [rankedLabel moveToFront];
    [outOfLabel moveToFront];
}


-(BOOL)animationUpdate:(Animation *)animation
{
    CGFloat animatedRatio = [animation getAnimatedRatio];
    
    if (animation.type == ANIMATION_ALIGN)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        CGFloat pos = getEaseOut(*start, *end, animatedRatio);
        rankedLabel.frame = CGRectMake(pos, rankedLabel.frame.origin.y, rankedLabel.frame.size.width, rankedLabel.frame.size.height);
    }
    else if (animation.type == ANIMATION_CENTER)
    {
        CGFloat *start = [animation getStartValue];
        CGFloat *end = [animation getEndValue];
        CGFloat off = getEaseOut(*start, *end, animatedRatio);
        self.originInsideElement = CGPointMake(off,0);
    }
    if (animatedRatio >= 1.0)
        return YES;
    return NO;
}

-(void)setCurrentRank:(int)rank andTotalRanks:(int)totalRanks
{
    [currentRankCounter setValue:rank inDuration:0.3];
    [totalRanksCounter setValue:totalRanks inDuration:0.3];
    
    CGFloat width = [currentRankCounter getVisibleWidth];
    CGFloat posx = currentRankCounter.frame.origin.x + currentRankCounter.frame.size.width - width;
    posx -= rankedLabel.frame.size.width;
    
    Animation *animation = [animator addAnimationFor:self ofType:ANIMATION_ALIGN ofDuration:0.3 afterDelayInSeconds:0];
    CGFloat startPos = rankedLabel.frame.origin.x;
    [animation setStartValue:&startPos OfSize:sizeof(float)];
    [animation setEndValue:&posx OfSize:sizeof(float)];
    
    
    CGFloat totalWidth =   (width - [totalRanksCounter getVisibleWidth])/2;
    CGFloat oldOffset = self.originInsideElement.x;
    
    Animation *animation1 = [animator addAnimationFor:self ofType:ANIMATION_CENTER ofDuration:0.3 afterDelayInSeconds:0];
    [animation1 setStartValue:&oldOffset OfSize:sizeof(float)];
    [animation1 setEndValue:&totalWidth OfSize:sizeof(float)];
    
    
}

@end
