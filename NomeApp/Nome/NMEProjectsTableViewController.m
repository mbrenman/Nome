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
#import "NMERecorderViewController.h"

@interface NMEProjectsTableViewController ()

@property (strong, nonatomic) NSMutableArray *projects;
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
    self.tableView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getProjectNames];
}

- (void)getProjectNames
{
    PFQuery *query = [PFQuery queryWithClassName:@"projectObject"];
    NSString *username = [[PFUser currentUser] username];
    [query whereKey:@"collaborators" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *unsorted = [[NSMutableArray alloc] initWithArray:objects];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES];
        
        self.projects = [[unsorted sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        
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
    self.clickedObject = [self.projects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"projectsToProject" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *myUsername = [[PFUser currentUser] valueForKey:@"username"];
        PFObject *projectObject = [self.projects objectAtIndex:indexPath.row];

        [self.projects removeObject:projectObject];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        NSMutableArray *collaborators = projectObject[@"collaborators"];
        
        if (collaborators.count == 1) {
            
            NSArray *loopDictionaries = projectObject[@"loops"];
            
            for (int i = 0; i < loopDictionaries.count; i++) {
                PFObject *object = [loopDictionaries objectAtIndex:i];
                PFObject *objectPointer = object[@"id"];
                
                if ([objectPointer objectId]){
                    PFQuery *query = [PFQuery queryWithClassName:@"loopObject"];
                    [query whereKey:@"objectId" equalTo:[objectPointer objectId]];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [object deleteInBackground];
                    }];
                }
            }
            
            [projectObject deleteInBackground];
            
         } else {
            for (NSString *collaborator in collaborators) {
                if ([collaborator isEqualToString:myUsername]) {
                    [collaborators removeObject:collaborator];
                    break;
                }
            }
            [projectObject saveInBackground];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMEProjectsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectsTableCell"];
    
    if (!cell) {
        cell = [[NMEProjectsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectsTableCell"];
    }
    
    PFObject *currentProject = [self.projects objectAtIndex:indexPath.row];
   
    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    
    cell.secondaryLabel.text = [NSString stringWithFormat:@"%u BPM", [[currentProject[@"bpm"] description] intValue]];
    cell.secondaryLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.secondaryLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
    
    cell.projectNameLabel.text = currentProject[@"projectName"];
    cell.projectNameLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
    cell.projectNameLabel.font = [UIFont fontWithName:@"Avenir" size:28];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue destinationViewController] isKindOfClass:[NMERecorderViewController class]]) {
        [segue.destinationViewController setProject:self.clickedObject];
    }
}


@end
