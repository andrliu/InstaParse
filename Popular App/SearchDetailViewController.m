//
//  SearchDetailViewController.m
//  Popular App
//
//  Created by May Yang on 11/17/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "PhotoCollectionViewCell.h"
#import "RootDetailViewController.h"
#import "Photo.h"
#import "User.h"
#import <Parse/Parse.h>

@interface SearchDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *photoCountButton;
@property (weak, nonatomic) IBOutlet UIButton *fersCountButton;
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;
@property (strong, nonatomic) IBOutlet UITextView *detailTextView;
@property (strong, nonatomic) NSArray *collectionViewArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property Profile *currentUserProfile;

@end

@implementation SearchDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCurrentUserProfile];
    [self reloadPhoto];
    self.navigationItem.title = self.profile.name;
    UIImage *image = [UIImage imageWithData:self.profile.avatarData];
    self.detailImageView.image = image;
    self.detailTextView.text = self.profile.memo;
    [self.fersCountButton setTitle:[NSString stringWithFormat:@"Fers:%lu",(unsigned long)self.profile.followers.count]
                          forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"Fings:%lu",(unsigned long)self.profile.followings.count]
                          forState:UIControlStateNormal];
}

//MARK: custom update current user method
- (void)updateCurrentUserProfile
{
    User *user = [User currentUser];
    PFQuery *profileQuery = [Profile query];
    [profileQuery getObjectInBackgroundWithId:[user[@"profile"] objectId] block:^(PFObject *object, NSError *error)
     {
         if (!error)
         {
            self.currentUserProfile = (Profile *)object;
             NSMutableArray *array = [@[]mutableCopy];
             for (PFObject *object in self.profile.followers)
             {
                 [array addObject:object.objectId];
             }
             if ([array containsObject:self.currentUserProfile.objectId] ||
                 [self.profile.objectId isEqual: self.currentUserProfile.objectId])
             {
                 [self disableFollowingButton];
             }
         }
         else
         {
            [self error:error];
         }
     }];
}

- (void)disableFollowingButton
{
    [self.followingButton setBackgroundImage:[UIImage imageNamed:@"post"] forState:UIControlStateNormal];
    self.followingButton.enabled = NO;
}

//MARK: custom reload method
- (void)reloadPhoto
{
    [Photo searchPhotoByKey:@"profile" equalTo:self.profile Completion:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.collectionViewArray = objects;
             [self.photoCountButton setTitle:[NSString stringWithFormat:@"Photos: %lu",(unsigned long)self.collectionViewArray.count]
                                    forState:UIControlStateNormal];
             [self.collectionView reloadData];
         }
         else
         {
             [self error:error];
         }
     }];
}

- (IBAction)followingOnButtonPressed:(UIButton *)sender
{
    PFObject *followingObject = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                objectId:self.profile.objectId];
    NSMutableArray *followingArray = [@[]mutableCopy];
    if (self.currentUserProfile.followings.count == 0)
    {
        self.currentUserProfile.followings = @[followingObject];
    }
    else
    {
        followingArray = [self.currentUserProfile.followings mutableCopy];
        [followingArray addObject:followingObject];
        self.currentUserProfile.followings = followingArray;
    }
    [self.currentUserProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            PFObject *followerObject = [PFObject objectWithoutDataWithClassName:@"Profile"
                                                                       objectId:self.currentUserProfile.objectId];
            NSMutableArray *followerArray = [@[]mutableCopy];
            if (self.profile.followers.count == 0)
            {
                self.profile.followers = @[followerObject];
            }
            else
            {
                followerArray = [self.profile.followers mutableCopy];
                [followerArray addObject:followerObject];
                self.profile.followers = followerArray;
            }
            [self.profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (!error)
                {
                    [self.fersCountButton setTitle:[NSString stringWithFormat:@"Fers:%lu",(unsigned long)self.profile.followers.count]
                                          forState:UIControlStateNormal];
                    [self disableFollowingButton];
                }
                else
                {
                    [self error:error];
                }
            }];
        }
        else
        {
            [self error:error];
        }
    }];
}

//MARK: collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSData *data = [self.collectionViewArray[indexPath.item] imageData];
    cell.imageView.image = [UIImage imageWithData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     Photo *selectedPhoto = self.collectionViewArray[indexPath.item];
     [self performSegueWithIdentifier:@"photoSegue" sender:selectedPhoto];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RootDetailViewController *rdvc = segue.destinationViewController;
    rdvc.photo = sender;
}

//MARK: UIAlert
- (void)error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
