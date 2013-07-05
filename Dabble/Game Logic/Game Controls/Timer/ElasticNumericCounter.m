//
//  ElasticCounter.m
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "ElasticNumericCounter.h"

@implementation ElasticNumericCounter

@synthesize sequence;

-(id)initWithFrame:(CGRect)_frame
{
    if (self = [super initWithFrame:_frame])
    {
        currentValue = 0;
    }
    return self;
}

-(void)setFont:(NSString *)font withSize:(CGFloat)size
{
    fontSpriteSheet = [fontSpriteSheetManager getFontSpriteSheetOfType:FontSpriteTypeNumbers withFont:font andSize:size];
}

-(void)setValue:(int)value
{
    
}

-(void)draw
{
    int currentIndex = verticalOffset/frame.size.height;


}

-(CGRect)getPreviousRect:(int)currentIndex
{
    int index = (currentIndex - 1 + sequence.count)%sequence.count;
    CGFloat offsetY = verticalOffset - currentIndex * frame.size.height;
    
    previousFontSprite = [fontSpriteSheet getFontSprite:sequence[index]];
    
    CGRect offsetFrame = CGRectOffset(self.frame, 0, offsetY);
    CGRect offsetFontSpriteFrame = CGRectOffset(previousFontSprite.textureCGRect, 0, -self.frame.size.height);
    
    CGRect fontSpriteInterSection = CGRectIntersection(offsetFontSpriteFrame,offsetFrame);
    
}


@end
