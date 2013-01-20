//
//  MasterViewController.m
//  ImageComment
//
//  Created by Wu Wenzhi on 12-12-20.
//  Copyright (c) 2012年 Wu Wenzhi. All rights reserved.
//

#import "PhotoListController.h"

@interface PhotoListController ()
@property                       BOOL            searchWasActive;
@property (strong, nonatomic)   NSMutableArray  *searchedObjects;

@property (strong, nonatomic)   UIBarButtonItem *previewButton;
@property (strong, nonatomic)   UIBarButtonItem *uploadButton;
@property (strong, nonatomic)   UIBarButtonItem *deleteButton;

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PhotoListController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize searchedObjects = _searchedObjects, searchWasActive;
@synthesize previewButton = _previewButton, uploadButton = _uploadButton, deleteButton = _deleteButton;

static NSString *IMPreviewSome  = @"Preview (%d)";
static NSString *IMPreviewAll   = @"Preview All";
static NSString *IMUploadSome   = @"Upload (%d)";
static NSString *IMUploadAll    = @"Upload All";
static NSString *IMDeleteSome   = @"Delete (%d)";
static NSString *IMDeleteAll    = @"Delete All";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"List", @"Image lists");
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self addImageContentButton];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.searchedObjects = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
}
 
- (void)didReceiveMemoryWarning
{
    self.searchWasActive = [self.searchDisplayController isActive];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    if (self.tableView.isEditing)
    {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
    
    NSLog(@"%d", self.tableView.isEditing);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.tableView.isEditing)
    {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
    
    NSLog(@"%d", self.tableView.isEditing);
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
}

- (void)insertImageContent:(id)sender
{     
    PhotoManageController *manageController = [[PhotoManageController alloc] initWithStyle:UITableViewStyleGrouped];
    manageController.delegate = self;
    manageController.managedObjectContext = self.managedObjectContext;
    manageController.previewMode = NO;
    
    UINavigationController *addImageNavigator = [[UINavigationController alloc] initWithRootViewController:manageController];
    
    [self presentViewController:addImageNavigator animated:YES completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [self setSearchedObjects:nil];
    [self setPreviewButton:nil];
    [self setUploadButton:nil];
    [self setDeleteButton:nil];
}

#pragma mark - Editing Overwrite

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.searchDisplayController.searchBar.userInteractionEnabled = !editing;
    self.searchDisplayController.searchBar.alpha = editing ? 0.75: 1.0;
    
    if (editing)
    {
        NSArray *toolbarButtons = [NSArray arrayWithArray:self.toolbarItems];
        if ([toolbarButtons count] == 0)
        {
            [self initialToolbarButtons];
        }
        
        [self removeAddImageContentButton];
    }
    else
    {
        [self addImageContentButton];
    }
    
    [self refreshButtonTitles];
    [self.navigationController setToolbarHidden:!editing animated:YES];
}

#pragma mark - Function Buttons

- (void)initialToolbarButtons
{
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    if (!self.uploadButton)
    {
        _uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload (0)" style:UIBarButtonItemStyleBordered target:self action:@selector(multiPhotoUpload)];
        //_uploadButton.tintColor = [UIColor doneButtonTinColor];
        _uploadButton.enabled = NO;
    }
    
    if (!self.previewButton)
    {
        _previewButton = [[UIBarButtonItem alloc] initWithTitle:@"Preview (0)" style:UIBarButtonItemStyleBordered target:self action:@selector(multiPhotoPreview)];
        //_previewButton.tintColor = [UIColor previewButtonColor];
        _previewButton.enabled = NO;
    }
    
    if (!self.deleteButton)
    {
        _deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete (0)" style:UIBarButtonItemStyleBordered target:self action:@selector(multiPhotoDelete)];
        _deleteButton.tintColor = [UIColor redColor];
        _deleteButton.enabled = NO;
    }
        
    [self setToolbarItems:[NSArray arrayWithObjects:space, _previewButton, _uploadButton, _deleteButton, space, nil] animated:NO];
}

- (void)removeAddImageContentButton
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)addImageContentButton
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertImageContent:)];
    [self.navigationItem setRightBarButtonItem:addButton animated:YES];
}

- (void)multiPhotoPreview
{
    NSArray *selectedIndexPath = [self.tableView indexPathsForSelectedRows];
    
    NSMutableArray *photos = [NSMutableArray array];
    for (NSIndexPath *indexPath in selectedIndexPath)
    {
       
    }

}

