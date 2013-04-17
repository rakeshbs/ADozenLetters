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
static NSString *fontCharactersNumbers = @"1234567890";


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

-(id)init
{
    if (self = [super init])
    {
        dictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(FontSprite *)getFontForCharacter:(NSString *)character withFont:(NSString *)fontName andSize:(CGFloat)size
{
    FontSpriteType type = -1;
    if ([fontCharactersUpper rangeOfString:character].location != NSNotFound)
    {
        type = FontSpriteTypeAlphabetsUppercase;
    }
    else if ([fontCharactersLower rangeOfString:character].location != NSNotFound)
    {
        type = FontSpriteTypeAlphabetsLowerCase;
    }
    else
    {
        type = FontSpriteTypeNumbers;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@:%d:%f",fontName,type,size];
    
    FontSpriteSheet *fSheet = dictionary[key];
    
    
    if (fSheet != nil) {
        return [fSheet getFontSprite:character];
    }
    else
    {
        fSheet = [[FontSpriteSheet alloc]initWithType:type andFontName:fontName andFontSize:size];
        [dictionary setObject:fSheet forKey:key];
    }
    return [fSheet getFontSprite:character];
    
}

@end
