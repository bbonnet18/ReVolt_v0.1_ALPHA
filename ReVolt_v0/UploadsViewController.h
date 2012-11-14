//
//  UploadsViewController.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Build.h"
#import "BuildItem.h"




@interface UploadsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
        
        UITableView *tv;
   // id <BuildEditor> delegate; 
    Build *_build;
    NSFetchedResultsController *_fetched;
       NSManagedObjectContext *_context;
    
    
}


@property (strong, nonatomic) IBOutlet UITableView *tv;// table view
//@property (strong, nonatomic) id <BuildEditor> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) Build *build;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc

-(void)addNewBuildAndPopulate:(id) sender;
//- (void)buildTableCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
