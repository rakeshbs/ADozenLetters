//
//  SpriteSheet.m
//  GameDemo
//
//  Created by Rakesh BS on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FontSpriteSheet.h"
#import "TextureManager.h"

NSString *fontCharactersUpper = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
NSString *fontCharactersLower = @"abcdefghijklmnopqrstuvwxvz";
NSString *fontCharactersNumbers = @"1234567890:.";

@implementation FontSpriteSheet

-(id)init
{
    if (self = [super init])
    {
        fontSpriteDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;

}

-(void)addFontSprite:(FontSprite *)fontSprite
{
    [fontSpriteDictionary setValue:fontSprite forKey:fontSprite.key];
}



-(void)createTexture
{
    
}

@end
