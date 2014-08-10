//
//  NMEAppDelegate.m
//  Nome
//
//  Created by Julian Locke on 8/9/14.
//  Copyright (c) 2014 Julian Locke. All rights reserved.
//

#import "NMEAppDelegate.h"
#import "NMESecrets.h"
#import <Parse/Parse.h>
#import <Venmo-iOS-SDK/Venmo.h>

@interface NMEAppDelegate ()

@property (strong, nonatomic) NMEDataManager *dataManager;

@end

@implementation NMEAppDelegate

+(instancetype)delegate {
    return (NMEAppDelegate *)([UIApplication sharedApplication].delegate);
}

- (NMEDataManager *)dataManager{
    if (!_dataManager) {
        _dataManager = [[NMEDataManager alloc] init];
    }
    return _dataManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Venmo startWithAppId:venmoID secret:venmoKey name:@"Nome"];

    
    //Setting up Parse
    [Parse setApplicationId: parseAppID
                  clientKey: parseClientKey];
    
    //Parse Analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
