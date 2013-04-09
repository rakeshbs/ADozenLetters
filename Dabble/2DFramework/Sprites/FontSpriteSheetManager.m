//
//  FontSpriteSheetManager.m
//  Dabble
//
//  Created by Rakesh on 08/04/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "FontSpriteSheetManager.h"
#import "SynthesizeSingleton.h"

static NSString *fontCharactersUpper = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static NSString *fontCharactersLower = @"abcdefghijklmnopqrstuvwxvz";
static NSString *fontCharactersNumbers = @"1234567890:.";


@implementation FontSpriteSheetManager

+(FontSpriteSheetManager *)getSharedFontSpriteSheetManager
{
	static FontSpriteSheetManager *sharedInstance;
	
	@synchronized(self)
	{
		if (!sharedInstance)
		{
			sharedInstance = [[FontSpriteSheetManager alloc]init];
		}
	}
	return sharedInstance;
}

-(void)getFontForCharacter:(NSString *)character withFont:(NSString *)fontName andSize:(CGFloat)size
{
    if ([fontCharactersUpper rangeOfString:character].location != NSNotFound)
    {
        
    }
    else if ([fontCharactersLower rangeOfString:character].location != NSNotFound)
    {
        
    }
    else
    {
        
    }
}

@end
