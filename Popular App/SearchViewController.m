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
@property NSArray *tableViewArray;

@end

@implementation SearchViewController

//MARK: app load sequence
- (void)viewDidLoad
{
    [super viewDidLoad];


    //refresh on pull
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshDisplay:withClass:withSearchText:withOrderByKey:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

}


//MARK: delegate methods
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
    }
    else
    {
        Profile *profile = self.tableViewArray[indexPath.row];
        cell.textLabel.text = profile.name;
        cell.detailTextLabel.text = profile.description;
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
        PFQuery *query = [Photo query];
        [query whereKey:@"tag" equalTo:tag.tag];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            [self performSegueWithIdentifier:@"tagSegue" sender:objects];
        }];

    }
    else
    {
        Profile *profile = self.tableViewArray[indexPath.row];
        [self performSegueWithIdentifier:@"profileSegue" sender:profile];

    }

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    //    searchText

    if (searchText.length != 0)
    {
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            [self refreshDisplay:nil withClass:@"Tag" withSearchText:searchText withOrderByKey:@"tag"];
        }
        else
        {
            [self refreshDisplay:nil withClass:@"Profile" withSearchText:searchText withOrderByKey:@"lowercaseName"];
        }

    }
    //refreshes the table view when removing the letters
    else
    {
        [searchBar resignFirstResponder];
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            [self refreshDisplay:nil withClass:@"Tag" withSearchText:searchText withOrderByKey:@"tag"];
        }
        else
        {
            [self refreshDisplay:nil withClass:@"Profile" withSearchText:searchText withOrderByKey:@"lowercaseName"];
        }
    }

    [self.tableView reloadData];
}

//MARK: custom methods
- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.tableViewArray = @[];
        [self.tableView reloadData];
    }
    else
    {
        self.tableViewArray = @[];
        [self.tableView reloadData];
    }
}

-(void)refreshDisplay:(UIRefreshControl *)refreshControl withClass:(NSString *)class withSearchText:(NSString *)searchText withOrderByKey:(NSString *)orderKey
{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ BEGINSWITH %@",orderKey, searchText];
//    PFQuery *query = [PFQuery queryWithClassName:class predicate:predicate]; //crash point
    PFQuery *query = [PFQuery queryWithClassName:class];

    [query whereKey:orderKey hasPrefix:[searchText lowercaseString]]; //parse query format, better than predicate
    [query orderByAscending:orderKey]; //sort query
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             [self error:error];
         }
         else
         {
             self.tableViewArray = objects;
             [self.tableView reloadData];
         }

         [refreshControl endRefreshing];

     }];


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"tagSegue"])
    {
        RootViewController *rvc = segue.destinationViewController;
        rvc.tagPhotoArray = sender;
    }
    else if ([segue.identifier isEqualToString:@"profileSegue"])
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
