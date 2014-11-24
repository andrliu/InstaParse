//
//  ActivityViewController.m
//  Popular App
//
//  Created by May Yang on 11/17/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "ActivityViewController.h"
#import <Parse/PFObject+Subclass.h>
#import "RootDetailViewController.h"
#import "Comment.h"
#import "Tag.h"

@interface ActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *activitySegementedControl;
@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property NSArray *followingArray;
@property NSArray *followersArray;
@property NSArray *tempArrayForDisplay;

@end

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.profile = [[PFUser currentUser] objectForKey:@"profile"];
    [self queryForFollowing];
    [self.activityTableView reloadData];
}

- (void)queryForFollowing
{
    [Profile searchCurrentProfileWithID:self.profile.objectId includeKey:@"followings" Completion:^(Profile *profile, NSError *error)
    {
        if (!error)
        {
            [Photo searchPhotoByKey:@"profile" containedIn:profile.followings includeKey:@"profile" withOrder:@"createdAt" andLimit:10 Completion:^(NSArray *objects, NSError *error)
            {
                if (!error)
                {
                    self.followingArray = objects;
                    self.tempArrayForDisplay = self.followingArray;
                    [self.activityTableView reloadData];
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

- (void)queryForFollowers
{
    [Profile searchCurrentProfileWithID:self.profile.objectId includeKey:@"followers" Completion:^(Profile *profile, NSError *error)
     {
        if (!error)
        {
            [Photo searchPhotoByKey:@"profile" containedIn:profile.followers includeKey:@"profile" withOrder:@"createdAt" andLimit:10 Completion:^(NSArray *objects, NSError *error)
             {
                 if (!error)
                 {
                     self.followersArray = objects;
                     self.tempArrayForDisplay = self.followersArray;
                     [self.activityTableView reloadData];
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

- (IBAction)onActivitySegmentedControl:(id)sender
{
    if (self.activitySegementedControl.selectedSegmentIndex == 0)
    {
        [self queryForFollowing];
    }
    else
    {
        [self queryForFollowers];
    }
}

//MARK: tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tempArrayForDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Photo *photo = self.tempArrayForDisplay[indexPath.row];
    cell.imageView.image = [UIImage imageWithData:photo.imageData];
    Profile *profile = photo.profile;
    cell.textLabel.text = profile[@"name"];
    if (photo.tag)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"added a photo with #%@", photo.tag];
    }
    else
    {
        cell.detailTextLabel.text = @"added a photo without #";
    }
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RootDetailViewController *rdvc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.activityTableView indexPathForCell:sender];
    rdvc.photo = self.tempArrayForDisplay[indexPath.row];
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
