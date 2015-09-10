//
//  AppDelegate.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MSDynamicsDrawerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
