//
//  SpriteSheet.h
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "GLCommon.h"

@interface FontSprite : NSObject
@property (nonatomic,retain) NSString *key;
@property (nonatomic) CGFloat offSetX;
@property (nonatomic) CGFloat offSetY;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@end

@interface FontSpriteSheet : NSObject {
	Texture2D *fontSpriteSheet;
    NSDictionary *fontSpriteDictionary;
    

}

@property (nonatomic,retain) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic,retain) UIColor* fontColor;

-(void)addFontSprite:(FontSprite *)fontSprite;
@end