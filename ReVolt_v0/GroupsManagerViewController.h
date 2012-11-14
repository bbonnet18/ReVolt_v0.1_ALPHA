//
//  GroupsManagerViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Group.h"
#import "GroupCreatorViewController.h"
#import "GroupDetailViewController.h"
#import "PostsManagerViewController.h"


@interface GroupsManagerViewController : UITableViewController <NSFetchedResultsControllerDelegate, GroupCreatorProtocol, GroupDetailProtocol>{

//id <GroupEditor> _delegate; 
NSFetchedResultsController *_fetched;
NSManagedObjectContext *_context;

}


@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) Group *group;

-(void)addNewGroupAndPopulate:(id) sender;// launches the new group view controller and allows the user to fill in the title and description fields 


@end
