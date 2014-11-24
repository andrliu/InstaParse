//
//  Photo.m
//  Popular App
//
//  Created by Andrew Liu on 11/18/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "Photo.h"
#import "Profile.h"

@implementation Photo

@dynamic profile;
@dynamic createdAt;
@dynamic description;
@dynamic imageData;
@dynamic likeCount;
@dynamic profilesLiked;
@dynamic tag;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Photo";
}

+ (void) sortByDescending:(NSString *)reuqest withLimit:(int)number Completion:(sortPhotoBlock)complete
{
    PFQuery *query = [self query];
    [query orderByDescending:reuqest];
    query.limit = number;
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

+ (void) searchPhotoByKey:(NSString *)key equalTo:(id)object Completion:(searchPhotoByTagBlock)complete
{
    PFQuery *query = [self query];
    [query whereKey:key equalTo:object];
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

+ (void) searchPhotoByKey:(NSString *)key containedIn:(id)object includeKey:(NSString *)iKey withOrder:(NSString *)order andLimit:(int)number Completion:(searchFollowPhotoBlock)complete
{
    PFQuery *photosQuery = [self query];
    [photosQuery includeKey:iKey];
    [photosQuery orderByDescending:order];
    [photosQuery whereKey:key containedIn:object];
    photosQuery.limit = number;
    [photosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
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
