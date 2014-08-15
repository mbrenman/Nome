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

@interface NMEAddProjectViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *colabAdd;
@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *collaboratorsTextField;
@property (strong, nonatomic) IBOutlet UILabel *collaboratorsLabel;
@property (strong, nonatomic) IBOutlet UITextField *bpmTextField;
@property (strong, nonatomic) IBOutlet UITextField *totalBeatsTextField;
@property (strong, nonatomic) IBOutlet UIButton *finalButton;

@property (strong, nonatomic) UITapGestureRecognizer* tapRecognizer;

@property (strong, nonatomic) NSMutableArray *collaboratorsArray;

@end

@implementation NMEAddProjectViewController
- (IBAction)addCollaboratorButtonPressed:(id)sender {

    NSString *toAdd =self.collaboratorsTextField.text;
    if (![toAdd isEqualToString:@""]) {
        [self.collaboratorsArray addObject:toAdd];
    }
    
    
    
    NSString *total = [[NSString alloc]init];
    for (NSString *string in self.collaboratorsArray) {
        total = [total stringByAppendingString:string];
        total = [total stringByAppendingString:@" "];
    }
    self.collaboratorsLabel.text = total;
    self.collaboratorsTextField.text = @"";

    [self tapped];
}
//- (IBAction)addTagPressed:(id)sender {
//    NSString *toAdd =self.tagsTextField.text;
//    if (![toAdd isEqualToString:@""]) {
//        [self.tagsArray addObject:toAdd];
//    }
//    
//    NSString *total = [[NSString alloc]init];
//    for (NSString *string in self.tagsArray) {
//        total = [total stringByAppendingString:string];
//        total = [total stringByAppendingString:@" "];
//    }
//    self.tagsLabel.text = total;
//    self.tagsTextField.text = @"";
//    
//    [self tapped];
//}

- (IBAction)pushToParse:(id)sender {
    [self finalProjectTapped:nil];
}


- (IBAction)finalProjectTapped:(id)sender {
    NSLog(@"FINALIZE");
    NSString *projectName = self.projectNameTextField.text;
    NSArray *collaborators = self.collaboratorsArray;
    NSString *bpm = self.bpmTextField.text;
    NSString *totalBeats = self.totalBeatsTextField.text;
//    NSArray *tags = self.tagsArray;
    NSArray* loops = [[NSArray alloc] init];
    
    if ([projectName isEqualToString:@""] ||
        (collaborators.count < 1) ||
        [bpm isEqualToString:@""] ||
         [totalBeats isEqualToString:@""]) {
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
        projectObject[@"collaborators"] = collaborators;
        projectObject[@"bpm"] = @([bpm integerValue]);
        projectObject[@"totalBeats"] = @([totalBeats integerValue]);
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
    
    self.collaboratorsArray = [[NSMutableArray alloc] init];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.enabled = NO;
    
    [self.projectNameTextField setDelegate:self];
    [self.projectNameTextField setTag:projectName];
    
    [self.collaboratorsTextField setDelegate:self];
    [self.collaboratorsTextField setTag:collaborators];
    
    [self.bpmTextField setDelegate:self];
    [self.bpmTextField setTag:bpm];
    
    [self.totalBeatsTextField setDelegate:self];
    [self.totalBeatsTextField setTag:totalBeats];
    
    [self.collaboratorsLabel setText:@""];
//    [self.tagsLabel setText:@""];
    
    self.collaboratorsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.collaboratorsLabel.numberOfLines = 0;
    self.collaboratorsLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];

//    self.tagsLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    self.tagsLabel.numberOfLines = 0;
//    self.tagsLabel.textColor = [UIColor colorWithWhite:.95 alpha:1.];
//
//    
    self.finalButton.backgroundColor = [UIColor colorWithHue:.03 saturation:.64 brightness:1. alpha:1.];
    self.finalButton.font = [UIFont fontWithName:@"Avenir" size:38];
    
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.2 alpha:1.];
    self.colabAdd.font = [UIFont fontWithName:@"Avenir" size:14];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
