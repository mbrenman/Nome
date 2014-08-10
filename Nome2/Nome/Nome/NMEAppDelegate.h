//
//  NMEAppDelegate.h
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NMEDataManager.h"

@interface NMEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NMEDataManager *dataManager;

+(instancetype)delegate;

@end
