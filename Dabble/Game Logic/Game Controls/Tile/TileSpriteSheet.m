//
//  TileSpriteSheet.m
//  Dabble
//
//  Created by Rakesh on 27/07/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "TileSpriteSheet.h"

@implementation TileSprite

-(id)initWithType:(int)tileSpriteType
{
    if (self = [super init])
    {
        self.type = tileSpriteType;
    }
    return self;
}
@end

@implementation TileSpriteSheet

NSString *characters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

-(id)initWithFont:(NSString *)fontName andSize:(int)size
{
    if (self = [super init])
    {
        tilesSprites = [[NSMutableArray alloc]init];
        if ([[UIScreen mainScreen]scale] == 1.0)
        {
            UIFont *font = [UIFont fontWithName:fontName size:size];
            _font = font;
            
            TileSprite *tileSprite;
            for (int i = 0; i < characters.length;i++)
            {
                NSString *str = [characters substringWithRange:NSMakeRange(i, 1)];
                tileSprite = [[TileSprite alloc]initWithType:TILESPRITETYPE_FONT];
                CGSize size = [str sizeWithFont:font];
                tileSprite.width = size.width;
                tileSprite.height = size.height;
                tileSprite.character = str;
                tileSprite.type = TILESPRITETYPE_FONT;
                tileSprite.key = str;
                [tilesSprites addObject:tileSprite];
                [tileSprite release];
            }
            
            UIImage *tileImage = [UIImage imageNamed:@"tile.png"];
            tileSprite = [[TileSprite alloc]initWithType:TILESPRITETYPE_IMAGE];
            tileSprite.image = tileImage;
            tileSprite.width = tileImage.size.width;
            tileSprite.height = tileImage.size.height;
            tileSprite.type = TILESPRITETYPE_IMAGE;
            tileSprite.key = @"tile";
            [tilesSprites addObject:tileSprite];
            [tileSprite release];
            
         /*   UIImage *shadowImage = [UIImage imageNamed:@"shadow.png"];
            tileSprite = [[TileSprite alloc]initWithType:TILESPRITETYPE_IMAGE];
            tileSprite.image = shadowImage;
            tileSprite.width = shadowImage.size.width;
            tileSprite.height = shadowImage.size.height;
            [tilesSprites setObject:tileSprite forKey:@"shadow"];
            [tileSprite release];
           */ 
        }
        else
        {
            UIFont *font = [UIFont fontWithName:fontName size:size * 2];
            _font = font;
            
            TileSprite *tileSprite;
            for (int i = 0; i < characters.length;i++)
            {
                NSString *str = [characters substringWithRange:NSMakeRange(i, 1)];
                tileSprite = [[TileSprite alloc]initWithType:TILESPRITETYPE_FONT];
                CGSize size = [str sizeWithFont:font];
                tileSprite.width = size.width;
                tileSprite.height = size.height;
                tileSprite.character = str;
                tileSprite.key = str;
                tileSprite.type = TILESPRITETYPE_FONT;
                [tilesSprites addObject:tileSprite];
                [tileSprite release];
            }
            
            UIImage *tileImage = [UIImage imageNamed:@"tile@2X.png"];
            tileSprite = [[TileSprite alloc]initWithType:TILESPRITETYPE_IMAGE];
            tileSprite.image = tileImage;
            tileSprite.width = tileImage.size.width;
            tileSprite.height = tileImage.size.height;
            tileSprite.key = @"tile";
            tileSprite.type = TILESPRITETYPE_IMAGE;
            [tilesSprites addObject:tileSprite];
            [tileSprite release];
            
        }
    }
    [self generateSpriteSheet];
    return self;
}

-(void)generateSpriteSheet
{
    CGFloat area = 0;
    
    for (TileSprite *t in tilesSprites.objectEnumerator)
    {
        area += t.height * t.width;
    }
    
    CGFloat squareSide = ceilf(sqrtf(area));
    
    
    int col = 0;
    int row = 0;
    CGFloat lineHeight = 0,lineWidth = 0,totalHeight = 0,totalWidth = 0;
    
    int i = 0;
    for (TileSprite *t in tilesSprites.objectEnumerator)
    {
        
        lineWidth += (t.width+2);
        lineHeight = (lineHeight < t.height) ? t.height:lineHeight;
        
        col++;
        if (lineWidth >= squareSide || i == tilesSprites.count - 1)
        {
            
            totalWidth = (totalWidth < lineWidth) ? lineWidth:totalWidth;
            totalHeight += lineHeight;
            col = 0;
            lineWidth = 0;
            row++;
        }
        i++;
    }

    NSUInteger				width,
    height;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
    
    width = totalWidth;
    i = 0;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
            i *= 2;
		width = i;
	}
	height = totalHeight;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
            i *= 2;
		height = i;
	}
    
    
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width );
	context = CGBitmapContextCreateWithData(data, width, height, 8, width ,
                                            colorSpace, kCGImageAlphaNone,nil,nil);
	CGColorSpaceRelease(colorSpace);
	CGContextSetGrayFillColor(context, 1.0, 1.0);

    
    CGContextTranslateCTM(context, 0.0, height);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    lineHeight = 0,lineWidth = 0,totalHeight = 0,totalWidth = 0,col = 0;
    
    UIGraphicsPushContext(context);
    
    i = 0;
    
    for (TileSprite *t in tilesSprites.objectEnumerator)
    {
        
        CGContextTranslateCTM(context, lineWidth, totalHeight);
        if (t.type == TILESPRITETYPE_FONT)
        {
            [t.character drawInRect:CGRectMake(0, 0, t.width, t.height) withFont:self.font lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentCenter];
        }
        else if (t.type == TILESPRITETYPE_IMAGE)
        {
            CGImageRef imageRef = t.image.CGImage;
            CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);

        }
        CGContextTranslateCTM(context, -lineWidth, -totalHeight);
        
        Sprite *s = [[Sprite alloc]init];
        
        s.offSetX = lineWidth;
        s.offSetY = totalHeight;
        s.width = t.width;
        s.height = t.height;
        s.key = t.key;
        s.spriteSheet = self;
        
        [self addSprite:s];
        [s release];
        
        lineWidth += (t.width+2);
        lineHeight = (lineHeight < t.height) ? t.height:lineHeight;
        
        col++;
        if (lineWidth >= squareSide || i == tilesSprites.count - 1)
        {
            totalWidth = (totalWidth < lineWidth) ? lineWidth:totalWidth;
            totalHeight += lineHeight;
            col = 0;
            lineWidth = 0;
            row++;
        }
        
        t.image = nil;
        t.character = nil;
        i++;
    }
    
    [tilesSprites release];
    
    /*CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage* image = [[UIImage alloc] initWithCGImage:imageRef];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png",self.hash]]; //Add the file name
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]; //Write the file
    */
    
    self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:CGSizeMake(totalWidth, totalHeight)];
	
    [self calculateCoordinates];
    
	CGContextRelease(context);
	free(data);

}



@end
