//
//  TextureString.h
//  Dabble
//
//  Created by Rakesh on 30/03/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"


@interface TextureString : NSObject

@property (nonatomic,retain) NSString *string;
@property (nonatomic) UITextAlignment horizontalTextAlignment;
@property (nonatomic) UITextVerticalAlignment verticalTextAlignment;
@property (nonatomic) CGSize dimensions;
@property (nonatomic,retain) NSString *fontName;
@property (nonatomic) CGFloat fontSize;

@end
