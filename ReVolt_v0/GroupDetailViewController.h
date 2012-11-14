//
//  GroupDetailViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// The is simply a viewer, the user can not edit once they have created the group

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol GroupDetailProtocol 
@required

-(void) didDismissGroupDetailView;// this will simply dismiss the view


@end

@interface GroupDetailViewController : UIViewController <UIAlertViewDelegate>
{

    id <GroupDetailProtocol> _delegate;// delegate must comform to the protocol
    Group * _myGroup;// the group we will use for the details
    NSManagedObjectContext *_context;// context passed in from the delegate
}

@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupTagsLabel;
@property (strong, nonatomic) IBOutlet UIButton *okBtn;
- (IBAction)returnToGroupsViewer:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *groupDescriptionText;
@property (strong, nonatomic)  id<GroupDetailProtocol> delegate;
@property (strong, nonatomic) Group *myGroup;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end