- (void)showImageContentDeleteWarning
{
    UIActionSheet *deleteWarning = [[UIActionSheet alloc] initWithTitle:@"Delete selected images?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
    [deleteWarning showFromToolbar:self.navigationController.toolbar];
}

- (void)multiPhotoDelete
{
    NSArray *selectedIndexPath = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedIndexPath)
    {
        [self deleteImageContentAtIndexPath:indexPath];
    }
}

- (void)deleteImageContentAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    ImageContent *content = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:content.folderPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:content.folderPath error:NULL];
        NSLog(@"delete image folder at path: %@", content.folderPath);
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:content];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    */
}

- (void)multiPhotoUpload
{
    
}

- (void)refreshButtonTitles
{
    NSArray *selectedIndexPath = [self.tableView indexPathsForSelectedRows];
    
    //enablle or unable buttons
    if ([selectedIndexPath count] != 0)
    {
        _previewButton.enabled = YES;
        _uploadButton.enabled = YES;
        _deleteButton.enabled = YES;
    }
    else
    {
        _previewButton.enabled = NO;
        _uploadButton.enabled = NO;
        _deleteButton.enabled = NO;
    }
    
    //manage button title
    if ([selectedIndexPath count] != [[self.fetchedResultsController fetchedObjects] count])
    {
        _previewButton.title = [NSString stringWithFormat:IMPreviewSome, [selectedIndexPath count]];
        _uploadButton.title = [NSString stringWithFormat:IMUploadSome, [selectedIndexPath count]];
        _deleteButton.title = [NSString stringWithFormat:IMDeleteSome, [selectedIndexPath count]];
    }
    else
    {
        _previewButton.title = IMPreviewAll;
        _uploadButton.title = IMUploadAll;
        _deleteButton.title = IMDeleteAll;
    }
}

#pragma mark - ActionSheet Delegate: Delete ImageContents

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
    {
        return [[self.fetchedResultsController sections] count];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return [self.searchedObjects count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILongPressGestureRecognizer *previewGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(previewContent:)];
        previewGesture.minimumPressDuration = 1.0;
        [cell addGestureRecognizer:previewGesture];
    }
    
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (tableView == self.tableView)
    {
        ImageContent *imageContent = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = imageContent.name;
        cell.detailTextLabel.text = imageContent.comment;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    else
    {
        ImageContent *imageContent = [self.searchedObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = imageContent.name;
        cell.detailTextLabel.text = imageContent.comment;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
     */
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView == self.tableView ? YES : NO;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ImageContent *content = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:content.folderPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:content.folderPath error:NULL];
            NSLog(@"delete image folder at path: %@", content.folderPath);
        }
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:content];
        
        NSError *error = nil;
        if (![context save:&error])
        {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}
*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - Preview and Selection

- (void)previewContent:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }

    ImageContent *imageContent = nil;
    if ([self.searchDisplayController isActive])
    {
        NSInteger selectedRow = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint:[gesture locationInView:self.searchDisplayController.searchResultsTableView]].row;
        imageContent = [self.searchedObjects objectAtIndex:selectedRow];
    }
    else
    {
        NSIndexPath *selectedPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
        imageContent = [self.fetchedResultsController objectAtIndexPath:selectedPath];
    }
    
    Photo *photo = [[Photo alloc] initWithLocalPhotoPath:imageContent.imagePath name:imageContent.imageName];

    EGOPhotoViewController *viewController = [[EGOPhotoViewController alloc] initWithPhoto:photo];
        
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.isEditing)
    {
        ImageContent *imageContent = nil;
        
        if (tableView == self.tableView)
        {
            imageContent = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        else
        {
            imageContent = [self.searchedObjects objectAtIndex:indexPath.row];
        }
        
        ImageManageController *manageController = [[ImageManageController alloc] initWithStyle:UITableViewStyleGrouped];
        manageController.managedObjectContext = self.managedObjectContext;
        manageController.content = imageContent;
        manageController.previewMode = YES;
        
        [self.navigationController pushViewController:manageController animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [self refreshButtonTitles];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        [self refreshButtonTitles];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageContent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ImageCache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self tableView:tableView configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}

#pragma mark Search Display Controller

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	[self.searchedObjects removeAllObjects]; 
	
    for (ImageContent *content in [self.fetchedResultsController fetchedObjects])
    {
        NSComparisonResult nameCompare = [content.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
         NSComparisonResult commentCompare = [content.comment compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (nameCompare == NSOrderedSame || commentCompare == NSOrderedSame)
        {
            [self.searchedObjects addObject:content];
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - ImageManageController Delegate

- (void)photoManagerController:(PhotoManageController *)controller didFinishEditContent:(BOOL)success
{
    if (success)
    {
        [self.tableView reloadData];
    }
}

@end
