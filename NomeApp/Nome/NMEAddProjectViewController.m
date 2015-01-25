//
//  NMEAddProjectViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

typedef enum : NSUInteger {
    projectName,
    collaborators,
    bpm,
    numMeasures,
    tags,
} textFields;

#import "NMEAddProjectViewController.h"
#import "Parse/Parse.h"

const int BPM_MAX = 500;
const int BEATS_PER_MEASURE_MAX = 20;
const int NUM_MEASURES_MAX = 40;

@interface NMEAddProjectViewController () <UITextFieldDelegate,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *bpmTextField;

@property (weak, nonatomic) IBOutlet UITextField *numMeasuresTextField;

@property (strong, nonatomic) IBOutlet UITextField *beatsPerMeasureTextField;
@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NMEAddProjectViewController

- (IBAction)finalProjectTapped:(id)sender {
    
    //Get all of the info that was typed in
    NSString *projectName = self.projectNameTextField.text;
    NSString *bpm = self.bpmTextField.text;
    NSString *numMeasures = self.numMeasuresTextField.text;
    NSString *beatsPerMeasure = self.beatsPerMeasureTextField.text;
    NSArray* loops = [[NSArray alloc] init];
    
    //Check that user entered information for every field
    if ([projectName isEqualToString:@""] ||
        [bpm isEqualToString:@""]         ||
        [numMeasures isEqualToString:@""]  ||
        [beatsPerMeasure isEqualToString:@""])   {
        
        UIAlertView *badInfo = [[UIAlertView alloc]
                                initWithTitle:@"Bad info"
                                message:@"Please make sure to fill all the fields!"
                                delegate:self
                                cancelButtonTitle:@"Dismiss"
                                otherButtonTitles: nil];
        [badInfo show];
    } else if ([bpm integerValue] < 1 ||
               [numMeasures integerValue] < 1 ||
               [beatsPerMeasure integerValue] < 1) {
        
        //Checking for numbers that are zero or non-numbers
        UIAlertView *badInfo = [[UIAlertView alloc]
                                initWithTitle:@"Bad info"
                                message:@"Make sure the number fields are positive numbers!"
                                delegate:self
                                cancelButtonTitle:@"Dismiss"
                                otherButtonTitles: nil];
        [badInfo show];
    } else if ([bpm integerValue] > BPM_MAX ||
               [numMeasures integerValue] > NUM_MEASURES_MAX ||
               [beatsPerMeasure integerValue] > BEATS_PER_MEASURE_MAX) {
        //Checking that numbers are not above limits
        UIAlertView *badInfo = [[UIAlertView alloc]
                                initWithTitle:@"Bad info"
                                message:@"Some of your numbers are too high!"
                                delegate:self
                                cancelButtonTitle:@"Dismiss"
                                otherButtonTitles: nil];
        [badInfo show];
    } else {
        
        //Create a new project
        PFObject *projectObject = [[PFObject alloc] initWithClassName:@"projectObject"];
        
        //Set new project's information
        projectObject[@"projectName"] = projectName;
        projectObject[@"collaborators"] = @[[[PFUser currentUser] username]];
        projectObject[@"bpm"] = @([bpm integerValue]);
        projectObject[@"totalBeats"] = @([numMeasures integerValue] * [beatsPerMeasure integerValue]);
        projectObject[@"beatsPerMeasure"] = @([beatsPerMeasure integerValue]);
        projectObject[@"loops"] = loops;
        
        //Save the new project
        [projectObject saveInBackground];
        
        //Go back to project listing page
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.tapRecognizer.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.tapRecognizer.enabled = NO;
}

-(void)tapped{
    NSLog(@"Tapped");
    if ([self.view endEditing:NO]) {
//
    } else {
        [self.view endEditing:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //To clear keyboard when tapping to close
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.enabled = NO;
    
    //Set up fields
    [self.projectNameTextField setDelegate:self];
    [self.projectNameTextField setTag:projectName];
    
    [self.bpmTextField setDelegate:self];
    [self.bpmTextField setTag:bpm];
    
    [self.numMeasuresTextField setDelegate:self];
    [self.numMeasuresTextField setTag:numMeasures];
    
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
