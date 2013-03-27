//
//  Dictionary.m
//  DictionarySearch
//
//  Created by Rakesh on 16/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Dictionary.h"


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
        wordList = [[NSMutableArray alloc]init];
        
        NSString *tmp;
        NSArray *lines;
        lines = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wordList" ofType:@"txt"]
                                           encoding:NSUTF8StringEncoding
                                              error:nil]
                 componentsSeparatedByString:@"\n"];
        
        NSEnumerator *nse = [lines objectEnumerator];
        
        while(tmp = [nse nextObject])
        {
            NSString *str = [tmp stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [wordList addObject:str];
        }
       // NSLog(@"%d",[wordList count]);
        used = malloc(sizeof(BOOL)*wordList.count);
        memset(used, 0, sizeof(BOOL)*wordList.count);
    
    }
    return  self;
}



-(int)checkIfWordExists:(NSString *)word
{
    int low = 0;
    int high = [wordList count];
    int mid = (high + low)/2;
    
    do {
        NSString *str = wordList[mid];
        
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
            if (!used[mid])
            {
                used[mid] = YES;
                return mid;
            }
            return -2;
        }
        mid = (high + low)/2;
    }
    while ((high - low)>1);
    
    
    return -1;
}

-(BOOL)checkIfPrefixExists:(NSString *)prefix
{
    
    int low = 0;
    int high = [wordList count];
    int mid = (high + low)/2;
    
    do
    {
        NSString *str = wordList[mid];
        if ([str hasPrefix:prefix])
        {
            return true;
        }
        else if ([str caseInsensitiveCompare:prefix] == NSOrderedAscending)
        {
            low = mid;
            
        }
        else if ([str caseInsensitiveCompare:prefix] == NSOrderedDescending)
        {
            
            high = mid;
        }
        else
        {
            return true;
        }
        mid = (high + low)/2;
    }
    while ((high - low)>1);
    
    
    return false;
}

-(void)reset
{
    memset(used, 0, sizeof(BOOL)*wordList.count);
}


@end
