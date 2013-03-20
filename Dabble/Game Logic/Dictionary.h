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
    int word_count;
    NSMutableArray *wordList;
    BOOL *used;
}

@property (nonatomic) char *grid;

-(BOOL)checkIfPrefixExists:(NSString *)prefix;
-(BOOL)checkIfWordExists:(NSString *)word;
+(Dictionary * )getSharedDictionary;

@end
