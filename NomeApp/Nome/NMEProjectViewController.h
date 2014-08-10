//
//  NMEProjectViewController.h
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import <AVFoundation/AVFoundation.h>

@interface NMEProjectViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic,strong) PFObject *project;

@end
