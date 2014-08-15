//
//  NMEDataManager.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//
//
//#import "NMEDataManager.h"
//
//@interface NMEDataManager ()
//
//@property (strong, nonatomic) NSMutableArray *myProjects;
//@property (strong, nonatomic) NSMutableArray *discoveryProjects;
//
//@property (strong, nonatomic) NSMutableArray *serverMyProjects;
//@property (strong, nonatomic) NSMutableArray *serverDiscoveryProjects;
//
//@end
//
//@implementation NMEDataManager
//
//- (id)init{
//    if(self = [super init]){
//        _myProjects = [[NSMutableArray alloc] init];
//        _discoveryProjects = [[NSMutableArray alloc] init];
//        _serverMyProjects = [[NSMutableArray alloc] init];
//        _serverDiscoveryProjects = [[NSMutableArray alloc] init];
//        
//        for (NSInteger i = 0; i<10; i++) {
//            PFObject *projectObject = [[PFObject alloc] initWithClassName:@"projectObject"];
//            projectObject[@"projectName"] = @"Project Name";
//            projectObject[@"collaborators"] = @[@"Bob",@"Bill",@"John",@"Lucy"];
//            projectObject[@"bpm"] = @(i);
//            projectObject[@"totalBeats"] = @(i*40);
//            projectObject[@"tags"] = @[@"drumstep",@"hard rock",@"awesome",@"lion"];
//            projectObject[@"loops"] = @[@{@"name" : @"1", @"creator" : @"matt", @"id": @"1234"},
//                                        @{@"name" : @"1", @"creator" : @"matt", @"id": @"1234"},
//                                        @{@"name" : @"1", @"creator" : @"matt", @"id": @"1234"},
//                                        @{@"name" : @"1", @"creator" : @"matt", @"id": @"1234"},
//                                        ];
//            [_serverMyProjects addObject:projectObject];
//        }
//    }
//    return self;
//}
//
//- (void)getMyProjectsFromServer{
//    self.myProjects = self.serverMyProjects;
//}
//
//- (void)getDiscoveryProjectsOnServer{
//    self.discoveryProjects = self.serverDiscoveryProjects;
//}
//
//- (void)addProjectToMyProjects: (PFObject *)project{
//    [self.serverMyProjects addObject:project];
//}
//
//- (void)removeProjectFromMyProjects: (PFObject *)project{
//    [self.serverMyProjects removeObject:project];
//}
//@end
