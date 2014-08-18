//
//  NMEDiscoveryTableViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEDiscoveryTableViewController.h"
#import "NMEAppDelegate.h"
#import "NMEDataManager.h"
#import "NMEDiscoverTableCell.h"

@interface NMEDiscoveryTableViewController ()

@property (strong, nonatomic) NSMutableArray *projects;

@end

@implementation NMEDiscoveryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear");
    [self getProjectNames];
}

- (void)getProjectNames
{
    PFQuery *query = [PFQuery queryWithClassName:@"projectObject"];
    NSLog(@"about to run query");
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"found things");
        self.projects = [[NSMutableArray alloc] initWithArray:objects];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.projects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"discoverToProject" sender:self];
#warning WhichProject?
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NMEDiscoverTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"discoverTableCell"];
    
    if (!cell) {
        cell = [[NMEDiscoverTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"discoverTableCell"];
    }
    
    PFObject *currentProject = [self.projects objectAtIndex:indexPath.row];
    
    NSLog([NSString stringWithFormat:@"%@", currentProject]);
    
    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    
    
    
    cell.secondaryLabel.text = [NSString stringWithFormat:@"%u BPM", [[currentProject[@"bpm"] description] intValue]];
    cell.secondaryLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.secondaryLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
    
    cell.projectNameLabel.text = currentProject[@"projectName"];
    cell.projectNameLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.projectNameLabel.font = [UIFont fontWithName:@"Avenir" size:28];
    //    cell.projectNameLabel.textColor = [UIColor colorWithHue:.03 saturation:.64 brightness:.99 alpha:1.];
    //    cell.projectNameLabel.textColor = [UIColor colorWithHue:.49 saturation:.22 brightness:.95 alpha:1.];
    //    cell.projectNameLabel.textColor = [UIColor colorWithHue:.03 saturation:.64 brightness:.99 alpha:1.];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
