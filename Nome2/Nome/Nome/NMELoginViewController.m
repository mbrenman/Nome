//
//  NMEViewController.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMELoginViewController.h"

@interface NMELoginViewController ()

@end

@implementation NMELoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginToTabBarPressed:(id)sender {
    [self segueToTabBar];
}

- (void)segueToTabBar{
    [self performSegueWithIdentifier:@"loginToTabBar" sender:self];
}

@end
