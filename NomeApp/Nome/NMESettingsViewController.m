//
//  NMESettingsViewController.m
//  Nome
//
//  Created by Julian Locke on 8/18/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMESettingsViewController.h"
#import "Parse/Parse.h"

@interface NMESettingsViewController ()

@end

@implementation NMESettingsViewController

- (IBAction)logoutButton:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"toSignIn" sender:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:.4 alpha:1.];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
