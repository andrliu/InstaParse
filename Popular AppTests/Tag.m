//
//  Tag.m
//  Popular App
//
//  Created by Andrew Liu on 11/18/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@dynamic tag;
@dynamic photosOfTag;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Tag";
}

+ (void) searchTagsWithSearchText:(NSString *)searchText withOrderByKey:(NSString *)orderKey Completion:(searchTagBlock)complete
{
    PFQuery *query = [self query];
    [query whereKey:orderKey hasPrefix:[searchText lowercaseString]];
    [query orderByAscending:orderKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            complete(objects,nil);
        }
        else
        {
            complete(nil,error);
        }
    }];
}

@end
