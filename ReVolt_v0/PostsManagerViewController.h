//
//  PostsManagerViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PostCreatorViewController.h"
#import "Group.h"
#import "TitleDescriptionView.h"
#import "Build.h"
#import "UploadViewer.h"
#import "PostViewViewController.h"

@interface PostsManagerViewController : UITableViewController <NSFetchedResultsControllerDelegate, PostCreatorProtocol>
{
    
    NSFetchedResultsController *_fetched;
    NSManagedObjectContext *_context;
    Group * _groupForPosts;// Group selected on the previous screen
    Boolean _isLeader;// boolean to tell whether the user is the leader of the group
    
}


@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) Group * groupForPosts;
@property (nonatomic, assign) Boolean isLeader;

-(void)addNewPostAndPopulate:(id) sender;// launches the new post creator view controller and allows the user to create a post
@end
