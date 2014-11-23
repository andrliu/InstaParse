//
//  Profile.m
//  Popular App
//
//  Created by Andrew Liu on 11/18/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "Profile.h"

@interface Profile (PrimitiveAccessors)

@end

@implementation Profile

@dynamic objectId;
@dynamic name;
@dynamic lowercaseName;
@dynamic memo;
@dynamic avatarData;
@dynamic followers;
@dynamic followings;

- (void)setNameAndCanonicalName:(NSString *)username
{
    self.name = username;
    self.lowercaseName = [username lowercaseString];
    self.memo = @"Newbie in the house!!!";
    UIImage *image = [UIImage imageNamed:@"avatar"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    self.avatarData = imageData;
}

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Profile";
}

@end
