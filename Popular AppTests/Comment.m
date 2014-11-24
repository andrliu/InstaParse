//
//  Comment.m
//  Popular App
//
//  Created by Andrew Liu on 11/18/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic profileID;
@dynamic text;
@dynamic createdAt;
@dynamic photo;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Comment";
}

+ (void) getCommentFromPhoto:(Photo *)photo withLimit:(int)number Completion:(commentFromPhotoBlock)complete
{
    PFQuery *query = [Comment query];
    [query whereKey:@"photo" equalTo:photo];
    [query orderByDescending:@"createdAt"];
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

+ (void) storeCommentWith:(NSString *)text withPhoto:(Photo *)photo withUserID:(NSString *)userID Completion:(storeCommentBlock)complete
{
    Comment *comment = [Comment object];
    comment.text = text;
    comment.photo = photo;
    comment.profileID = userID;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            complete(YES,nil);
        }
        else
        {
            complete(NO,error);
        }
    }];
}

@end
