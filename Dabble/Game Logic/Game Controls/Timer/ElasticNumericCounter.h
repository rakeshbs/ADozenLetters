//
//  ElasticCounter.h
//  Dabble
//
//  Created by Rakesh on 04/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

@interface ElasticNumericCounter : GLElement
{
    FontSpriteSheet *fontSpriteSheet;
    NSMutableArray *sequence;
    
    int currentValue;
    
    CGFloat verticalOffset;
    
    FontSprite *previousFontSprite;
    FontSprite *currentFontSprite;
    FontSprite *nextFontSprite;
    
}

@property (nonatomic,retain) NSMutableArray *sequence;

-(void)setValue:(int)value;
-(void)setFont:(NSString *)font withSize:(CGFloat)size;

@end
