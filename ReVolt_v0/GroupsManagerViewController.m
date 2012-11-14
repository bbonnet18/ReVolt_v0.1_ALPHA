//
//  GroupsManagerViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupsManagerViewController.h"
//#import "AppDelegate.h"

@interface GroupsManagerViewController ()



@end



@implementation GroupsManagerViewController


@synthesize context = _context;
@synthesize fetched = _fetched;
@synthesize group = _group;


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
    
    
    UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewGroupAndPopulate:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    NSError *error;
    if(![self.fetched performFetch:&error]){
        NSLog(@"ERROR: %@", error);
    }
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.context = nil;
    self.group = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO]; //set the toolbar to hidden in case it is already showing for some reason (i.e. we don't know where the user is coming from in the application
    [self.tableView reloadData];// reload the data to refresh the table
}

#pragma mark - custom methods

-(void) addNewGroupAndPopulate:(id)sender{
    GroupCreatorViewController *gc = [[GroupCreatorViewController alloc] initWithNibName:@"GroupCreatorViewController" bundle:[NSBundle mainBundle]];
    gc.delegate = self;
    gc.context = self.context;
    [self presentModalViewController:gc animated:YES];
}

#pragma mark - GroupCreatorProtocol methods

-(void)didSaveGroup:(Group *)group{
    // save the group and dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) didCancelGroupCreation{
    // dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.fetched.sections count];// should always be 1
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];// get the number of objects in the section from the sectionInfo data
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] 
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }

    Group *g = [self.fetched objectAtIndexPath:indexPath];// get the group that corresponds with this index
   
    cell.textLabel.text = g.name;
 
    
    UIButton *groupInfoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [groupInfoBtn setTitle:@"Info" forState:UIControlStateNormal];
    [groupInfoBtn addTarget:self action:@selector(launchGroupInfo:event:) forControlEvents:UIControlEventTouchUpInside];
    groupInfoBtn.frame = CGRectMake(0.0, 0.0, 60.0, 25.0);
    cell.accessoryView = groupInfoBtn;
    
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetched sections] objectAtIndex:section];// get the number of objects in the section from the sectionInfo data
    // check to see if the user is the leader of the group, if so, then return groups you lead otherwise they are groups you follow
    
    if([[NSNumber numberWithInt:[[sectionInfo name] intValue]] isEqualToNumber:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]]){
        return @"Groups You Lead";
    }else{
        return  @"Groups you Follow";
    }
}


// launch the info screen for the group so the user can view/change the group
// this will get the item in the fetched results controller and present it modally
- (void) launchGroupInfo:(id)sender event:(id)event{
    UIButton *thisBtn = (UIButton*)sender;//reference to the button
    NSIndexPath *indexPath = nil;// instantiate the indexPath
    UIView *parent = [thisBtn superview]; // get the parent
    if([parent isKindOfClass:[UITableViewCell class]]){// check to see if the parent is a UITableViewCell
        UITableViewCell *cell = (UITableViewCell*)parent;// if so, get the cell
        indexPath = [self.tableView indexPathForCell:cell];// else get the index path
    }
    if(indexPath != nil){
        Group *g = [self.fetched objectAtIndexPath:indexPath];// get the build
        GroupDetailViewController *dv = [[GroupDetailViewController alloc] // initiate the GroupDetailViewController
        initWithNibName:@"GroupDetailViewController" bundle:[NSBundle mainBundle]];
        dv.myGroup = g;
        
        
        dv.delegate = self;// assign the delegate
        dv.context = self.context;// assign the context
        [self presentModalViewController:dv animated:YES];// present the view modally
    }

    
}


#pragma mark - GroupDetailProtocol

-(void) didDismissGroupDetailView{// simply dismisses the view controller
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    
     PostsManagerViewController *detailViewController = [[PostsManagerViewController alloc] initWithNibName:@"PostsManagerViewController" bundle:[NSBundle mainBundle]];
    Group *g = [self.fetched objectAtIndexPath:indexPath];
    
    detailViewController.context = self.context;
    detailViewController.groupForPosts = g; 
    
     [self.navigationController pushViewController:detailViewController animated:YES];
     
}

#pragma mark - NSFetchedResultsController delegate methods
// this is very important, because it instantiates the fetched object and performs the initial fetch
- (NSFetchedResultsController*) fetched{
    
    if(_fetched != nil){
        return _fetched;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"leader" ascending:YES];
//    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"leader" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        NSLog(@"obj1: %@ | obj2: %@",obj1 , obj2);
//        
//        if(obj1 != [NSNumber numberWithInt:1])
//            return NSOrderedDescending;
//        else
//            return NSOrderedAscending;
//        
//    }];    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    
    
    self.fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"leader" cacheName:nil];
    self.fetched.delegate = self;
    return _fetched;
    
}

-(NSComparisonResult)compareLeader:(NSNumber*) num{
    return NSOrderedSame;
}

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
    self.fetched = nil;// have to call this here because you are passing around the same context to multiple controllers. Other controllers that add data will attempt to update data on this object because the fetechedResultsControllers are all tied to the same context. If this view has been deallocated, it will cause an error if the fetchedResultsController receives a message to update it's data
}

@end
