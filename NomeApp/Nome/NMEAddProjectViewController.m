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
    totalBeats,
    tags,
} textFields;

#import "NMEAddProjectViewController.h"
#import "Parse/Parse.h"

@interface NMEAddProjectViewController () <UITextFieldDelegate,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *bpmTextField;
@property (strong, nonatomic) IBOutlet UITextField *totalBeatsTextField;
@property (strong, nonatomic) IBOutlet UITextField *beatsPerMeasureTextField;
@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NMEAddProjectViewController

- (IBAction)finalProjectTapped:(id)sender {
    NSLog(@"FINALIZE");
    NSString *projectName = self.projectNameTextField.text;
    NSString *bpm = self.bpmTextField.text;
    NSString *totalBeats = self.totalBeatsTextField.text;
    NSString *beatsPerMeasure = self.beatsPerMeasureTextField.text;
    NSArray* loops = [[NSArray alloc] init];
    
    if ([projectName isEqualToString:@""] ||
        [bpm isEqualToString:@""]         ||
        [totalBeats isEqualToString:@""]  ||
        [totalBeats isEqualToString:@""])   {
        
        //Also we need to make sure that the bpm and totalbeats are integers
        UIAlertView *badInfo = [[UIAlertView alloc]
                                initWithTitle:@"Bad info"
                                message:@"Please make sure to fill all the fields!"
                                delegate:self
                                cancelButtonTitle:@"Dismiss"
                                otherButtonTitles: nil];
        [badInfo show];
    } else {
        PFObject *projectObject = [[PFObject alloc] initWithClassName:@"projectObject"];
        projectObject[@"projectName"] = projectName;
        projectObject[@"collaborators"] = @[[[PFUser currentUser] username]];
        projectObject[@"bpm"] = @([bpm integerValue]);
        projectObject[@"totalBeats"] = @([totalBeats integerValue] * [beatsPerMeasure integerValue]);
        projectObject[@"beatsPerMeasure"] = @([beatsPerMeasure integerValue]);
        projectObject[@"loops"] = loops;
        [projectObject saveInBackground];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    self.inUseTextField = textField;
    NSLog(@"began");
    self.tapRecognizer.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"ended");
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
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.enabled = NO;
    
    [self.projectNameTextField setDelegate:self];
    [self.projectNameTextField setTag:projectName];
    
    [self.bpmTextField setDelegate:self];
    [self.bpmTextField setTag:bpm];
    
    [self.totalBeatsTextField setDelegate:self];
    [self.totalBeatsTextField setTag:totalBeats];
    
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];

    // Do any additional setup after loading the view.
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
