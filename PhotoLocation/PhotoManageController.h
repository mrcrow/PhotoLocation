//
//  ImageManageController.h
//  ImageComment
//
//  Created by Wu Wenzhi on 12-12-20.
//  Copyright (c) 2012年 Wu Wenzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MWPhotoBrowser.h"
#import "PhotoLocationController.h"

@protocol PhotoManageControllerDelegate;

@interface PhotoManageController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoLocationControllerDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic)   NSManagedObjectContext          *managedObjectContext;
@property (strong, nonatomic)   PhotoObject                     *photo;
@property                       BOOL                            previewMode;

@property (weak, nonatomic) id <PhotoManageControllerDelegate>  delegate;

- (void)initialzeViewButtons;

@end

@protocol PhotoManageControllerDelegate 

- (void)photoManageController:(PhotoManageController *)controller didFinishEditPhoto:(BOOL)success;

@end