//
//  ImageManageController.m
//  ImageComment
//
//  Created by Wu Wenzhi on 12-12-20.
//  Copyright (c) 2012年 Wu Wenzhi. All rights reserved.
//

#import "PhotoManageController.h"

#define BIG_CELL_HEIGHT 200.0
#define SMALL_CELL_HEIGHT 58.0

@interface PhotoManageController ()
@property (strong, nonatomic)   UITextField             *nameField;
@property (strong, nonatomic)   UITextView              *commentView;

@property (strong, nonatomic)   NSMutableArray          *previewPhoto;
@property                       BOOL                    newMedia;

@property (strong, nonatomic)   UIActionSheet           *imageSelectionSheet;
@property (strong, nonatomic)   UIActionSheet           *cancelActionSheet;

@end

@implementation PhotoManageController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize nameField = _nameField, commentView = _commentView;
@synthesize photo = _photo;
@synthesize newMedia, previewMode;
@synthesize delegate;
@synthesize previewPhoto = _previewPhoto;
@synthesize imageSelectionSheet = _imageSelectionSheet, cancelActionSheet = _cancelActionSheet;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Photo", @"Photo object");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self initialzeViewButtons];
    
    if (!previewMode)
    {
        [self createPhotoObjectAndStoragePath];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setNameField:nil];
    [self setCommentView:nil];
    [self setImageSelectionSheet:nil];
    [self setCancelActionSheet:nil];
    [self setDelegate:nil];
    [self setPhoto:nil];
    [self setPreviewPhoto:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [delegate photoManageController:self didFinishEditPhoto:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Object and Folder

- (void)createPhotoObjectAndStoragePath
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoObject" inManagedObjectContext:context];
    _photo = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    _photo.date = [NSDate date];
    _photo.storagePath = [IMAGE_BOX_PATH stringByAppendingPathComponent:[self stringFromDate:_photo.date]];
    
    NSLog(@"Created image folder at path: %@", _photo.storagePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_photo.storagePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_photo.storagePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return [formatter stringFromDate:date];
}

#pragma mark - Button functions

- (void)initialzeViewButtons
{
    if (previewMode)
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else
    {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showImageSelectionSheet)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:doneButton, cameraButton, nil];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

- (void)cancel
{
    if (!self.cancelActionSheet)
    {
        _cancelActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Photo record will not be saved", @"Cancel warning") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [_cancelActionSheet showInView:self.view];
}

- (void)done
{
    if ([_nameField.text length] != 0 && [_photo.hasPhoto boolValue] && [_photo.hasLocation boolValue])
    {
        [self savePhotoObject];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The photo attributes are not completed!" message:@"Please check the completeness of name, image and location information and save again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
    [self.commentView setEditable:editing];
    [self.nameField setEnabled:editing];
    
    if (!editing)
    {
        [self savePhotoObject];
        [self allResignFirstResponse];
    }
}

- (void)allResignFirstResponse
{
    if (_commentView.isFirstResponder)
    {
        [_commentView resignFirstResponder];
    }
    
    if (_nameField.isFirstResponder)
    {
        [_nameField resignFirstResponder];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self allResignFirstResponse];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return NSLocalizedString(@"Photo", @"Photo");
        case 1: return NSLocalizedString(@"Location", @"Location");
        default: return NSLocalizedString(@"Comments", @"Comments");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 2: return NSLocalizedString(@"Typing symbols like '.', '!' or '?' can start a new paragraph.", @"Comment Tip");
        default: return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *numberOfRows = [NSArray arrayWithObjects:
                             [NSNumber numberWithInteger:2],
                             [NSNumber numberWithInteger:1],
                             [NSNumber numberWithInteger:1],
                             nil];
    return [[numberOfRows objectAtIndex:section] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    switch (section)
    {
        case 0: return [self cellForPhotoAttributeAtIndex:indexPath.row];
        case 1: return [self cellForPhotoLocation];
        default: return [self cellForPhotoComments];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) //Comment
    {
        return BIG_CELL_HEIGHT;
    }
    
    return [self.tableView rowHeight];
}

#pragma mark - UITableView Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //select image cell
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            if (previewMode)
            {
                [self pushImagePreviewView];
            }
            else
            {
                if ([_photo.hasPhoto boolValue])
                {
                    [self pushImagePreviewView];
                }
                else
                {
                    [self showImageSelectionSheet];
                }
            }
        }
    }
    
    //select location cell
    if (indexPath.section == 1)
    {
        [self pushLocationViewAllowEditing:previewMode];
    }
}

- (void)showImageSelectionSheet
{
    if (!self.imageSelectionSheet)
    {
        _imageSelectionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @"Use camera"), NSLocalizedString(@"Photo Album", @"Select from photo album"), nil];
    }
    
    [_imageSelectionSheet showInView:self.view];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)pushImagePreviewView
{
    [self prepareForPreviewPhoto];
    
    MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithContentsOfFile:_photo.photoPath]];
    
    [_previewPhoto addObject:photo];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = previewMode;
    browser.wantsFullScreenLayout = YES;
    
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)pushLocationViewAllowEditing:(BOOL)allow
{
    //push location view
    PhotoLocationController *locationController = [[PhotoLocationController alloc] initWithNibName:@"PhotoLocationController" bundle:nil];
    locationController.photo = self.photo;
    locationController.delegate = self;
    locationController.previewMode = allow;
    locationController.managedObjectContext = self.managedObjectContext;
    
    [self.navigationController pushViewController:locationController animated:YES];
}

