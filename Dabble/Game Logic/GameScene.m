//
//  GameScene.m
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "GameScene.h"
#import "Dictionary.h"

#define yOffset 75

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
        currentRandomNumber =  arc4random()+1;

        [mvpMatrixManager setOrthoProjection:-self.view.frame.size.width
                                            :0 :-self.view.frame.size.height :0 :-1 :1000];
        
        
        
        resString[0] = [[NSMutableString alloc]initWithString:@"#####"];
        resString[1] = [[NSMutableString alloc]initWithString:@"####"];
        resString[2] = [[NSMutableString alloc]initWithString:@"###"];
        madeWords = [[NSMutableArray alloc]init];
        
        [self performSelectorInBackground:@selector(loadDictionary) withObject:nil];
        
        gcHelper = [GCHelper sharedInstance];
        gcHelper.delegate = self;
        [gcHelper authenticateLocalUser];
      //  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];

      
    }
    return  self;
}

-(void)loadDictionary
{
    dictionary = [Dictionary getSharedDictionary];
}

-(void)loadData
{
    
    NSURL *url = [NSURL URLWithString:@"http://qucentis.com/dabble.php"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *stringData = [dataDict[@"chars"] uppercaseString];
    [self performSelectorOnMainThread:@selector(sendCharData:) withObject:stringData waitUntilDone:YES];
    
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
        [elements removeObjectsInArray:squaresArray];
        [squaresArray release];
    }
    
    squaresArray = [[NSMutableArray alloc]init];
    
    
    for (int i = 0;i<3;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray1[i]];
            square.centerPoint = CGPointMake(160, 160+yOffset);
        square.anchorPoint = CGPointMake(100+60*i, 210+yOffset);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<4;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray2[i]];
        square.centerPoint = CGPointMake(160, 160+yOffset);
        square.anchorPoint = CGPointMake(70+60*i, 130+yOffset);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    for (int i = 0;i<5;i++)
    {
        square = [[Square alloc]initWithCharacter:charArray3[i]];
        square.centerPoint = CGPointMake(160, 160+yOffset);
        square.anchorPoint = CGPointMake(40+60*i, 50+yOffset);
        [self addElement:square];
        [squaresArray addObject:square];
        square.squaresArray  = squaresArray;
        [square release];
    }
    
    CGFloat delay = 0.0;
    
    for (Square *sq in [squaresArray reverseObjectEnumerator])
    {
        [sq throwToPoint:sq.anchorPoint inDuration:0.7 afterDelay:delay];
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
	color.red = 241.0/255.0;
	color.blue = 196.0/255.0;
	color.green = 15/255.0;
	color.alpha = 1;
    [director clearScene:color];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
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
            CGFloat anchorY = i*80 + 50 + yOffset;
            for (Square *sq in squaresArray)
            {
                if (sq.anchorPoint.y == anchorY)
                {
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
    [self sendRandomNumber];
    
}
- (void)matchEnded
{
        NSLog(@"match Ended");
}
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    Message *message = (Message *) [data bytes];
    
    int messageType = message->messageType;
    
    NSLog(@"message recieved");
    
    if (messageType== kMessageTypeRandomNumber)
    {
        if (currentRandomNumber == 0)
            return;
        
        MessageRandomNumber * messRandom = (MessageRandomNumber *) [data bytes];
        if (currentRandomNumber > messRandom->randomNumber)
        {
            isServer = YES;
            [self performSelectorInBackground:@selector(loadData) withObject:nil];
            NSLog(@"is server");
        }
        else if (currentRandomNumber == messRandom->randomNumber)
        {
            currentRandomNumber =  arc4random()+1;
            [self sendRandomNumber];
        }
        else
        {
            isServer = NO;
            NSLog(@"is not server");
        }
    }
    else if (messageType == kMessageTypeCharData)
    {
        MessageCharData * messData = (MessageCharData *) [data bytes];

        NSString *stringData = [NSString stringWithCString:messData->charData encoding:NSUTF8StringEncoding];
      //          int k = 0;
       [self performSelectorOnMainThread:@selector(createSquares:) withObject:stringData waitUntilDone:YES];
    }
}
- (void)inviteReceived
{
        
}
- (void)localUserAuthenticated
{

    [gcHelper findMatchWithMinPlayers:2 maxPlayers:2 viewController:director.openGLViewController delegate:self];
}

-(void)sendRandomNumber
{
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = currentRandomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendDataToOthers:data];
}

-(void)sendCharData:(NSString *)stringData
{
    MessageCharData message;
    message.message.messageType = kMessageTypeCharData;
    const char *charArray = [stringData cStringUsingEncoding:NSUTF8StringEncoding];

    for (size_t idx = 0; idx < 12; ++idx) {
        message.charData[idx] = charArray[idx];
    }
    message.charData[12]='\0';
    
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageCharData)];
    [self sendDataToOthers:data];
}

-(void)sendDataToOthers:(NSData *)data
{
    [gcHelper.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:nil];
}


-(void)dealloc
{
    [super dealloc];
    [squaresArray release];
}


@end
