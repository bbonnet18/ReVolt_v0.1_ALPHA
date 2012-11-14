//
//  PostsManagerViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostsManagerViewController.h"

@interface PostsManagerViewController ()

@end

@implementation PostsManagerViewController

@synthesize context = _context;
@synthesize fetched = _fetched;
@synthesize groupForPosts = _groupForPosts;
@synthesize isLeader = _isLeader;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Posts"];
    
    // if the group leader is the user, then set the isLeader boolean to YES, this will be used to determine whether the user can add posts 
    self.isLeader = NO;
    if([[[self groupForPosts] leader] isEqualToNumber:[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]]){
        self.isLeader = YES;
        UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPostAndPopulate:)];
        self.navigationItem.rightBarButtonItem = addItem;
    }
    
    NSError *error;
    if(![self.fetched performFetch:&error]){
        NSLog(@"ERROR: %@", error);
    }


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
   
}

- (void) viewDidUnload{
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Go to the new post creation controller
-(void) addNewPostAndPopulate:(id)sender{
        // create a build and set the properties, this will be sent to the next BuildMainEditScreen controller
        
        TitleDescriptionView *tv = [[TitleDescriptionView alloc] initWithNibName:@"TitleDescriptionView" bundle:[NSBundle mainBundle]];
        tv.thisGroup = self.groupForPosts;
        tv.context = self.context;

        tv.title = @"Create Post";
   // self.fetched = nil;// setting this to nil to make sure contents are not updated on this instance since it will be deallocated when we come back to this screen and move to the next
        [self.navigationController pushViewController:tv animated:YES];

    
}

#pragma mark - action methods for the table cells 
-(void)goToAndEdit:(id)sender event:(id)event {
    
//    UIButton *thisBtn = (UIButton*)sender;//reference to the button
//    NSIndexPath *indexPath = nil;// instantiate the indexPath
//    UIView *parent = [thisBtn superview]; // get the parent
//    
//    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
//        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
//        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
//    }
//    if(indexPath != nil){
//        Post *p = [self.fetched objectAtIndexPath:indexPath];
//        TitleDescriptionView *detailViewController = [[TitleDescriptionView alloc] initWithNibName:@"TitleDescriptionView" bundle:[NSBundle mainBundle]];
//        detailViewController.thisPost = p; 
//        detailViewController.context = self.context;
//        [self.navigationController pushViewController:detailViewController animated:YES];
//    }
    
    [self goToAndView:sender event:event];
    
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
        Post *p = [self.fetched objectAtIndexPath:indexPath];// get the build
        
        Build *b = [p valueForKey:@"build"];
        
        UploadViewer *detailViewController = [[UploadViewer alloc] initWithNibName:@"UploadViewer" bundle:[NSBundle mainBundle]];
        detailViewController.context = self.context;
        detailViewController.build = b;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

-(void) goToAndView:(id)sender event:(id)event{
    
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
    }
    if(indexPath != nil){
        Post *p = [self.fetched objectAtIndexPath:indexPath];// get the build
        
        PostViewViewController *detailViewController = [[PostViewViewController alloc] initWithNibName:@"PostViewViewController" bundle:[NSBundle mainBundle]];
        detailViewController.thisPost = p;
        detailViewController.context = self.context;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }

    
    
}

#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSUInteger total = [self.fetched.sections count];
    if(total == 0){
        self.title = @"No Posts Yet";
    }
    return [self.fetched.sections count];// should always be 1
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];// get the number of objects in the section from the sectionInfo data
    
    return [sectionInfo numberOfObjects];
}



// return the titles for the section
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];// get the number of objects in the section from the sectionInfo data
    
    NSString *s = [sectionInfo name];
    NSRange r = [s rangeOfString:@"+"];
    NSString *sa = nil;
    if(r.location != 0){// make sure the + is in the string
       sa = [s substringToIndex:r.location];
    }else{
        sa = s;
    }
    // create a new date format to build a new set of strings
    NSDateFormatter *raw = [[NSDateFormatter alloc] init];
    
    [raw setDateFormat:@"yyyy-mm-dd HH:mm:ss "];// set it to handle the incoming date so we can get the day, month and year out of it
    NSDate *rawDate = [raw dateFromString:sa];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd"];
    
    NSString *myDayString = [NSString stringWithFormat:@"%@",
                   [df stringFromDate:rawDate]];
    
    [df setDateFormat:@"MMM"];
    
     NSString *myMonthString = [NSString stringWithFormat:@"%@",
                     [df stringFromDate:rawDate]];
    
    [df setDateFormat:@"yyyy"];
    
     NSString *myYearString = [NSString stringWithFormat:@"%@",
                    [df stringFromDate:rawDate]];
    
    [df setDateFormat:@"HH:mm:ss"];
    NSString *myHourString = [NSString stringWithFormat:@"%@",[df stringFromDate:rawDate]];


    NSString *formattedDateString = [NSString stringWithFormat:@"%@ %@, %@ at %@",myMonthString,myDayString,myYearString,myHourString];
    NSLog(@"formattedDateString: %@", formattedDateString);
    
    
   
    return formattedDateString;
    
}

- (UIButton*) setAccessoryView:(NSString*)status{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
    
    if( ![self isLeader] || [status isEqualToString:@"view"]){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"view" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndView:event:) forControlEvents:UIControlEventTouchUpInside];
    }else if([status isEqualToString:@"uploading"]){
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"uploading" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndCheckUpload:event:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:@"edit" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToAndEdit:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return btn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Post *p = [self.fetched objectAtIndexPath:indexPath];
    
    UIButton *accBtn = [self setAccessoryView:p.status];
    if(accBtn != nil){
        [cell setAccessoryView:accBtn];// set the accessory view to the new button, which will perform actions for this post
    }
    
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",p.id];
    
    
    
    
    return cell;
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
    
    /* <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - FetchedResultsControllerDelegate methods

- (NSFetchedResultsController*) fetched{
    
    if(_fetched != nil){
        return _fetched;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // set the predicate to get the posts where the group is equal to the group provied
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@",self.groupForPosts];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date_created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    
    
    self.fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"date_created" cacheName:nil];
    self.fetched.delegate = self;
    return _fetched;
    
}

// - problem may be caused when it tries to send the message to a previous instance of this controller, but it has now added a new instance of it and therefore the old instance is not there and can't be accessed

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

- (void)dealloc{
    self.fetched = nil;
}



@end