#pragma mark - Prepare Preview

- (void)prepareForPreviewPhoto
{
    if (self.previewPhoto)
    {
        [_previewPhoto removeAllObjects];
    }
    else
    {
        _previewPhoto = [NSMutableArray array];
    }
}

#pragma mark - Table Cells

- (UITableViewCell *)cellForPhotoAttributeAtIndex:(NSInteger)index
{
    switch (index)
    {
        case 0: return [self cellForPhotoName];
        default: return [self cellForPhotoView];
    }
}

- (UITableViewCell *)cellForPhotoName
{
    static NSString *cellID = @"PhotoNameCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
    }
    
    if (!self.nameField)
    {
        self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 8, 225, 30)];
        _nameField.delegate = self;
        _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _nameField.placeholder = @"e.g. Sai Kung";
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameField.textColor = [UIColor tableViewCellTextBlueColor];
        _nameField.textAlignment = UITextAlignmentRight;
        [_nameField setReturnKeyType:UIReturnKeyDone];
        [_nameField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        self.nameField.enabled = !previewMode;
    }
    
    _nameField.text = _photo.name;
    [cell addSubview:self.nameField];
    
    return cell;
}

- (UITableViewCell *)cellForPhotoView
{
    static NSString *cellID = @"PhotoViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.textLabel.text = NSLocalizedString(@"Image", @"Image");
    cell.detailTextLabel.textColor = [UIColor tableViewCellTextBlueColor];
    
    if ([_photo.hasPhoto boolValue])
    {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.detailTextLabel.text = NSLocalizedString(@"No Image", @"Content has no image");
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell *)cellForPhotoComments
{
    static NSString *cellID = @"PhotoCommentsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.commentView = [[UITextView alloc] initWithFrame:CGRectMake(12, 5, 295, 190)];
        _commentView.backgroundColor = [UIColor tableViewCellBackgroundColor];
        _commentView.delegate = self;
        _commentView.textColor = [UIColor tableViewCellTextBlueColor];
        [_commentView setReturnKeyType:UIReturnKeyDone];
        [_commentView setFont:[UIFont systemFontOfSize:17.0]];
        _commentView.scrollEnabled = YES;
        
        if (previewMode)
        {
            self.commentView.editable = self.tableView.isEditing;
        }
        else
        {
            self.commentView.editable = YES;
        }
        
        [cell addSubview:self.commentView];
    }
    
    _commentView.text = _photo.comment;
    
    return cell;
}

