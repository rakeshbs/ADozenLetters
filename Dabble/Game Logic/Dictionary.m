//
//  Dictionary.m
//  DictionarySearch
//
//  Created by Rakesh on 16/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Dictionary.h"
#import "FileReader.h"

@implementation Dictionary

@synthesize grid;

+(Dictionary * )getSharedDictionary
{
    static  Dictionary *sharedObject;
    
    @synchronized(self)
    {
        if (sharedObject == nil)
        {
            sharedObject = [[Dictionary alloc]init];
        }
        
    }
    return  sharedObject;
}

-(Dictionary *)init
{
    if (self = [super init])
    {
        for (int i = 3; i < 6;i++)
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"w%d",i] ofType:@""];
            FileReader *fileReader = [[FileReader alloc]initWithFilePath:filePath];
            
            words[i] = [[NSMutableArray alloc]init];
            
            NSString *line;
            while ((line = [fileReader readLine]))
            {
                [words[i] addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            [fileReader release];
            
            used[i] = malloc(sizeof(BOOL)*words[i].count);
            memset(used[i], 0, sizeof(BOOL)*words[i].count);
            
        }
    }
    return  self;
}



-(int)checkIfWordExists:(NSString *)word
{
    int index = word.length;
    
    if (words[index].count <= 0)
        return -1;
    
    int low = 0;
    int high = [words[index] count];
    int mid = (high + low)/2;
    
    do {
        NSString *str = words[index][mid];
        
        if ([str caseInsensitiveCompare:word]  == NSOrderedAscending)
        {
            low = mid;
            
        }
        else if ([str caseInsensitiveCompare:word] == NSOrderedDescending)
        {
            high = mid;
            
        }
        else
        {
            if (!used[index][mid])
            {
                used[index][mid] = YES;
                return mid;
            }
            return -2;
        }
        mid = (high + low)/2;
    }
    while ((high - low)>1);
    
    
    return -1;
}

-(NSString *)generateDozenLetters
{
    BOOL found = NO;
    NSString *letters = nil;
    while (!found)
    {
        int r3 = arc4random()%words[3].count;
        int r4 = arc4random()%words[4].count;
        int r5 = arc4random()%words[5].count;
    
        letters = [NSString stringWithFormat:@"%@%@%@",words[3][r3],words[4][r4],words[5][r5]];
    
        for (int i = 0;i<20;i++)
        {
            letters = [self permuteLetters:letters];
            if ([self checkIfValid:letters])
            {
                found = YES;
                break;

            }
        }
    }
    
    NSString *ret = [[NSString stringWithFormat:@"%@,%@,%@",
                     [letters substringWithRange:NSMakeRange(0, 5)],
                      [letters substringWithRange:NSMakeRange(5, 4)],
                       [letters substringWithRange:NSMakeRange(9, 3)]]uppercaseString];
    
    return ret;
    
}

-(BOOL)checkIfValid:(NSString *)letters
{
    if ([self validateWord:[letters substringWithRange:NSMakeRange(0, 5)]])
        return NO;
    if ([self validateWord:[letters substringWithRange:NSMakeRange(5, 4)]])
        return NO;
    if ([self validateWord:[letters substringWithRange:NSMakeRange(9, 3)]])
        return NO;
    
    return YES;
    
}

-(NSString *)permuteLetters:(NSString *)letters
{
    NSMutableString *permute = [[NSMutableString alloc]initWithString:letters];
    NSMutableString *ordered = [[NSMutableString alloc]init];
    
    while (permute.length > 0)
    {
        int r = arc4random()%permute.length;
        NSRange range = NSMakeRange(r, 1);
        
        [ordered appendString:[permute substringWithRange:range]];
        [permute deleteCharactersInRange:range];
    }
    

    NSString *ret = [NSString stringWithString:ordered];
    [ordered release];
    [permute release];
    
    return ret;
}


-(BOOL)validateWord:(NSString *)word
{
    int index = word.length;
    
    if (words[index].count <= 0)
        return -1;
    
    int low = 0;
    int high = [words[index] count];
    int mid = (high + low)/2;
    
    do {
        NSString *str = words[index][mid];
        
        if ([str caseInsensitiveCompare:word]  == NSOrderedAscending)
        {
            low = mid;
            
        }
        else if ([str caseInsensitiveCompare:word] == NSOrderedDescending)
        {
            high = mid;
            
        }
        else
        {
            return YES;
            
        }
        mid = (high + low)/2;
    }
    while ((high - low)>1);
    
    
    return NO;
}


-(void)reset
{
    for (int i = 0;i<3;i++)
    {
        memset(used[i], 0, sizeof(BOOL)*words[i].count);
    }
}


@end
