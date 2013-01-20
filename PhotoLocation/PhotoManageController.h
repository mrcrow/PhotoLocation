//
//  ImageManageController.h
//  ImageComment
//
//  Created by Wu Wenzhi on 12-12-20.
//  Copyright (c) 2012年 Wu Wenzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoLocationController.h"

@protocol PhotoManageControllerDelegate;

@interface PhotoManageController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoLocationControllerDelegate>

@property (strong, nonatomic)   NSManagedObjectContext          *managedObjectContext;
@property (strong, nonatomic)   PhotoObject                     *content;
@property                       BOOL                            previewMode;

@property (weak, nonatomic) id <PhotoManageControllerDelegate>  delegate;

- (void)initialzeViewButtons;

@end

@protocol PhotoManageControllerDelegate 

- (void)photoManageController:(PhotoManageController *)controller didFinishEditContent:(BOOL)success;

@end