- (UITableViewCell *)cellForPhotoLocation
{
    static NSString *cellID = @"PhotoLocationCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = @"Coordinate";
    
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    
    if ([_photo.hasLocation boolValue])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.3f, λ:%.3f", [_photo.latitude doubleValue], [_photo.longitude doubleValue]];
    }
    else
    {
        cell.detailTextLabel.text = @"Unknown";
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITextField & UITextView Delegate Methods

- (void)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //if the textfield is empty, the white space is not allowed
    if ([textField.text length] == 0)
    {
        if ([string isEqualToString:@" "])
        {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _photo.name = textField.text;
}

- (BOOL)enableEnterKeyForTextView:(UITextView *)view
{
    if ([view.text hasSuffix:@"."] || [view.text hasSuffix:@"。"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"?"] || [view.text hasSuffix:@"？"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"!"] || [view.text hasSuffix:@"！"]) {
        return YES;
    }
    if ([view.text hasSuffix:@"~"] || [view.text hasSuffix:@"～"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if (![self enableEnterKeyForTextView:textView]) {
            [textView resignFirstResponder];
            // Return FALSE so that the final '\n' character doesn't get added
            return NO;
        }
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _photo.comment = textView.text;
}

#pragma mark - UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //control image capture
    if (actionSheet == _imageSelectionSheet)
    {
        switch (buttonIndex)
        {
            case 0: {
                [self useCamera];
            } break;
                
            case 1: {
                [self usePhotoAlbum];
            } break;
                
            default:
                break;
        }
    }
    
    //control cancel action
    if (actionSheet == _cancelActionSheet)
    {
        switch (buttonIndex)
        {
            case 0:{
                [self deletePhotoObject];
                [self dismissModalViewControllerAnimated:YES];
            } break;
                
            default:
                //do nothing
                break;
        }
    }
}

#pragma mark - Delete Content

- (void)deletePhotoObject
{
    //remove image folder
    if ([[NSFileManager defaultManager] fileExistsAtPath:_photo.storagePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_photo.storagePath error:NULL];
    }
    
    NSLog(@"Deleted image folder at path: %@", _photo.storagePath);
    
    //delete image item in database
    NSManagedObjectContext *context = self.managedObjectContext;
    [context deleteObject:_photo];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Image Picker Delegate Methods

- (void)useCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.delegate = self;
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerView.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        pickerView.allowsEditing = NO;
        pickerView.showsCameraControls = YES;
        [self presentModalViewController:pickerView animated:YES];
        
        newMedia = YES;
    }
}

- (void)usePhotoAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.delegate = self;
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerView.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        pickerView.allowsEditing = NO;
        [self presentModalViewController:pickerView animated:YES];
        newMedia = NO;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        
        //get image and storage path
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSString *path = [[_photo.storagePath stringByAppendingPathComponent:[self stringFromDate:[NSDate date]]] stringByAppendingPathExtension:@"jpeg"];
        NSLog(@"Image should save to path: %@", path);
        
        //empty the images in folder
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *folderContents = [fileManager contentsOfDirectoryAtPath:_photo.storagePath error:NULL];
        
        if ([folderContents count] != 0)
        {
            for (NSString *pathComponent in folderContents)
            {
                NSString *filePath = [_photo.storagePath stringByAppendingPathComponent:pathComponent];
                NSLog(@"Check image at path: %@",filePath);
                
                if ([fileManager fileExistsAtPath:filePath])
                {
                    [fileManager removeItemAtPath:filePath error:NULL];
                }
            }
        }
        
        //create image to folder
        [fileManager createFileAtPath:path contents:UIImageJPEGRepresentation(image, 1.0) attributes:nil];
        
        _photo.photoPath = path;
        _photo.hasPhoto = [NSNumber numberWithBool:YES];
        
        if (newMedia)
        {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), NULL);
        }
        
        [self.tableView reloadData];
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:[NSString stringWithFormat:@"Failed to save the captured image into Photo Album, please check this image at file path: %@", _photo.storagePath]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Photo Location Controller Delegate

- (void)photoLocationController:(PhotoLocationController *)controller didFinishLocatePhoto:(BOOL)success
{
    if (success)
    {
        [self.tableView reloadData];
    }
}

#pragma mark - PhotoObject save

- (void)savePhotoObject
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - MWPhotoBrowser Delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [_previewPhoto count];
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < [_previewPhoto count])
    {
        return [_previewPhoto objectAtIndex:index];
    }
    
    return nil;
}

@end
