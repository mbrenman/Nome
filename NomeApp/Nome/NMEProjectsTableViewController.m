//
//  NMEProjectsTableViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEProjectsTableViewController.h"
#import "NMEProjectsTableCell.h"
#import "NMEAppDelegate.h"
#import "NMEDataManager.h"
#import "NMEProjectViewController.h"

@interface NMEProjectsTableViewController ()

@property (strong, nonatomic) NSMutableArray *projects;
@property (strong, nonatomic) NMEDataManager *dataManager;
@property (strong, nonatomic) PFObject *clickedObject;

@end

@implementation NMEProjectsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)addButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"projectListToAddProject" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NMEDataManager *dataManager = [NMEAppDelegate delegate].dataManager;
    [dataManager getMyProjectsFromServer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.projects = dataManager.myProjects;
        [self.tableView reloadData];
    });
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
    self.clickedObject = [self.projects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"projectsToProject" sender:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NMEProjectsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectsTableCell"];
    
    if (!cell) {
        cell = [[NMEProjectsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectsTableCell"];
    }
    
    PFObject *currentProject = [self.projects objectAtIndex:indexPath.row];
   
    cell.backgroundColor = [UIColor colorWithHue:.49 saturation:.22 brightness:.95 alpha:1.];
//    cell.backgroundColor = [UIColor colorWithHue:.49 saturation:.22 brightness:.95 alpha:1.];

    cell.projectNameLabel.text = currentProject[@"projectName"];
    cell.projectNameLabel.font = [UIFont fontWithName:@"Avenir" size:18];
//    cell.projectNameLabel.textColor = [UIColor colorWithHue:.03 saturation:.64 brightness:.99 alpha:1.];
//    cell.projectNameLabel.textColor = [UIColor colorWithHue:.49 saturation:.22 brightness:.95 alpha:1.];
//    cell.projectNameLabel.textColor = [UIColor colorWithHue:.03 saturation:.64 brightness:.99 alpha:1.];
    cell.projectNameLabel.textColor = [UIColor colorWithWhite:.4 alpha:1.];

    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] isKindOfClass:[NMEProjectViewController class]]) {
        [segue.destinationViewController setProject:self.clickedObject];
    }
}


@end
