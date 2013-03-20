//
//  GameScene.m
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GameScene.h"
#import "Dictionary.h"

@interface GameScene (Private)
-(void)createSquares;
@end

@implementation GameScene

NSString *charArray1[3] = {@"E",@"T",@"H"};
NSString *charArray2[4] = {@"O",@"W",@"R",@"D"};
NSString *charArray3[5] = {@"G",@"M",@"A",@"E",@"R"};
NSMutableString *resString[3];
Dictionary *dictionary;
NSMutableArray *madeWords;

-(id)init
{
    if (self = [super init])
    {
        
        [mvpMatrixManager setOrthoProjection:-self.view.frame.size.width
                                            :0 :-self.view.frame.size.height :0 :-1 :1000];
        
        [self createSquares];
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];
        dictionary = [[Dictionary alloc]init];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(squareFinishedMoving:) name:@"SquareFinishedMoving" object:nil];
      
    }
    return  self;
}

-(void)createSquares
{
    Square *square;
    if (squaresArray != nil)
    {
        [elements removeAllObjects];
        [squaresArray release];
    }
    
    squaresArray = [[NSMutableArray alloc]init];
    
    for (int i = 0;i<3;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray1[i]];
        square.centerPoint = CGPointMake(100+60*i, 210);
        square.anchorPoint = CGPointMake(100+60*i, 210);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<4;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray2[i]];
        square.centerPoint = CGPointMake(70+60*i, 130);
        square.anchorPoint = CGPointMake(70+60*i, 130);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<5;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray3[i]];
        square.centerPoint = CGPointMake(40+60*i, 50);
        square.anchorPoint = CGPointMake(40+60*i, 50);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
}

-(void)draw{
	Color4f color;
	color.red = 1;
	color.blue = 1;
	color.green = 1;
	color.alpha = 1;
    [director clearScene:color];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

-(void)update
{
    
}

-(void)squareFinishedMoving:(NSNotification *)notification
{
    for (Square *sq in squaresArray)
    {
        int arrIndex = (sq.anchorPoint.y-50)/80;
        int charIndex = -1;
        
        if (arrIndex == 0)
            charIndex = (sq.anchorPoint.x-40)/squareSize;
        if (arrIndex == 1)
            charIndex = (sq.anchorPoint.x-70)/squareSize;
        if (arrIndex == 2)
            charIndex = (sq.anchorPoint.x-100)/squareSize;
        
        if (sq.touchesInElement.count != 0)
            return;
        
        NSRange range  = NSMakeRange(charIndex, 1);
        [resString[arrIndex] replaceCharactersInRange:range withString:sq.character];
        
    }
    
    for (int i = 0;i<3;i++)
    {
        if ([dictionary checkIfWordExists:resString[i]])
        {
            NSLog(@"%@",resString[i]);
            [madeWords addObject:resString[i]];
            CGFloat anchorY = i*80 + 50;
            for (Square *sq in squaresArray)
            {
                if (sq.anchorPoint.y == anchorY)
                {
                    CGFloat delay = 0;
                    if (i == 0)
                        delay = (sq.anchorPoint.x-40)/squareSize;
                    if (i == 1)
                        delay = (sq.anchorPoint.x-70)/squareSize;
                    if (i == 2)
                        delay = (sq.anchorPoint.x-100)/squareSize;
                    [sq wiggleFor:1.0];
                    
                }
            }
        }
    }
}



NSMutableArray *squaresArray;

-(void)sceneMadeActive
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

};

-(void)sceneMadeInActive
{
    [super sceneMadeInActive];
    
}

-(BOOL)touchesBeganInScene:(NSSet *)touches withEvent:(UIEvent *)event
{
    return YES;
}
-(BOOL)touchesMovedInScene:(NSSet *)touches withEvent:(UIEvent *)event
{
        
	return YES;
}
-(BOOL)touchesEndedInScene:(NSSet *)touches withEvent:(UIEvent *)event
{
	return YES;
}

-(void)dealloc
{
    [super dealloc];
    [squaresArray release];
}


@end
