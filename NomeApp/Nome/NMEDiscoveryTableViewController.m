//
//  NMEDiscoveryTableViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEDiscoveryTableViewController.h"
#import "NMEAppDelegate.h"
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
    [self getProjectNames];
}

- (void)getProjectNames
{
    //Find all projects
    PFQuery *query = [PFQuery queryWithClassName:@"projectObject"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //Store projects locally
        self.projects = [[NSMutableArray alloc] initWithArray:objects];
        
        //Update table with data
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    //Get project corresponding to the cell
    PFObject *currentProject = [self.projects objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    
    //Set cell information with the project information
    cell.secondaryLabel.text = [NSString stringWithFormat:@"%u BPM", [[currentProject[@"bpm"] description] intValue]];
    cell.secondaryLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.secondaryLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
    
    cell.projectNameLabel.text = currentProject[@"projectName"];
    cell.projectNameLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.projectNameLabel.font = [UIFont fontWithName:@"Avenir" size:28];

    return cell;
}

@end
