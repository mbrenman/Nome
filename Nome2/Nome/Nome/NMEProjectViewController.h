//
//  NMEProjectViewController.h
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface NMEProjectViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) PFObject *project;

@end
