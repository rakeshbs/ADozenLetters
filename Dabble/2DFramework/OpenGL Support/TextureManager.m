//
//  TextureManager.m
//  MusiMusi
//
//  Created by Rakesh BS on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextureManager.h"

@interface TextureManager (Private)
-(Texture2D *)loadTexture:(NSString *)texture_name fromPath:(NSString *)path;
@end


@implementation TextureManager

+(TextureManager *)getSharedTextureManager
{
	static TextureManager *sharedInstance;
	
	@synchronized(self)
	{
		if (!sharedInstance)
		{
			sharedInstance = [[TextureManager alloc]init];
		}
	}
	return sharedInstance;
}

-(id)init
{
	if (self = [super init])
	{
		texture_dictionary = [[NSMutableDictionary alloc]init];
		paths = [[NSArray alloc]initWithObjects:@"",nil];
	}
	return self;
}

-(Texture2D *)loadTexture:(NSString *)texture_name fromPath:(NSString *)path
{
	NSString *imgPath = [[NSBundle mainBundle]resourcePath];
	imgPath = [imgPath stringByAppendingFormat:@"/%@/%@",path,texture_name];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL exists = [fileManager isReadableFileAtPath:imgPath];
	if (exists)
	{
		return [[Texture2D alloc]initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
		
	}
	return nil;
}

-(Texture2D *)getStringTexture:(NSString *)string dimensions:(CGSize)cgSize
           horizontalAlignment:(UITextAlignment)alignment verticalAlignment:(UITextVerticalAlignment)vAlignment
					  fontName:(NSString *)font
					  fontSize:(int)size
{
    NSString *key = [NSString stringWithFormat:@"%@%d%@%d%f%f",string,size,font,alignment,cgSize.width,cgSize.height];
    
	if ([texture_dictionary objectForKey:key] != nil)
	{
		return (Texture2D *)[texture_dictionary objectForKey:key];
	}
	else
	{
		Texture2D *tex = [[Texture2D alloc]initWithString:string
											   dimensions:cgSize 
												horizontalAlignment:alignment verticalAlignment:vAlignment
												 fontName:font
												 fontSize:size];
		
		if (tex != nil)
		{
			[texture_dictionary setObject:tex forKey:key];
            [tex release];
			return tex;
		}
	}
	return nil;
}

-(Texture2D *)getStringTexture:(NSString *)texture_name
{
	if ([texture_dictionary objectForKey:texture_name] != nil)
	{
		return (Texture2D *)[texture_dictionary objectForKey:texture_name];
	}
	else
	{
		Texture2D *tex = [[Texture2D alloc]initWithString:texture_name
											   dimensions:CGSizeMake(200,30) 
												horizontalAlignment:UITextAlignmentCenter verticalAlignment:UITextAlignmentMiddle
												 fontName:@"Arial-BoldMT"
												 fontSize:16];
	
		if (tex != nil)
		{
			[texture_dictionary setObject:tex forKey:texture_name];
            [tex release];
			return tex;
		}
	}
	return nil;
}

-(Texture2D *)getTexture:(NSString *)texture_name
{
	if ([texture_dictionary objectForKey:texture_name] != nil)
	{
		return (Texture2D *)[texture_dictionary objectForKey:texture_name];
	}
	else
	{
		for(NSString *p in paths)
		{
			Texture2D *tex = [self loadTexture:texture_name fromPath:p];
			if (tex != nil)
			{
				[texture_dictionary setObject:tex forKey:texture_name];
				return tex;
			}
		}
	}
	return nil;
}
-(void)delete_Texture:(NSString *)texture_name
{
	[texture_dictionary removeObjectForKey:texture_name];
}

@end
