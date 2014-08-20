//
//  NMEProjectTableViewCell.h
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMERecorderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;

@end
