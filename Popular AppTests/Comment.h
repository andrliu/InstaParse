//
//  Comment.h
//  Popular App
//
//  Created by Andrew Liu on 11/18/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "Photo.h"

typedef void(^commentFromPhotoBlock)(NSArray *objects, NSError *error);
typedef void(^storeCommentBlock)(BOOL succeeded, NSError *error);

@interface Comment : PFObject  <PFSubclassing>

@property (nonatomic, strong) NSString *profileID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) Photo *photo;

+ (void) getCommentFromPhoto:(Photo *)photo withLimit:(int)number Completion:(commentFromPhotoBlock)complete;

+ (void) storeCommentWith:(NSString *)text withPhoto:(Photo *)photo withUserID:(NSString *)userID Completion:(storeCommentBlock)complete;

@end
