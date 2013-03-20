//
//  TextureManager.h
//  MusiMusi
//
//  Created by Rakesh BS on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"

@interface TextureManager : NSObject {
	NSMutableDictionary *texture_dictionary;
	NSArray *paths;
}

+(TextureManager *)getSharedTextureManager;
-(Texture2D *)getTexture:(NSString *)texture_name;
-(void)delete_Texture:(NSString *)texture_name;
/*
-(Texture2D *)getStringTexture:(NSString *)texture_name;
-(Texture2D *)getStringTexture:(NSString *)string dimensions:(CGSize)cgSize
					 alignment:(UITextAlignment)alignment 
					  fontName:(NSString *)font
					  fontSize:(int)size;*/
@end