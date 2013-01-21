//
//  MasterViewController.h
//  ImageComment
//
//  Created by Wu Wenzhi on 12-12-20.
//  Copyright (c) 2012年 Wu Wenzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "PhotoManageController.h"
#import "MWPhotoBrowser.h"

@interface PhotoListController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, PhotoManageControllerDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic)   NSFetchedResultsController  *fetchedResultsController;
@property (strong, nonatomic)   NSManagedObjectContext      *managedObjectContext;

@end
