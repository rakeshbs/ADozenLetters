//
//  Dictionary.h
//  DictionarySearch
//
//  Created by Rakesh on 16/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface Dictionary : NSObject
{
    NSMutableArray *words[10];
    BOOL *used[10];
}

@property (nonatomic) char *grid;

-(int)checkIfWordExists:(NSString *)word;
+(Dictionary * )getSharedDictionary;
-(void)reset;
-(NSString *)generateDozenLetters;
@end
