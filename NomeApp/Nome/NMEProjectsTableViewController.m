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
    return self;
}

- (IBAction)addButtonPressed:(id)sender {
    //Segue to New Project Screen (NMEAddProjectViewController)
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
    //Find all projects
    PFQuery *query = [PFQuery queryWithClassName:@"projectObject"];
    
    //Current User's username
    NSString *username = [[PFUser currentUser] username];
    
    //Only find their projects
    [query whereKey:@"collaborators" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //Initially unsorted projects
        NSMutableArray *unsorted = [[NSMutableArray alloc] initWithArray:objects];
        
        //Sort by project name
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES];
        self.projects = [[unsorted sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        
        //Refresh the table with the new data
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
    //Find which project was clicked and enter that project's detail page
    self.clickedObject = [self.projects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"projectsToProject" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Remove a project
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Find username and project to delete
        NSString *myUsername = [[PFUser currentUser] valueForKey:@"username"];
        PFObject *projectObject = [self.projects objectAtIndex:indexPath.row];

        //Remove project from local list
        [self.projects removeObject:projectObject];
        
        //Animate deletion of the project
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        //Find the collaborators on the project
        NSMutableArray *collaborators = projectObject[@"collaborators"];
        
        //Fully delete the project if there will be nobody who can see it
        //Otherwise just remove the current user
        if (collaborators.count == 1) {
            
            NSArray *loopDictionaries = projectObject[@"loops"];
            
            //Delete all loops that the project has
            for (int i = 0; i < loopDictionaries.count; i++) {
                PFObject *object = [loopDictionaries objectAtIndex:i];
                PFObject *objectPointer = object[@"id"];
                
                //Make sure that it exists
                if ([objectPointer objectId]){
                    
                    //Find every loop object in this project
                    PFQuery *query = [PFQuery queryWithClassName:@"loopObject"];
                    [query whereKey:@"objectId" equalTo:[objectPointer objectId]];
                    
                    //Delete the first one and repeat (This can almost definitely
                    //be done way more elegantly and without a for loop)
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [object deleteInBackground];
                    }];
                }
            }
            
            //Delete the project container
            [projectObject deleteInBackground];
            
         } else {
            for (NSString *collaborator in collaborators) {
                //Remove current user from list of users that own this project
                if ([collaborator isEqualToString:myUsername]) {
                    [collaborators removeObject:collaborator];
                    break;
                }
            }
             
            //Make sure the changes are reflected online
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
    
    //Sync each cell with a project
    PFObject *currentProject = [self.projects objectAtIndex:indexPath.row];
   
    //Set information and color on the cell
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
        //Recorder needs to know which project to use
        [segue.destinationViewController setProject:self.clickedObject];
    }
}


@end
