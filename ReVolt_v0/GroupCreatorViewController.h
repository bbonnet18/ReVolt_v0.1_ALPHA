//
//  GroupCreatorViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This class will create a new Group object and pass it back to the parent view controller, this will only be launched modally
#import <UIKit/UIKit.h>
#import "Group.h"
#import "TextEntryViewController.h"

@protocol GroupCreatorProtocol

- (void) didSaveGroup: (Group*) group;
- (void) didCancelGroupCreation;

@end

@interface GroupCreatorViewController : UIViewController <UITextFieldDelegate,ScreenTextEditor, UIAlertViewDelegate>
{
    Group * _group; 
    id <GroupCreatorProtocol> _delegate;
    UITextField *_activeTextField;// allows us to track whether the title or another textfield has been tapped so we can provide the necessary keyboard adjustments
    BOOL _didFinishEditing;
    BOOL _didMakeChanges;
    NSManagedObjectContext *_context;
    NSOperationQueue *_opsQueue;// will hold all the upload operations
    NSString *groupIDNumber;//we will hold this as a string on the return from the web service 
    
}

@property (strong, nonatomic) IBOutlet UITextField *tags;

@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) NSOperationQueue *opsQueue;// the queue to hold the network request operation
@property (strong, nonatomic) IBOutlet UITextField *groupName;// name property
@property (strong, nonatomic) IBOutlet UITextView *groupDescription;// description of the group
@property (strong, nonatomic) IBOutlet UIButton *editTextBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) Group *group;// the group that will be populated in this window
@property (strong, nonatomic) UITextField *activeTextField;
@property BOOL didMakeChanges;
@property (strong, nonatomic) id <GroupCreatorProtocol> delegate;
- (IBAction)saveGroup:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)editText:(id)sender;
@end
