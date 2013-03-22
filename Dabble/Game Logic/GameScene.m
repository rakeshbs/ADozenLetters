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

NSString *charArray1[3];
NSString *charArray2[4];
NSString *charArray3[5];
NSMutableString *resString[3];
Dictionary *dictionary;
NSMutableArray *madeWords;

-(id)init
{
    if (self = [super init])
    {
        
        [mvpMatrixManager setOrthoProjection:-self.view.frame.size.width
                                            :0 :-self.view.frame.size.height :0 :-1 :1000];
        
        
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];

        [self performSelectorInBackground:@selector(loadData) withObject:nil];
        gcHelper = [GCHelper sharedInstance];
        gcHelper.delegate = self;
        [gcHelper authenticateLocalUser];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];

      
    }
    return  self;
}

-(void)loadData
{
    dictionary = [Dictionary getSharedDictionary];
    NSURL *url = [NSURL URLWithString:@"http://qucentis.com/dabble.php"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *stringData = [dataDict[@"chars"] uppercaseString];
    
    
    [self performSelectorOnMainThread:@selector(createSquares:) withObject:stringData waitUntilDone:YES];

}

-(void)createSquares:(NSString *)dataStr
{    
    int ind = 0;
    
    [dictionary reset];
    
    for (int i = 0; i < 3; i++)
    {
        charArray1[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    for (int i = 0; i < 4; i++)
    {
        charArray2[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    for (int i = 0; i < 5; i++)
    {
        charArray3[i] = [dataStr substringWithRange:NSMakeRange(ind, 1)];
        ind++;
    }
    
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
        square.centerPoint = CGPointMake(160, 160);
        square.anchorPoint = CGPointMake(100+60*i, 210);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<4;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray2[i]];
        square.centerPoint = CGPointMake(160, 160);
        square.anchorPoint = CGPointMake(70+60*i, 130);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<5;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray3[i]];
        square.centerPoint = CGPointMake(160, 160);
        square.anchorPoint = CGPointMake(40+60*i, 50);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    CGFloat delay = 0.0;
    
    for (Square *sq in [squaresArray reverseObjectEnumerator])
    {
        [sq moveToPoint:sq.anchorPoint inDuration:0.7 afterDelay:delay];
        delay += 0.1;
    }
    
    [self performSelector:@selector(enableNotification) withObject:nil afterDelay:5];

}

-(void)enableNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(squareFinishedMoving:) name:@"SquareFinishedMoving" object:nil];

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

-(BOOL)touchBeganInScene:(UITouch *)touch withIndex:(int)index withEvent:(UIEvent *)event
{
    NSLog(@"%d",touch.tapCount);
    if (touch.tapCount == 2)
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SquareFinishedMoving" object:nil];

           [self performSelectorInBackground:@selector(loadData) withObject:nil];
    }
    return YES;
}

//GameCenter Functions
- (void)matchStarted
{
    NSLog(@"match Started");
    
}
- (void)matchEnded
{
        NSLog(@"match Ended");
}
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    
}
- (void)inviteReceived
{
            NSLog(@"match invite received");
}
- (void)localUserAuthenticated
{
    NSLog(@"authenticated");
    [gcHelper findMatchWithMinPlayers:2 maxPlayers:2 viewController:director.openGLViewController delegate:self];
}


-(void)dealloc
{
    [super dealloc];
    [squaresArray release];
}


@end
