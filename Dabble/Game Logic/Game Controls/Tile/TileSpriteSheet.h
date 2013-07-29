//
//  TileSpriteSheet.h
//  Dabble
//
//  Created by Rakesh on 27/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GLElement.h"

#define TILESPRITETYPE_IMAGE 1
#define TILESPRITETYPE_FONT 2


@interface TileSprite : NSObject

@property (nonatomic) int type;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) NSString *character;

-(id)initWithType:(int)tileSpriteType;

@end

@interface TileSpriteSheet : SpriteSheet
{
    NSMutableArray *tilesSprites;
}

@property (nonatomic,readonly) UIFont *font;

-(void)generateSpriteSheet;
-(id)initWithFont:(NSString *)fontName andSize:(int)size;

@end
