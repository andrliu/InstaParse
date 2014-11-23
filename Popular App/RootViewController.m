//
//  ViewController.m
//  Popular App
//
//  Created by May Yang on 11/17/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "RootViewController.h"
#import "RootDetailViewController.h"
#import "PhotoCollectionViewCell.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseUI/ParseUI.h>
#import "User.h"
#import "Profile.h"
#import "Photo.h"

@interface RootViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *collectionViewArray;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![PFUser currentUser])
    {
        LoginViewController *logInViewController = [[LoginViewController alloc]init];
        [logInViewController setDelegate:self];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;

        SignupViewController *signUpViewController = [[SignupViewController alloc]init];
        [signUpViewController setDelegate:self];
        signUpViewController.fields = PFSignUpFieldsDefault;

        [logInViewController setSignUpController:signUpViewController];

        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else
    {
        if (self.tagPhotoArray != nil)
        {
            self.collectionViewArray = self.tagPhotoArray;
            [self.navigationItem.titleView setHidden:YES];
        }
        else
        {
            [Photo sortByDescending:@"createdAt" withLimit:16 Completion:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    self.collectionViewArray = objects;
                    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    [self.collectionView reloadData];
                }
                else
                {
                    [self error:error];
                }

            }];
        }
    }
}

//MARK: PFLogInViewController delegate
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES;
    }
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO;
}

- (void)logInViewController:(LoginViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [self error:error];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        {
            informationComplete = NO;
            break;
        }
    }
    if (!informationComplete)
    {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    return informationComplete;
}

//MARK: PFSignUpViewController delegate
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    Profile *profile = [Profile object];
    [user setObject:profile forKey:@"profile"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (!error)
        {
            [profile setNameAndCanonicalName:user.username];
            [profile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (!error)
                {
                    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    [self error:error];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: CollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Photo *photo = self.collectionViewArray[indexPath.item];
    UIImage *image = [UIImage imageWithData:photo.imageData];
    cell.imageView.image = image;
    return cell;
}

- (IBAction)onSegmentedControlTapped:(UISegmentedControl *)sender
{
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        [Photo sortByDescending:@"createdAt" withLimit:16 Completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.collectionViewArray = objects;
                [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self.collectionView reloadData];
            }
            else
            {
                [self error:error];
            }

        }];
    }
    else
    {
        [Photo sortByDescending:@"likeCount" withLimit:16 Completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.collectionViewArray = objects;
                [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self.collectionView reloadData];
            }
            else
            {
                [self error:error];
            }

        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RootDetailViewController *rdvc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    rdvc.photo = self.collectionViewArray[indexPath.item];
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
