//
//  RecentDetailViewController.m
//  Popular App
//
//  Created by May Yang on 11/17/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "RootDetailViewController.h"
#import "Comment.h"
@import MessageUI;
@import Social;

@interface RootDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property Profile *currentProfile;
@end

@implementation RootDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.commentTextField.delegate = self;

    PFUser *currentUser = [PFUser currentUser];
    self.currentProfile = currentUser[@"profile"];

    self.imageView.image = [UIImage imageWithData:self.photo.imageData];

    if (self.photo.profilesLiked.count == 0)
    {
        self.photo.profilesLiked = [NSArray array];
    }
    if ([self checkForLike])
    {
        [self.likeButton setTitle:[NSString stringWithFormat:@"Liked: %lu", (unsigned long)self.photo.profilesLiked.count] forState:UIControlStateNormal];
        self.likeImageView.image = [UIImage imageNamed:@"like"];
    }
    else
    {
        [self.likeButton setTitle:[NSString stringWithFormat:@"Likes: %lu", (unsigned long)self.photo.profilesLiked.count] forState:UIControlStateNormal];
        self.likeImageView.image = [UIImage imageNamed:@"unlike"];
    }
    [self loadCommentsByPhoto:self.photo];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Comment *comment = self.commentArray[indexPath.row];
    cell.textLabel.text = comment.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy @ HH:mm:ss"];
    NSString *date = [dateFormatter stringFromDate:comment.createdAt];

    PFQuery *profileQuery = [Profile query];
//    [profileQuery includeKey:comment.profileID];
    [profileQuery getObjectInBackgroundWithId:comment.profileID
                                        block:^(PFObject *object, NSError *error)
    {
        Profile *commentProfile = (Profile *)object;

        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ on %@", commentProfile.name, date];
    }];
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//MARK: Actions

- (IBAction)onLikeButtonPressed:(UIButton *)sender
{
     if ([self checkForLike])
    {
        NSMutableArray *likedArray = [self.photo.profilesLiked mutableCopy];
        [likedArray removeObject:self.currentProfile.objectId];
        self.photo.profilesLiked = likedArray;
        NSString *count = [NSString stringWithFormat:@"Liked: %lu", (unsigned long)self.photo.profilesLiked.count];
        self.photo.likeCount = [NSNumber numberWithInt:(int)self.photo.profilesLiked.count];
        self.likeImageView.image = [UIImage imageNamed:@"like"];
        [self.likeButton setTitle:count forState:UIControlStateNormal];
        [self.photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error)
             {
                 [self error:error];
             }
         }];
    }
    else
    {
        NSMutableArray *likedArray = [self.photo.profilesLiked mutableCopy];
        [likedArray addObject:self.currentProfile.objectId];
        self.photo.profilesLiked = likedArray;
        NSString *count = [NSString stringWithFormat:@"Liked: %lu", (unsigned long)self.photo.profilesLiked.count];
        self.photo.likeCount = [NSNumber numberWithInt:(int)self.photo.profilesLiked.count];
        self.likeImageView.image = [UIImage imageNamed:@"unlike"];
        [self.likeButton setTitle:count forState:UIControlStateNormal];
        [self.photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error)
             {
                 [self error:error];
             }
         }];
    }
}

-(BOOL)checkForLike
{
    BOOL isLiked = NO;
    for (int i=0; i<self.photo.profilesLiked.count; i++)
    {
        if ([self.photo.profilesLiked[i] isEqualToString:self.currentProfile.objectId])
        {
            isLiked = YES;
            break;
        }
    }
    return isLiked;
}

- (IBAction)commentTextField:(UITextField *)sender
{
    if (![self.commentTextField.text isEqual:@""])
    {
        Comment *comment = [Comment object];
        comment.text = sender.text;
        comment.photo = self.photo;
        comment.profileID = [[PFUser currentUser][@"profile"] objectId];
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [self loadCommentsByPhoto:self.photo];
        }];
        self.commentTextField.text = @"";
    }
}

- (void)loadCommentsByPhoto:(Photo *)photo
{
    PFQuery *commentQuery = [Comment query];
    [commentQuery whereKey:@"photo" equalTo:photo];
    [commentQuery orderByDescending:@"createdAt"];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             [self error:error];

         }
         else
         {
             self.commentArray = [objects mutableCopy];
             [self.tableView reloadData];

         }
     }];
}

//MARK: Share the photo
- (IBAction)onShareButtonPressed:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share"
                                                                   message:@"Let the whole world to see the picture!"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *emailButton = [UIAlertAction actionWithTitle:@"Email it"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                            {
                                                                [self sendEmail:self.photo.imageData];
                                                            }];
    [alert addAction:emailButton];
    UIAlertAction *twitButton = [UIAlertAction actionWithTitle:@"Twit it"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                            {
                                                                [self sendTwit:self.photo.imageData];
                                                            }];
    [alert addAction:twitButton];
    UIAlertAction *nothigButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:nothigButton];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: Email
-(void)sendEmail:(NSData *)data
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:@"It's from Instaparse"];
        [mailCont addAttachmentData:data mimeType:@"image/jpg" fileName:@"photo.jpg"];
        [mailCont setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
    else
    {
        [self errorMessage:@"Please make sure your device has an internet connection and you have at least one email account setup"];
    }
}

//MARK: Twitter
-(void) sendTwit:(NSData *)data
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Cool pic!"];
        [tweetSheet addImage:[UIImage imageWithData:data]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [self errorMessage:@"Please make sure your device has an internet connection and you have at least one Twitter account setup"];
    }
}

- (IBAction)onReportButtonPressed:(UIButton *)sender
{
    [self reportThePhotoEmail:self.photo.imageData];
}

//MARK: Report the photo
-(void)reportThePhotoEmail:(NSData *)data
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setToRecipients:[NSArray arrayWithObject:@"abuse@instaparse.com"]];
        [mailCont setSubject:@"Violation alert"];
        [mailCont setMessageBody:@"This photo vilates the Instaparse rules" isHTML:NO];
        [mailCont addAttachmentData:data mimeType:@"image/jpg" fileName:@"photo.jpg"];
        [mailCont setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
    else
    {
        [self errorMessage:@"Please make sure your device has an internet connection and you have at least one email account setup"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (!error)
    {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self error:error];
    }
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

- (void)errorMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Message"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
