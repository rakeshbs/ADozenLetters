//
//  GameScene.m
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GameScene.h"
#import "Dictionary.h"
#import "NSArray+Additions.h"

#define yOffset 75

#define totalTimePerGame 122

@interface GameScene (Private)
@end

@implementation GameScene

Color4B whiteColor4B = (Color4B){.red = 255, .green = 255, .blue = 255, .alpha=255};
Color4B blackColor4B = (Color4B){.red = 0, .green = 0, .blue = 0, .alpha=255};


Dictionary *dictionary;
-(id)init
{
    if (self = [super init])
    {
        
        
        currentRandomNumber =  arc4random()+1;
        
        numberOfTripletsMade = 0;
        numberOfDoublesMade = 0;
        numberOfWordsMade = 0;
        for (int i = 0;i<3;i++)
            numberOfWordsPerLetter[i] = 0;
        
        analyticsTexture = [[Texture2D alloc]
                            initWithString:@"W : 0 (0,0,0) D : 0 T : 0"                                                 dimensions:CGSizeMake(320, 30)
                            horizontalAlignment:UITextAlignmentLeft
                            verticalAlignment:UITextAlignmentMiddle
                            fontName:@"Lato" fontSize:30];
        
    
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];
        onBoardWords = [[NSMutableArray alloc]init];
        madeTriples = [[NSMutableArray alloc]init];
        madeDoubles = [[NSMutableArray alloc]init];
        
        
        remainingTime = totalTimePerGame;
        [self loadDictionary];
        
        tileControl = [[TileControl alloc]init];
        [self addElement:tileControl];
        [tileControl addTarget:self andSelector:@selector(tileRearranged)];
        
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

        
        
    }
    return  self;
}

-(void)loadDictionary
{
    dictionary = [Dictionary getSharedDictionary];
}

-(void)tileRearranged
{
    NSLog(@"%@",tileControl.concatenatedWords);
    
}



-(void)loadData
{
    tileControl.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
    
    
    [tileControl createTiles:[dictionary generateDozenLetters]];
    
    //[tileControl createTiles:@"XYZ"];
    
    remainingTime = totalTimePerGame;
    lastUpdate = CFAbsoluteTimeGetCurrent();
    prevTimeLeft=totalTimePerGame;
    isTimerRunning = YES;
    [self update];
}


-(void)draw{
    Color4B color;
	color.red =241;
	color.blue = 196;
	color.green = 15;
	color.alpha = 255;
    [director clearScene:color];
}

-(void)tileBreakBond:(NSNotification *)notification
{
    Tile *tile = notification.object;
    CGFloat anchorY = tile.anchorPoint.y;
    for (Tile *t in tilesArray)
    {
        if (t.anchorPoint.y == anchorY)
        {
            [t animateHideColorInDuration:0.2];
        }
    }
}

-(void)update
{
    if (!isTimerRunning)
        return;
}

-(void)updateAnalytics
{
    
  
}

NSMutableArray *tilesArray;

-(void)sceneMadeActive
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
};

-(void)sceneMadeInActive
{
    [super sceneMadeInActive];
    
}

-(BOOL)touchBeganInElement:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    if (touch.tapCount == 2)
    {
        [self loadData];
    }
    return YES;
}

-(void)dealloc
{
    [super dealloc];
    [tilesArray release];
}


@end
