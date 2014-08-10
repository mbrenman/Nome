//
//  NMEDataManager.h
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
//#import "NMEProjectObject.h"

@interface NMEDataManager : NSObject

@property (readonly, strong, nonatomic) NSMutableArray *myProjects;
@property (readonly, strong, nonatomic) NSMutableArray *discoveryProjects;

- (void)getMyProjectsFromServer;
- (void)getDiscoveryProjectsOnServer;

- (void)addProjectToMyProjects: (PFObject *)project;
- (void)removeProjectFromMyProjects: (PFObject *)project;

@end
