//
//  UploadsViewController.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UploadsViewController.h"
#import "AppDelegate.h"
#import "UploadViewer.h"
#import "TitleDescriptionView.h"

#define BUILDNUMBER [NSString stringWithFormat:@"build%d", self->buildCount]
#define BUILDID [NSString stringWithFormat:@"%d", self->buildCount]

@implementation UploadsViewController
@synthesize tv;
//@synthesize delegate;
@synthesize fetched = _fetched;
@synthesize build = _build;
@synthesize context = _context;

- (id)initWithStyle:(UITableViewStyle)style// initwithstyle creates a table view and puts it as the rootview? 
{
    self = [super initWithStyle:style];
    if (self) {
//        UITableView * tableV = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
//        
//        self.tv = tableV;
//        [self.view addSubview:tv];
//        tv.delegate = self;
    }

    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewBuildAndPopulate:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    NSError *error;
    if(![self.fetched performFetch:&error]){
        NSLog(@"ERROR: %@", error);
    }
    
    NSArray *arr = self.fetched.fetchedObjects;
    for(Build *b in arr){
        NSLog(@"id: %@",[b valueForKey:@"buildID"]);
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    self.fetched = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Get Table objects

- (NSFetchedResultsController*) fetched{
    
    if(_fetched != nil){
        return _fetched;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    
    
    self.fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetched.delegate = self;
        return _fetched;

}

/* Get the status and provide the right view based on the status of the build */

// this method will get the build associated with this row and set it with the delegate method
//-(Boolean)setBuildID:(id)sender{
//    UIButton *thisBtn = (UIButton*)sender;//reference to the button
//    NSIndexPath *indexPath = nil;// instantiate the indexPath
//    UIView *parent = [thisBtn superview]; // get the parent
//    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
//        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
//        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
//    }
//    if(indexPath != nil){
//        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
//        [self.delegate setCurrentBuildID:[b valueForKey:@"buildID"]];// set the build ID
//        return YES;
//    }
//    
//    return NO;
//
//
//}
// go to edit this item
-(void)goToAndEdit:(id)sender event:(id)event {
        
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
    }
    if(indexPath != nil){
//        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
//        TitleDescriptionView *detailViewController = [[TitleDescriptionView alloc] initWithNibName:@"TitleDescriptionView" bundle:[NSBundle mainBundle]];
//        detailViewController.context = self.context;
//        detailViewController.thisBuild = b;
//        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

// check on the upload
-(void) goToAndCheckUpload:(id)sender event:(id)event{
    
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
    }
    if(indexPath != nil){
        Build *b = [self.fetched objectAtIndexPath:indexPath];// get the build
        UploadViewer *detailViewController = [[UploadViewer alloc] initWithNibName:@"UploadViewer" bundle:[NSBundle mainBundle]];
        // ...
        detailViewController.context = self.context;
        detailViewController.build = b;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

-(void) goToAndView:(id)sender event:(id)event{
    
}

-(void)addNewBuildAndPopulate:(id) sender{
        
    NSNumber *oldID = [[NSUserDefaults standardUserDefaults] valueForKey:@"buildID"];
    NSInteger oldInt = [oldID intValue];
    NSInteger newInt = oldInt +1;
    
    NSNumber* newID = [NSNumber numberWithInt:newInt];
    
        Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
        
        newBuild.creationDate = [NSDate date];
        //newBuild.title = @"build title";
        newBuild.status = @"edit";
        //newBuild.context = @"Here and now";
        newBuild.buildID = newID;
        //newBuild.buildDescription = @"this is about the second one";
        NSError *error;
    NSLog(@"error: %@",[error localizedDescription]);
        if(![self.context save:&error])
            NSLog(@"%@", [error localizedFailureReason]);

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fetched.sections count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSDictionary *dictionary = [listOfItems objectAtIndex:section];
        
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];

}
// builds the cell with the information from the BuildItem
//- (void)buildTableCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    Build *build = [_fetched objectAtIndexPath:indexPath];
//    
//    // 
//    if(!build.uploaded){
//        //UIImage *img = [UIImage imageNamed:@"WWAN5.png"];
//        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        editBtn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
//        //[editBtn setBackgroundImage:img forState:UIControlStateNormal];
//        editBtn.backgroundColor = [UIColor clearColor];
//        [editBtn setTitle:@"upload" forState:UIControlStateNormal];
//        cell.accessoryView = editBtn; 
//    }
//    cell.textLabel.text = build.name;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
//                                 build.buildID];
//  
//}

// returns the accessory view for each row as a button
- (UIButton*) setAccessoryView:(NSString*)buildStatus{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
    
    if([buildStatus isEqualToString:@"uploading"]){
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"uploading" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndCheckUpload:event:) forControlEvents:UIControlEventTouchUpInside];
    }else if([buildStatus isEqualToString:@"view"]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"view" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndView:event:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"edit" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndEdit:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    /*UIButton *accView = [self setAccessoryView:build.status];
     if(accView != nil){// make sure we get the view
     cell.accessoryView = [self setAccessoryView:build.status];
     }
     cell.textLabel.text = @"the title";//build.title;
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
     build.buildID];*/
    
    return btn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // add in the button for checking on uploads
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] 
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }
    // Set up the cell...
    
    Build *build = [_fetched objectAtIndexPath:indexPath];
    
    UIButton *accView = [self setAccessoryView:build.status];
    if(accView != nil){// make sure we get the view
         cell.accessoryView = [self setAccessoryView:build.status];
    }
    cell.textLabel.text = @"the title";//build.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
                                 build.buildID];
    
    return cell;
}




- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
//    if(section == 0)
//        return @"Builds";
//    else
//        return @"Countries visited";
    
    return @"list of your builds";
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    //UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
//    NSString *buildName = [buildToSet valueForKey:@"buildName"];
//    
//    NSString* isUploaded = [buildToSet valueForKey:@"uploaded"];
    
    
    
}

#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
