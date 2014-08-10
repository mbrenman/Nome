//
//  NMEDiscoverTableCell.m
//  Nome
//
//  Created by Julian Locke on 8/10/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEDiscoverTableCell.h"

@implementation NMEDiscoverTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
