//
//  NMEProjectViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEProjectViewController.h"
#import "NMEProjectTableViewCell.h"
#import "NMEAppDelegate.h"
#import "NMEDataManager.h"

@interface NMEProjectViewController () 

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;

@property (strong, nonatomic) IBOutlet UITableView  *tableView;

@end

@implementation NMEProjectViewController

- (IBAction)recordButtonPressed:(id)sender {
    
}
- (IBAction)playButtonPressed:(id)sender {
    
}
- (IBAction)pressedStopButton:(id)sender {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.projectNameLabel = self.project[@"name"];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0., 0., 320, 320);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NMEProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectTableCell"];
    
    if (!cell) {
        cell = [[NMEProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"projectTableCell"];
    }
    
    PFObject *currentProject = self.project;
    
    //    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    NSDictionary *loop = [currentProject[@"loops"] objectAtIndex:indexPath.row];
    
    cell.loopNameLabel.text = [loop objectForKey:@"name"];
    
    cell.loopNameLabel.font = [UIFont fontWithName:@"Avenir" size:18];
    cell.loopNameLabel.textColor = [UIColor colorWithWhite:.35 alpha:1.];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.'
    NSLog(@"COUNT! %u",[self.project[@"loops"] count]);

    return [self.project[@"loops"] count];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.clickedObject = [self.project objectAtIndex:indexPath.row];
//    [self performSegueWithIdentifier:@"projectsToProject" sender:self];
//}

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
