//
//  SearchViewController.m
//  Popular App
//
//  Created by May Yang on 11/17/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "SearchViewController.h"
#import "RootViewController.h"
#import "SearchDetailViewController.h"
#import <Parse/Parse.h>
#import "Tag.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *tableViewArray;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//MARK: searchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if (searchText.length != 0)
    {
        [self checkSelectedSegmentIndexAndSearchWithText:searchText];

    }
    else
    {
        [self checkSelectedSegmentIndexAndSearchWithText:searchText];
        [searchBar performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];
    }
}

- (void)checkSelectedSegmentIndexAndSearchWithText:(NSString *)searchText
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        [self searchTagAndReloadTableViewWithSearchText:searchText withOrderByKey:@"tag"];
    }
    else
    {
        [self searchProfileAndReloadTableViewWithSearchText:searchText withOrderByKey:@"lowercaseName"];
    }
}

-(void)searchTagAndReloadTableViewWithSearchText:(NSString *)searchText withOrderByKey:(NSString *)orderKey
{
    [Tag searchTagsWithSearchText:searchText withOrderByKey:orderKey Completion:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.tableViewArray = objects;
             [self.tableView reloadData];
         }
         else
         {
             [self error:error];
         }
     }];
}

-(void)searchProfileAndReloadTableViewWithSearchText:(NSString *)searchText withOrderByKey:(NSString *)orderKey
{
    [Profile searchProfilesWithSearchText:searchText withOrderByKey:orderKey Completion:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.tableViewArray = objects;
             [self.tableView reloadData];
         }
         else
         {
             [self error:error];
         }
     }];
}

//MARK: custom methods
- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        [self clearTableViewAndSearchBar];
    }
    else
    {
        [self clearTableViewAndSearchBar];
    }
}

- (void)clearTableViewAndSearchBar
{
    self.tableViewArray = @[];
    [self.tableView reloadData];
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

//MARK: tableview delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        Tag *tag = self.tableViewArray[indexPath.row];
        cell.textLabel.text = tag.tag;
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
    }
    else
    {
        Profile *profile = self.tableViewArray[indexPath.row];
        cell.textLabel.text = profile.name;
        cell.detailTextLabel.text = profile.memo;
        UIImage *image = [UIImage imageWithData:profile.avatarData];
        cell.imageView.image = image;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        Tag *tag = self.tableViewArray[indexPath.row];
        [Photo searchPhotoByKey:@"tag" equalTo:tag.tag Completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                [self performSegueWithIdentifier:@"tagSegue" sender:objects];
            }
            else
            {
                [self error:error];
            }
        }];
    }
    else
    {
        Profile *profile = self.tableViewArray[indexPath.row];
        [self performSegueWithIdentifier:@"profileSegue" sender:profile];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"tagSegue"])
    {
        RootViewController *rvc = segue.destinationViewController;
        rvc.tagPhotoArray = sender;
    }
    else
    {
        SearchDetailViewController *sdvc = segue.destinationViewController;
        sdvc.profile = sender;
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

@end
