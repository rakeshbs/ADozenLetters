//
//  TextureManager.h
//  MusiMusi
//
//  Created by Rakesh BS on 9/4/09.
//  Copyright 2009 Qucentis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"

@interface TextureManager : NSObject {
	NSMutableDictionary *texture_dictionary;
	NSArray *paths;
}

+(TextureManager *)getSharedTextureManager;
-(Texture2D *)getTexture:(NSString *)texture_name OfType:(NSString *)type;
-(void)delete_Texture:(NSString *)texture_name;

-(Texture2D *)getStringTexture:(NSString *)texture_name;
-(Texture2D *)getStringTexture:(NSString *)string dimensions:(CGSize)cgSize
           horizontalAlignment:(UITextAlignment)alignment verticalAlignment:(UITextVerticalAlignment)vAlignment
					  fontName:(NSString *)font
					  fontSize:(int)size;
-(Texture2D *)getLayeredStringTexture:(NSMutableArray *)strings :(NSString *)_key;
@end
