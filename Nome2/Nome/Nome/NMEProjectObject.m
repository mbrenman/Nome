//
//  NMEProjectObject.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEProjectObject.h"


@interface NMEProjectObject ()

@end

@implementation NMEProjectObject

- (id)init{
    if(self = [super init]){
        //
    }
    return self;
}

- (id)initWithProjectName: (NSString *)projName
            Collaborators: (NSArray *) collabs
                      BPM: (NSInteger)bpm
               TotalBeats: (NSInteger)totalBeats
                     Tags: (NSArray *)tags
                    Loops: (NSArray *)loops {
    
    if (self = [super init]) {
        NMEProjectObject *projectObject = [[NMEProjectObject alloc] init];
        projectObject[@"projectName"] = projName;
        projectObject[@"collaborators"] = collabs;
        projectObject[@"bpm"] = @(bpm);
        projectObject[@"totalBeats"] = @(totalBeats);
        projectObject[@"tags"] = tags;
    }
    return self;
}

@end
