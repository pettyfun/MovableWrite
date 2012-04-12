//
//  FolderViewController.m
//  PettyFunNote
//
//  Created by YJ Park on 11/14/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "PFFolderViewController.h"
#import "PFFileNavController.h"
#import "PFUtils.h"

@implementation PFFolderViewController
@synthesize labelTextColor;

#pragma mark -
#pragma mark Initialization

-(id) initWithStyle:(UITableViewStyle)style path:(NSString *)folderPath {
    if ((self = [super initWithStyle:style])) {
        path = [folderPath retain];
        folders = [[NSMutableArray alloc] init];
        files = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) loadFolderFiles {
    [folders removeAllObjects];
    [files removeAllObjects];
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    NSArray *items = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    DECLARE_PFFileNavController;
    for (NSString *item in items) {
        BOOL isDir;
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&isDir]) {
            if (isDir) {
                [folders addObject:item];
            }else {
                if ([navController isValidFile:item]) {
                    [files addObject:item];
                    NSLog(@"item path= %@, %@", path, item);
                }
            }
        }
    }
    [folders sortUsingSelector:@selector(localizedStandardCompare:)];
    [files sortUsingComparator:(NSComparator)^(id file1, id file2){
        NSString *itemPath = [path stringByAppendingPathComponent:file1];
        NSString *name1 = [navController.nameMap valueForKey:itemPath];
        itemPath = [path stringByAppendingPathComponent:file2];
        NSString *name2 = [navController.nameMap valueForKey:itemPath];
        if (name1 && name2) {
            return [name1 localizedStandardCompare:name2]; 
        } else if (name1) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (name2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return [file1 localizedStandardCompare:file2]; 
    }];    
    [self.tableView reloadData];
}

-(void) onOperate {
    if (selectedItemRef) {
        NSString *itemPath = [path stringByAppendingPathComponent:selectedItemRef];
        DECLARE_PFFileNavController;
        navController.selectedPath = itemPath;
        [navController finishNav];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    selectedItemRef = nil;
    DECLARE_PFFileNavController
    self.navigationItem.rightBarButtonItem = 
    [[[UIBarButtonItem alloc] initWithTitle:[navController getOperationTitle]
                                      style:UIBarButtonItemStyleDone
                                     target:self action:@selector(onOperate)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if ([navController.nameMap valueForKey:path]) {
        self.navigationItem.title = [navController.nameMap valueForKey:path];
    }
    [navController updateStyle:self];
    
    [self loadFolderFiles];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return [folders count];
    } else if (section == 1) {
        return [files count];
    } else {
        return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PFFolderViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if (labelTextColor) {
            cell.textLabel.textColor = labelTextColor;
        }
    }
    DECLARE_PFFileNavController
    NSString *item = nil;
    if (indexPath.section == 0) {
        item = [folders objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        item = [files objectAtIndex:indexPath.row];
    }
    NSString *itemPath = [path stringByAppendingPathComponent:item];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        if ([navController canSelectFile:itemPath]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    if ([navController.nameMap valueForKey:itemPath]) {
        cell.textLabel.text = [navController.nameMap valueForKey:itemPath];
    } else {
        cell.textLabel.text = item;
    }

    return cell;
}

/*
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
    }
}
*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1) {
        DECLARE_PFFileNavController;
        return [navController canDeleteFile];
    }
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 1) {
            NSString *item = [files objectAtIndex:indexPath.row];
            DECLARE_PFFileNavController;
            NSString *itemPath = [path stringByAppendingPathComponent:item];
            if ([navController deleteFile:itemPath]) {
                // Delete the row from the data source.
                [files removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DECLARE_PFFileNavController
    if (indexPath.section == 0) {
        //Folder
        NSString *item = [folders objectAtIndex:indexPath.row];
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        [navController pushToFolder:itemPath];
    } else if (indexPath.section == 1) {
        //Files
        NSString *item = [files objectAtIndex:indexPath.row];
        NSString *itemPath = [path stringByAppendingPathComponent:item];
        NSString *oldSelectedItemRef = selectedItemRef;
        selectedItemRef = item;
        BOOL canSelectFile = [navController canSelectFile:itemPath];
        self.navigationItem.rightBarButtonItem.enabled = canSelectFile;

        if (navController.doubleSelectToOperate
            && canSelectFile
            && (oldSelectedItemRef == item)) {
            [self onOperate];
        }
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    self.labelTextColor = nil;
    [path release];
    [folders release];
    [files release];
    [super dealloc];
}


@end

